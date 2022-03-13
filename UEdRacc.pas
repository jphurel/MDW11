unit UEdRacc;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  ShellApi, ShlObj, ActiveX,
  BJPH.StringUtils;

type
  TFEdRacc = class(TForm)
    PnFen: TPanel;
    PnBtns: TPanel;
    BbAnn: TBitBtn;
    BbOK: TBitBtn;
    Label1: TLabel;
    EdPath: TEdit;
    Label3: TLabel;
    EdNom: TEdit;
    BtRechercher: TButton;
    OD: TFileOpenDialog;
    Label2: TLabel;
    EdDir: TEdit;
    Label4: TLabel;
    EdParams: TEdit;
    procedure BtRechercherClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    function executer(var path,params,dir,nom:string; posX:integer):boolean;
  end;

var
  FEdRacc: TFEdRacc;

implementation

{$R *.dfm}

procedure TFEdRacc.BtRechercherClick(Sender: TObject);
begin
  if OD.Execute then EdPath.Text:= OD.FileName;
end;

function ExtraireDonneesDuRaccourci(var Spath,Sprm,Sdir,Snom:string):boolean;
var
ISL: IShellLink;
IPF: IPersistFile;
gIPF: TGUID;
Hr: HRESULT;
buf: array[0..MAX_PATH+1] of Char;
bufw: array[0..MAX_PATH+1] of WideChar;
pfd:TWin32FindData;
begin
  result:= false;
//  Pbuf:=StrAlloc(MAX_PATH+1);
  // Get a pointer to the IShellLink interface.
  Hr:= CoCreateInstance(CLSID_ShellLink, NIL, CLSCTX_INPROC_SERVER, IID_IShellLink, ISL);// Get a pointer to the IShellLink interface.
  if Succeeded(Hr) then begin
    gIPF:=StringToGUID('{0000010B-0000-0000-C000-000000000046}');
    Hr:=ISL.QueryInterface(gIPF, IPF);// Get a pointer to the IPersistFile interface.
    if Succeeded(Hr) then begin
      StringToWideChar(Spath, @bufw, MAX_PATH+1);// Ensure that the string is Unicode.
      Hr:=IPF.Load(@bufw, STGM_READ);// Load the shortcut.
      if Succeeded(Hr) then begin
        Hr:=ISL.Resolve(FEdRacc.Handle, SLR_ANY_MATCH);// Resolve the link.
        if Succeeded(Hr) then begin
          Hr:=ISL.GetPath(@buf, MAX_PATH, pfd, SLGP_UNCPRIORITY);// Get the path to the link target.
          if not Succeeded(Hr) then exit;
          Spath:= WideCharToString(@buf);//+'\'+pfd.cFileName;
          Hr:=ISL.GetArguments(@buf, MAX_PATH);
          if not Succeeded(Hr) then exit;
          Sprm:= buf;
          Hr:=ISL.GetWorkingDirectory(@buf, MAX_PATH);
          if not Succeeded(Hr) then exit;
          Sdir:= buf;
          Hr:=ISL.GetDescription(@buf, MAX_PATH);
          if not Succeeded(Hr) then exit;
          Snom:= buf;
          result:= true;
        end;
      end;
    end;
  end;
end;

function ProposerExtraireDonneesDuRaccourci(var Spath,Sprm,Sdir,Snom:string):boolean;
var
n: integer;
begin
  result:= false;//true si fait
  //si c'est un raccourci, proposer de le shunter
  if UpperCase( ExtractFileExt(Spath) ) = '.LNK' then begin
    n:= MessageDlg('Voulez-vous contourner le raccourci?' +k_CRLF+
                   'si oui, les paramètres du raccourci seront récupérés et le raccourci pourra être déplacé ou supprimé' +k_CRLF+
                   'si non, vous devrez le laisser à son emplacement', mtConfirmation,
                   mbYesNoCancel, 0);
    case n of
    mrYes: if ExtraireDonneesDuRaccourci(Spath,Sprm,Sdir, Snom)
      then result:= true
      else begin
        ShowMessage('impossible d''extraire les données du raccourci, abandon');
        exit;
      end;
    mrNo:;
    mrCancel: exit;
    end;
  end;
end;

function TFEdRacc.executer(var path,params,dir,nom:string; posX:integer):boolean;
begin
  self.Left:= posX;
  ProposerExtraireDonneesDuRaccourci(path, params, dir, nom);
  EdPath.Text:= path;
  EdParams.Text:= params;
  EdDir.text:= dir;
  EdNom.Text:= nom;
  result:= ShowModal = mrOK;
  if result then begin
    path:= Trim(EdPath.Text);
    params:= Trim(EdParams.Text);
    dir:= Trim(EdDir.Text);
    nom:= Trim(EdNom.Text);
  end;
end;

end.
