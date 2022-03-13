unit UMDW11PRMS;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Winapi.ShlObj, System.Win.Registry, Winapi.ShellAPI,
  BJPH.Utils, BJPH.DlphUtil, BJPH.StringUtils;

type
  TFMDW11Prms = class(TForm)
    PnFen: TPanel;
    Label2: TLabel;
    EdNbIco: TEdit;
    BtCoulFond: TButton;
    BtPolice: TButton;
    PnBtns: TPanel;
    BbAnn: TBitBtn;
    BbOK: TBitBtn;
    CD: TColorDialog;
    FD: TFontDialog;
    Label1: TLabel;
    EdMrgVert: TEdit;
    EdMrgHoriz: TEdit;
    BtDesinstaller: TButton;
    procedure BtCoulFondClick(Sender: TObject);
    procedure BtPoliceClick(Sender: TObject);
    procedure BtDesinstallerClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    function executer(posX:integer):boolean;
  end;

var
  FMDW11Prms: TFMDW11PRMS;

procedure TerminerLaDesinstallation;

implementation

{$R *.dfm}

uses UMDW11;

procedure TFMDW11Prms.BtCoulFondClick(Sender: TObject);
begin
  CD.Execute(self.Handle);
end;

procedure TFMDW11Prms.BtDesinstallerClick(Sender: TObject);
begin  //       EXIT;
  if MessageDlg('Menu Démarrer pour Windows11 (MDW11) va être désinstallé ; Continuer?',
                mtConfirmation, mbYesNo, 0) <> mrYes then exit;
//copier mdW11 dans un répertoire temporaire
  ShCopy(DirAppliBS + 'MDW11.EXE', DirWinTempBS + 'MDW11\MDW11.EXE');
//prévenir
  ShowMessage('Pour terminer la désinstallation, MDW11 va être relancé "en tant qu''administrateur" ; vous devez accepter son exécution');
//relancer en mode admin
  ShellExecute(0, PChar('runas'), PChar(DirWinTempBS + 'MDW11\MDW11.EXE'), PChar('/U'), nil, SW_SHOWNORMAL);

//arrêter cette instance
  halt;
end;

procedure TerminerLaDesinstallation; //on doit être en mode administrateur
var
bat,pathbat: string;
Pwc: PWideChar;
Reg: TRegistry;
begin
  ShowMessage('MDW11 : poursuite de la désinstallation');
//ouvrir le registre et supprimer la clé
  Reg:= TRegistry.Create(KEY_ALL_ACCESS);
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if NOT Reg.DeleteKey(k_regkeyapp) then begin
      ShowMessage('Impossible d''accéder au registre de windows ; êtes-vous administrateur?');
      ShowMessage('abandon de la désinstallation');
      halt;
    end;
  finally
    Reg.Free;
  end;
//supprimer le prog
  ShGetKnownFolderPath(StringToGUID('{6D809377-6AF0-444b-8957-A3773F02200E}'), 0, 0, Pwc); //FOLDERID_ProgramFilesX64
  ShDelete( Pwc + '\MDW11' );
// effacer les raccourcis
//bureau
  ShGetKnownFolderPath( StringToGUID('{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}'), 0, 0, Pwc); //FOLDERID_Desktop
  DeleteFile( Pwc + '\MDW11.lnk' );
//démarrage
  ShGetKnownFolderPath( StringToGUID('{B97D20BB-F46A-4C97-BA10-5E3608430854}'), 0, 0, Pwc); //FOLDERID_Startup
  DeleteFile( Pwc + '\MDW11.lnk' );

//créer le .bat
  pathbat:= Pwc + '\MDW11UNINST.BAT';//dans le menu démarrer
  bat:=
// supprimer le répertoire temporaire
        'rmdir /q /s "' + DirWinTempBS + 'MDW11"' + k_CRLF +
//effacer le .bat
        'del "' + pathbat + '"' ;
  StringToFile(bat, pathbat);
  ShowMessage('MDW11 a été désinstallé de votre PC ; quelques fichiers temporaires seront supprimés au prochain démarrage de Windows');
  halt;
end;

procedure TFMDW11Prms.BtPoliceClick(Sender: TObject);
begin
  FD.Execute(self.Handle);
end;

function TFMDW11PRMS.executer(posX:integer):boolean;
begin
  self.Left:= posX;
  EdNbIco.Text:= IntToStr(FMDW11.NbIconesParLigne);
  EdMrgHoriz.Text:= IntToStr(FMDW11.IconMrgH);
  EdMrgVert.Text:= IntToStr(FMDW11.IconMrgV);
  CD.Color:= FMDW11.PBx.Color;
  FD.Font:= FMDW11.PBx.Font;
  result:= ShowModal = mrOK;
  if result then begin
    FMDW11.NbIconesParLigne:= StrToIntDef( Trim(EdNbIco.Text), k_nbiconhz);
    FMDW11.IconMrgH:= StrToIntDef( Trim(EdMrgHoriz.Text), k_iconmrgdef);
    FMDW11.IconMrgV:= StrToIntDef( Trim(EdMrgVert.Text), k_iconmrgdef);
    FMDW11.PBx.Color:= CD.Color;
    FMDW11.Color:= CD.Color;
    FMDW11.PBx.Font:= FD.Font;
  end;
end;

end.

