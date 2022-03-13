unit UMDW11;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.Commctrl,
  System.SysUtils, System.Classes, Vcl.Graphics, clipbrd,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, System.Win.Registry,
  Vcl.ExtCtrls, ShellApi, ShlObj, ActiveX, Vcl.Menus,
  BJPH.StringUtils, BJPH.DlphUtil, BJPH.Utils;

const
k_versprgact = 1; //la version actuelle du programme
k_widthreplie = 2;
k_iconsize = 32;
k_iconmrgdef = 4;//marges par défaut
k_mrggicon = k_iconsize div 2;//la marge gauche de la ligne d'icones
k_nbiconhz = 5;//la largeur de fenêtre fera 5.5 * k_iconsize
k_mrgtx = 2;
k_numvers = 1;
k_regkeyapp = 'Software\JPH\MDW11';
k_datadefaut = '1' +k_CRLF+
               '5' +k_TAB+'4'+k_TAB+'4'+k_TAB+'0'+k_TAB+'"Arial"'+k_TAB+'8'+k_TAB+'16777215' +k_CRLF+
               k_TAB+k_TAB+k_TAB+'système' +k_CRLF+
               k_TAB+k_TAB+k_TAB+'applications' +k_CRLF+
               k_TAB+k_TAB+k_TAB+'utilitaires';
k_aide = 'Les raccourcis peuvent être ajoutés par copier-coller et par glisser-déposer.' +k_CRLF+
         'Ils peuvent aussi être créés manuellement.' +k_CRLF+
         'Les éléments acceptés sont des dossiers et des fichiers (quelconques, raccourcis, et exécutables).' +k_CRLF+
         'Les raccourcis et groupes peuvent être déplacés par glisser-déposer au sein de la fenêtre MDW11' +k_CRLF+
         'Les raccourcis sont activés par simple clic.';// +k_CRLF+

type
  TAppli = class
    PathAppli,         //vide pour un titre de groupe
    ParamsAppli,
    DirExeAppli,
    NomAppli: string;  //le titre de groupe ou le texte affiché de l'icone
    Icon: TIcon;
    HG: TPoint;  //pour les textes, HG.X est la largeur du texte
    function AppliGroupe:boolean;
  end;
  TDropTarget = class(TInterfacedObject, IDropTarget)
  public
    function DragEnter(const dataObj: IDataObject; grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function DragOver(grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
  end;

  TFMDW11 = class(TForm)
    PBx: TPaintBox;
    PPm: TPopupMenu;
    MiEditer: TMenuItem;
    MiRetirer: TMenuItem;
    MiColler: TMenuItem;
    MiAjouterungroupe: TMenuItem;
    MiAjouterunraccourci: TMenuItem;
    TimDrag: TTimer;
    N1: TMenuItem;
    MiParametres: TMenuItem;
    N2: TMenuItem;
    MiQuitter: TMenuItem;
    importexport: TMenuItem;
    MiExporterVersLePressePapier: TMenuItem;
    MiImporterDepuisLePressePapier: TMenuItem;
    MiAjouterunutilitaireWindows: TMenuItem;
    N3: TMenuItem;
    MiEditeurduregistre: TMenuItem;
    MiInviteDeCommande: TMenuItem;
    MiBlocnote: TMenuItem;
    MiCalculette: TMenuItem;
    MiAide: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure PBxPaint(Sender: TObject);
    procedure MiRetirerClick(Sender: TObject);
    procedure MiEditerClick(Sender: TObject);
    procedure PBxStartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure PBxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PBxDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure PBxDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure MiAjouterungroupeClick(Sender: TObject);
    procedure MiAjouterunraccourciClick(Sender: TObject);
    procedure MiCollerClick(Sender: TObject);
    procedure PBxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TimDragTimer(Sender: TObject);
    procedure PBxMouseEnter(Sender: TObject);
    procedure PBxMouseLeave(Sender: TObject);
    procedure PBxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PPmPopup(Sender: TObject);
    procedure MiParametresClick(Sender: TObject);
    procedure MiQuitterClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MiExporterVersLePressePapierClick(Sender: TObject);
    procedure MiImporterDepuisLePressePapierClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MiUtilitaireWindowsClick(Sender: TObject);
    procedure MiAideClick(Sender: TObject);
  private
    { Déclarations privées }
    Applis: Array of TAppli;// la liste des applications dans l'ordre d'affichage, 1 par ligne
    IconSzH,IconSzV, //la taille d'icone + le texte en dessous + les marges
    IxSel, //la ligne sélectionnée (clic dans icone)
    IxPos, //idem mais valide pour clic dans marges hz
    htx: integer;//hauteur du texte sans les marges
    AppSel,AppSelDrag,AppIcoSel: TAppli;
    PopUp: boolean;//signale l'affichage du menu
    DropTarget: TDropTarget;
    PFdrop: string;
    procedure AppIdle(Sender:TObject; var Done:boolean);
    procedure AppDeactivate(Sender: TObject);
    procedure Deplier;
    procedure Replier;
    procedure AddApp(path,params,dir,nom:string; pixdrop:Pinteger=nil);
    procedure Deselectionne;
    procedure LoadFromString(S:string);
    procedure LoadData;
    function SaveToString:string;
    procedure SaveData;
    function MouseToEltSel(X,Y:integer):integer; //renvoie la position dans Applis ou -1
    function MouseToEltPos(X,Y:integer):integer; //renvoie la position dans Applis ou -1
    function AutoInstall:boolean;
    function GlobalReadName(H:THandle):string;
    procedure AjoutRaccParPath(PF:string; pixdrop:Pinteger=nil);
  public
    { Déclarations publiques }
    NbIconesParLigne,
    IconMrgH,IconMrgV: integer;  //marge entre icones
    function WidthFen:integer;
  end;

var
  FMDW11: TFMDW11;

implementation

{$R *.dfm}

uses UEdRacc, UMDW11Prms;


function IconFromPath(path:string):TIcon;
var
ixicon,n: word;
ws: array[0..MAX_PATH + 1] of WideChar;
pws: PWideChar;
begin
  try
    result:= TIcon.Create;
    ixicon:= 0;
    pws:= @ws;
    pws:= PChar(path);
    result.Handle:= ExtractAssociatedIcon(0, pws, ixicon);
  except
    on E:Exception do ShowMessage(E.Message + k_CRLF + '(' + path + ')' );
  end;
end;



function TAppli.AppliGroupe:boolean;
begin
  result:= PathAppli = '';
end;

/////////////////////////////////////////////////////////////////////////////////

var
DropTargetHelper: IDropTargetHelper;
function TDropTarget.DragEnter(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
  procedure makehelper;
  //d'après : https://github.com/Baltimore99/delphi-drag-drop/blob/master/Source/DropTarget.pas
  begin
    DropTargetHelper:= nil;
    if (Succeeded(CoCreateInstance(CLSID_DragDropHelper, nil, CLSCTX_INPROC_SERVER,
        IDropTargetHelper, DropTargetHelper))) AND
        (DropTargetHelper <> nil) then DropTargetHelper.DragEnter(FMDW11.WindowHandle, DataObj, pt, dwEffect);
  end;
var
fetc: TFormatEtc;
stgm: tagSTGMEDIUM;
begin
  FMDW11.Deplier;
//vérifier si acceptable
  fetc.cfFormat:= 49158;//CF_TEXT;
  fetc.ptd:= nil;
  fetc.dwAspect:= DVASPECT_CONTENT;
  fetc.lindex:= -1;
  fetc.tymed:= TYMED_HGLOBAL;
  if Succeeded( dataObj.GetData(fetc, stgm) ) then begin
    FMDW11.PFdrop:= FMDW11.GlobalReadName(stgm.hGlobal);
    dwEffect:= DROPEFFECT_COPY;
    makehelper;
  end
  else begin
    FMDW11.PFdrop:= '';
    dwEffect:= DROPEFFECT_NONE;
  end;

end;

function TDropTarget.DragOver(grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
begin
  if FMDW11.PFdrop = ''
   then dwEffect:= DROPEFFECT_NONE
   else dwEffect:= DROPEFFECT_COPY;
  if (DropTargetHelper <> nil) then DropTargetHelper.DragOver(pt, dwEffect);
end;

function TDropTarget.DragLeave: HResult; stdcall;
begin
  FMDW11.Replier;
end;

function TDropTarget.Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult; stdcall;
var
ixdrop: integer;
begin
  if FMDW11.PFdrop = ''
   then dwEffect:= DROPEFFECT_NONE
   else begin
    ixdrop:= FMDW11.MouseToEltPos(pt.X, pt.Y);
    //si ixdrop) = -1 on ajoute en fin
    //sinon on insère à la place, en ixdrop
    FMDW11.AjoutRaccParPath(FMDW11.PFdrop, @ixdrop); //si ixdrop = -1, ajoute en bout
    dwEffect:= DROPEFFECT_copy;
   end;
end;

/////////////////////////////////////////////////////////////////////////////////

procedure TFMDW11.LoadFromString(S:string);
var
Sl: string;
App: TAppli;
n,vers: integer;
begin
  if Trim(S) = '' then S:=k_datadefaut;
  //lecture des paramètres
  vers:= LgetI(S);//version
  Sl:= LgetS(S);//paramètres
  NbIconesParLigne:= getI(Sl, k_nbiconhz);
  IconMrgH:= getI(Sl, k_iconmrgdef);
  IconSzH:= k_iconsize + IconMrgH;
  IconMrgV:= getI(Sl, k_iconmrgdef);
  IconSzV:= k_iconsize + htx + 1 + IconMrgV;
  PBx.Color:= getI(Sl);
  DecodeFont(Sl, PBx.Font);
  //lecture des applis
  SetLength(Applis, 100);
  n:= 0;
  while S <> '' do begin
    Sl:= LgetS(S);
    if Sl = '' then Continue;
    App:= TAppli.Create;
    with App do begin
      PathAppli:= trim( getS(Sl) );
      ParamsAppli:= trim( getS(Sl) );
      DirExeAppli:= trim( getS(Sl) );
      NomAppli:= getS(Sl);
      if PathAppli <> '' then Icon:= IconFromPath(PathAppli);
    end;
    Applis[n]:= App;
    inc(n);
  end;
  SetLength(Applis, n);
  if n = 0 then LoadFromString('');//entrée défectueuse, prend les valeurs par défaut
end;

procedure TFMDW11.LoadData;
var
S: string;
Reg: TRegistry;
begin
  Reg:= TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if NOT Reg.OpenKey(k_regkeyapp, false) then
      ShowMessage('Impossible d''accéder au registre de windows ; réinstallez MDW11');
    S:= Reg.ReadString( 'data');
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
  LoadFromString(S);
end;

function TFMDW11.SaveToString:string;
var
i: integer;
S: string;
begin
  S:= IntToStr(k_numvers) +k_CRLF+
      IntToStr(NbIconesParLigne) +k_TAB+ IntToStr(IconMrgH) +k_TAB+IntToStr(IconMrgV) +k_TAB+
      IntToStr(PBx.Color) +k_TAB+ FontToStr(PBx.Font)+k_CRLF;
  for i:= 0 to High(Applis) do with Applis[i] do begin
    S:= S + PathAppli + k_TAB + ParamsAppli + k_TAB + DirExeAppli + k_TAB + NomAppli + k_CRLF;
  end;
  result:= S;
end;

procedure TFMDW11.SaveData;
var
S: string;
Reg: TRegistry;
begin
  S:= SaveToString;
  Reg:= TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if NOT Reg.OpenKey(k_regkeyapp, false) then
      ShowMessage('Impossible d''accéder au registre de windows ; réinstallez MDW11');
    Reg.WriteString( 'data', S);
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
end;

procedure TFMDW11.AppIdle(Sender:TObject; var Done:boolean);
var
CLSID_CDropTarget,
IID_IDropTarget: TGUID;
begin
  if Applis = nil then begin  //démarrage
    if ParamStr(1) = '/U' then UMDW11Prms.TerminerLaDesinstallation;//s'arrêtera ici
    CLSID_CDropTarget:= StringToGUID('{F9E4BF70-EFA8-411E-A142-F4B02D89D619}');
    IID_IDropTarget:= StringToGUID('{00000122-0000-0000-C000-000000000046}');
{ $IFNDEF DEBUG}
    if NOT AutoInstall then HALT;//ne fait rien si déjà installé
{ $ENDIF}
    DropTarget:= TDropTarget.Create;
//    if Succeeded( CoCreateInstance(CLSID_CDropTarget, NIL, CLSCTX_INPROC_SERVER, IID_IDropTarget, DropTarget) ) then begin
      RegisterDragDrop(self.WindowHandle, DropTarget);
//    end;
    htx:= PBx.Canvas.TextHeight('bp');//avant LoadData
    LoadData; //charge depuis le registre
    Application.OnDeactivate:= AppDeactivate;
    Application.HintHidePause:= 600000;//délai d'extinction 10 mn
    self.ClientWidth:= k_widthreplie;
    self.Top:= 0;
    self.Left:= 0;
    IxSel:= -1; IxPos:= -1;
    PBx.Invalidate;
  end;
end;

procedure TFMDW11.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  RevokeDragDrop(self.WindowHandle);
end;

procedure TFMDW11.FormCreate(Sender: TObject);
begin
  Application.OnIdle:= AppIdle;
  PBx.ControlStyle:= PBx.ControlStyle + [csDisplayDragImage];
end;

procedure TFMDW11.FormShow(Sender: TObject);
begin
   ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TFMDW11.AppDeactivate(Sender: TObject);
begin
  PopUp:= false;
  PBxMouseLeave(Sender);
end;

procedure TFMDW11.Deselectionne;
begin
  IxSel:= -1; IxPos:= -1;
  AppSel:= nil;
  AppIcoSel:= nil;
end;

procedure TFMDW11.AddApp(path,params,dir,nom:string; pixdrop:Pinteger=nil);
//ixdrop est l'emplacement de rangement base 0
//augmente la taille de Applis
var
App: TAppli;
ixdrop,n: integer;
begin
  App:= TAppli.Create;
  App.PathAppli:= path;
  App.ParamsAppli:= params;
  App.DirExeAppli:= dir;
  App.NomAppli:= nom;
  if App.PathAppli <> '' then App.Icon:= IconFromPath(App.PathAppli);
  n:= Length(Applis);            //index du dernier élt
  SetLength(Applis, n + 1);
  if pixdrop = nil then begin  //on ajoute
    Applis[n]:= App;
  end else begin
    ixdrop:= pixdrop^; //le point d'insertion, base 0 ; accepte d'insérer en fin
    if ixdrop = -1 then ixdrop:= n;//Length(Applis);
    n:= n - ixdrop;// - 1;  nb à déplacer
    if (n > 0) then Move( Applis[ixdrop], Applis[ixdrop + 1], n * sizeof(pointer) );//crée la place
    Applis[ixdrop]:= App;
  end;
  SaveData;
  PBx.Repaint;
end;

procedure TFMDW11.MiAideClick(Sender: TObject);
begin
  ShowMessage(k_aide);
end;

procedure TFMDW11.MiAjouterungroupeClick(Sender: TObject);
var
S: string;
begin
  S:= '';
  if NOT InputQuery('MDW11', 'Nom du groupe?', S) then exit;
  AddApp('', '', '', S);
end;

procedure TFMDW11.MiAjouterunraccourciClick(Sender: TObject);
//crée un lien vers le raccourci
var
Sp,Spa,Sd,Sn: string;
begin
  Sp:= ''; Spa:= ''; Sd:= ''; Sn:= '';
  if NOT FEdRacc.executer(Sp, Spa, Sd, Sn, WidthFen) then exit;
  AddApp(Sp, Spa, Sd, Sn, @IxPos);
end;

function TFMDW11.GlobalReadName(H:THandle):string;
var
P: pointer;
ast: AnsiString;
n: integer;
begin
  if H = 0 then result:= ''
  else begin
    P:= GlobalLock(H);
    n:= GlobalSize(H);
    SetLength(ast , n);
    Move(P^ , ast[1] , n);
    result:= Trim(ast);
    GlobalUnlock(H);
  end;
end;

procedure TFMDW11.AjoutRaccParPath(PF:string; pixdrop:Pinteger=nil);
var
Sprm,Sdir,Sn:string;
begin
  Sprm:= '';
  Sdir:= '';
  Sn:= '';
  if NOT FEdRacc.executer(PF, Sprm, Sdir, Sn, WidthFen) then exit;
  AddApp(PF, Sprm, Sdir, Sn, pixdrop);
end;

procedure TFMDW11.MiCollerClick(Sender: TObject);
//si c'est un raccourci, propose de le shunter
var
H: Thandle;
Sp:string;
begin
//récupère l'objet copié
  Clipboard.Open;
  H:= ClipBoard.GetAsHandle(49158); //FileName
  Sp:= GlobalReadName(H);
  Clipboard.Close;
  AjoutRaccParPath(Sp, @IxPos);
end;

procedure TFMDW11.MiParametresClick(Sender: TObject);
begin
  if FMDW11Prms.executer(WidthFen) then begin
    IconSzH:= k_iconsize + IconMrgH;
    IconSzV:= k_iconsize + htx + 1 + IconMrgV;
    SaveData;
    Deplier;
    PBx.Repaint;
  end;
end;

procedure TFMDW11.MiQuitterClick(Sender: TObject);
begin
  Close;
end;

procedure TFMDW11.MiEditerClick(Sender: TObject);
begin
  if Ixsel < 0 then exit;
  with Applis[IxSel] do begin
    if AppliGroupe then begin
      if NOT InputQuery('MDW11', 'Renommez le titre', NomAppli) then exit;
    end else begin
      if NOT FEdRacc.executer(PathAppli, ParamsAppli, DirExeAppli, NomAppli, WidthFen) then exit;
    end;
    SaveData;
    PBx.Repaint;
  end;
end;

procedure TFMDW11.MiUtilitaireWindowsClick(Sender: TObject);
  procedure add(path,nom:string);
  var
  Spa,Sd: string;
  begin
    Spa:= ''; Sd:= '';
    if NOT FEdRacc.executer(path, Spa, Sd, nom, WidthFen) then exit;
    AddApp(path, Spa, Sd, nom, @IxPos);
  end;
begin
  case (Sender as TMenuItem).Tag of
  1:add('C:\windows\syswow64\regedit.exe', 'éditeur du registre');
  2:add('C:\windows\system32\cmd.exe', 'invite de commande');
  3:add('C:\windows\system32\notepad.exe', 'bloc-note');
  4:add('C:\windows\system32\calc.exe', 'calculette');
  end;
end;

procedure TFMDW11.MiExporterVersLePressePapierClick(Sender: TObject);
begin
  Clipboard.AsText:= SaveToString;
  Replier;
end;

procedure TFMDW11.MiImporterDepuisLePressePapierClick(Sender: TObject);
begin
  LoadFromString(Clipboard.AsText);
  SaveData;
  PBx.Repaint;
end;

procedure TFMDW11.MiRetirerClick(Sender: TObject);
begin
  if Ixsel < 0 then exit;
  Applis[IxSel].Free;
  Move(Applis[IxSel + 1], Applis[IxSel], (High(Applis) - IxSel) * sizeof(pointer) );
  SetLength(Applis, High(Applis));
  SaveData;
  PBx.Repaint;
end;

procedure TFMDW11.TimDragTimer(Sender: TObject);
begin
  TimDrag.Enabled:= false;
  if Assigned(AppSel) then begin
    AppSelDrag:= AppSel;
    AppSel:= nil;
    PBx.BeginDrag(true, 0);
  end;
end;

procedure TFMDW11.PBxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  AppSel:= nil;
  AppIcoSel:= nil;
  IxSel:= MouseToEltSel(X, Y);//-1 si rien
  IxPos:= MouseToEltPos(X, Y);
  if (IxSel >= 0) then begin
    AppSel:= Applis[IxSel];
    if NOT AppSel.AppliGroupe then AppIcoSel:= AppSel; //sinon c'est un texte
  end;
  if Button = mbRight then begin //ouvrir un sous-menu
    PPm.Popup(X, Y);
    exit;
  end;
  if AppSel = nil then exit;
  TimDrag.Enabled:= true;
end;

function TFMDW11.WidthFen:integer;
begin
  result:= k_mrggicon + NbIconesParLigne * IconSzH;
end;

procedure TFMDW11.PBxMouseEnter(Sender: TObject);
begin
  Deplier;
end;

procedure TFMDW11.Deplier;
begin
  self.ClientWidth:=  WidthFen;
  SetForegroundWindow(self.WindowHandle);
  PopUp:= false;
end;

procedure TFMDW11.Replier;
begin
  self.ClientWidth:= k_widthreplie;
  Application.HideHint;
end;

procedure TFMDW11.PBxMouseLeave(Sender: TObject);
begin
  if Mouse.IsDragging then exit;
  if PopUp then exit;
  Replier;
end;

procedure TFMDW11.PBxMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
var
i: integer;
begin
  i:= MouseToEltSel(X, Y);
  if (i >= 0) then with Applis[i] do if NOT AppliGroupe then begin
    PBx.Hint:= NomAppli;
    Application.ActivateHint(Mouse.CursorPos);
    exit;
  end;
  Application.HideHint;
end;

procedure TFMDW11.PBxMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
cde,dir,prms: string;
begin
  //lancer une appli
  if AppSel = nil then exit;
  cde:= AppSel.PathAppli;
  prms:= AppSel.ParamsAppli;
  Deselectionne; //évite le drag
  if cde = '' then exit;//c'est un titre
  Replier;
  dir:= ExtractFileDir(cde);
  ShellExecute(0 , 'open', PChar(cde) , PChar(prms) , PChar(dir) , SW_SHOWNORMAL);
end;

function TFMDW11.MouseToEltSel(X,Y:integer):integer;
//renvoie la position dans Applis ou -1 si hors icone
//X,Y doit être sur l'icone ou le texte, pas dans les marges
var
ix,ht: integer;
begin
  for ix:= 0 to High(Applis) do with Applis[ix] do begin
    if (HG.Y > Y) then begin//on a cliqué en bout de la lignes d'icones précédente (si c'était un titre, ça serait géré sur la ligne)
      result:= -1;
      exit;
    end;
    if AppliGroupe      //ligne de titre
     then ht:= htx //+ 2 * k_mrgtx
     else ht:= k_iconsize + htx;
    if (HG.Y <= Y) AND ((HG.Y + ht) >= Y) then begin //on est sur la ligne
      if AppliGroupe then begin  //ligne de titre
        if (X >= 2) AND (X <= 2 + HG.X) then result:= ix else result:= -1;
        exit;
      end else begin  //ligne d'icones
        if (HG.X <= X) AND ((HG.X + k_iconsize) >= X) then begin   //on est sur l'icone
          result:= ix;
          exit;
        end;
      end;
    end;
  end;
  result:=  -1;//pas trouvé
end;

function TFMDW11.MouseToEltPos(X,Y:integer):integer;
//renvoie la position dans Applis ou -1 si après la dernière Appli
//Y doit être sur l'icone, pas dans les marges
//X accepte les marges
var
ix,ht,Xg: integer;
begin
  for ix:= 0 to High(Applis) do with Applis[ix] do begin
    if (HG.Y > Y) then begin//on a cliqué en bout de la lignes d'icones précédente (si c'était un titre, ça serait géré sur la ligne)
      result:= ix;//l'index incrémenté de l'icone précédente
      exit;
    end;
    if AppliGroupe      //hauteur de la ligne
     then ht:= htx //+ 2 * k_mrgtx
     else ht:= k_iconsize + htx;
    if (Y >= HG.Y) AND (Y <= (HG.Y + ht)) then begin //on est sur la ligne
      if AppliGroupe then begin  //ligne de titre
        result:= ix;
        exit;
      end else begin  //ligne d'icones
        Xg:= HG.X;
        if Xg = k_mrggicon then Xg:= 0;  //pour la 1ère icone de la ligne, on accepte le clic dans la marge gauche
        if (X >= Xg) AND (X <= (HG.X + IconSzH)) then begin   //on est sur l'icone
          result:= ix;
          exit;
        end;
      end;
    end;
  end;
  result:=  -1;  //on est sous la dernière
end;
(*  for ix:= 0 to High(Applis) do with Applis[ix] do begin
    if (HG.Y > Y) then begin//on a cliqué en bout de la lignes d'icones précédente (si c'était un titre, ça serait géré sur la ligne)
      result:= -ix;//l'index incrémenté de l'icone précédente
      exit;
    end;
    if AppliGroupe      //hauteur de la ligne
     then ht:= htx + 2 * k_mrgtx
     else ht:= IconSzV;
    if (HG.Y < Y) AND ((HG.Y + ht) > Y) then begin //on est sur la ligne
      if AppliGroupe then begin  //ligne de titre
        if X < HG.X then result:= ix else result:= -(ix + 1);
        exit;
      end else begin  //ligne d'icones
        if (HG.X < X) AND ((HG.X + IconSzH) > X) then begin   //on est sur l'icone
          result:= ix;
          exit;
        end;
      end;
    end;
  end;
  result:= - Length(Applis);  //on est sous la dernière   *)

procedure TFMDW11.PBxPaint(Sender: TObject);
var
i,topact,nbiconhz,leftico: integer;
lignetitre: boolean;//si le dernier élément affiché est un titre
App: TAppli;
begin
  if NOT Assigned(Applis) then exit;
  topact:= 0;
  nbiconhz:= 0;
  lignetitre:= false;
  for i:= 0 to High(Applis) do begin
    App:= Applis[i];
    if App.AppliGroupe then begin //titre
      if lignetitre then inc(topact, IconSzV); //insère 1 "ligne" blanche entre 2 titres
      if nbiconhz > 0 then begin //sauter à la ligne
        inc(topact, IconSzV);
        nbiconhz:= 0;
      end;
      PBx.Canvas.TextOut(2, topact + k_mrgtx, App.NomAppli);
      App.HG.Y:= topact + k_mrgtx;
      App.HG.X:= PBx.Canvas.TextWidth( App.NomAppli );  //longueur du texte
      inc(topact, htx + k_mrgtx * 2); //la marge entoure le texte
      lignetitre:= true;
    end else begin //icone
      lignetitre:= false;
      if nbiconhz = k_nbiconhz then begin //sauter à la ligne
        nbiconhz:= 0;
        inc(topact, IconSzV);
      end;
      leftico:= k_mrggicon + IconSzH * nbiconhz;
      App.HG:= Point(leftico, topact);             //la marge de l'icone est sous l'icone
      PBx.Canvas.Draw(leftico, topact, App.Icon);
      PBx.Canvas.TextRect(Rect(leftico, topact + k_iconsize + 1, k_iconsize, htx),
                          leftico, topact + k_iconsize, App.NomAppli);
      inc(nbiconhz);
    end;
  end;
//  if (topact < k_iconsize) OR (nbiconhz > 0) OR lignetitre then inc(topact, k_iconsize);//ajoute 1 ligne blanche
  self.ClientHeight:= topact + IconSzV + 10;
end;

type
  TDragAppli = class(TDragObjectEx)
    DragApp: TAppli;
    IL: TDragImageList;
    function GetDragImages:TDragImageList; override;
  end;
function TDragAppli.GetDragImages:TDragImageList;
begin
  result:= IL;
end;

var
DApp: TDragAppli;

procedure TFMDW11.PBxStartDrag(Sender: TObject; var DragObject: TDragObject);
begin
  if (AppSelDrag = nil) then exit;   //pas une icone
  DApp:= TDragAppli.Create;
  DragObject:= DApp;
  DApp.AlwaysShowDragImages:= true;
  DApp.DragApp:= AppSelDrag;
  DApp.IL:= TDragImageList.Create(nil);
  with DApp.IL do begin
    Height:= 64;//32;
    Width:= 64;//32;
    AddIcon(AppSelDrag.Icon);
  end;
end;

procedure TFMDW11.PPmPopup(Sender: TObject);
var
surapp: boolean;
begin
  with Mouse.CursorPos do surapp:= MouseToEltSel(X, Y) >= 0;
  MiEditer.Enabled:= surapp;
  MiRetirer.Enabled:= surapp;
  PopUp:= true;
end;

//drag-drop interne à l'appli (déplacement d'icones)

procedure TFMDW11.PBxDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
var
ixdrop,i,n: integer;
begin
  if AppSelDrag.AppliGroupe then begin //on n'accepte que sur un autre groupe ou en fin
    ixdrop:= MouseToEltPos(X, Y); //-1 = en fin
    Accept := (ixdrop < 0) OR Applis[ixdrop].AppliGroupe;
  end
  else Accept:= Source is TDragAppli;
end;

procedure TFMDW11.PBxDragDrop(Sender, Source: TObject; X, Y: Integer);
var
ixdrop,i,n,hap: integer;
apps: ArrayOfPointer;
App: TAppli;
begin
  FreeAndNil(DApp.IL);
//  DApp.Free;
  ixdrop:= MouseToEltPos(X, Y);
  //si i < 0, on est au-delà du dernier élément
  //sinon (i>=0), on insère à la place, en i
  //comme on supprime la ligne avant d'insérer, si la ligne supprimée est avant, il faut décrémenter i
  //AppSelDrag est l'élément à déplacer
  if IxSel = ixdrop then exit;//rien ne change
  n:= 1;
  if AppIcoSel = nil then begin // on déplace un groupe
  //chercher le nb d'éléments
    hap:= High(Applis);
    for i:= IxSel + 1 to hap do begin
      if Applis[i].AppliGroupe then break;
      inc(n);
    end;
  end;
  if ixdrop < 0 then ixdrop:= Length(Applis);//en fin, le seul cas possible de <0
  if ixdrop > IxSel then dec(ixdrop, n);  //recale l'arrivée
  SetLength(apps, n);
  Move( Applis[IxSel], apps[0], n * sizeof(pointer) ); //préserve
  Move( Applis[IxSel + n], Applis[IxSel], (Length(Applis) - (IxSel + n)) * sizeof(pointer) );//compacte
  Move( Applis[ixdrop], Applis[ixdrop + n], (Length(Applis) - ixdrop - n) * sizeof(pointer) );//crée la place
  Move( apps[0], Applis[ixdrop], n * sizeof(pointer) );
  Deselectionne;
  SaveData;
  PBx.Repaint;
end;

(*procedure TFMDW11.WMDropFiles(var Msg: TMessage); //message WM_DROPFILES;
var
hDrop: THandle;
FileCount,
sz,i: integer;
buf: array[0..MAX_PATH+1] of Char;
path,params,dir,nom: string;

begin
  hDrop:= Msg.wParam;
  FileCount:= DragQueryFile (hDrop , $FFFFFFFF, nil, 0);
  if FileCount > 1 then begin
    ShowMessage('les fichiers doivent être déposés un par un');
  end else begin
    sz:= DragQueryFile(hDrop, 0, nil, 0) + 1;
    DragQueryFile(hDrop, 0, @buf[0], sz);
    path:= buf;
    params:= ''; dir:= ''; nom:= '';
    if FEdRacc.executer(path, params, dir, nom, WidthFen)
      then AddApp(path, params, dir, nom);
  end;
  DragFinish(hDrop);
  Clipboard.Clear;
end;   *)

function CreateLink(pathS,pathD:string):boolean;
var
ISL: IShellLink;
IPF: IPersistFile;
gIPF: TGUID;
Hr: HRESULT;
begin
  result:= false;
  // Get a pointer to the IShellLink interface.
  Hr:= CoCreateInstance(CLSID_ShellLink, NIL, CLSCTX_INPROC_SERVER, IID_IShellLinkW, ISL);
  if Succeeded(Hr) then begin
    // Set the path to the shortcut target, and
    ISL.SetPath( PChar(pathS) );
    // add the description.
    ISL.SetDescription( PChar('raccourci vers '+ExtractFileName(pathS)) );
    ISL.SetWorkingDirectory( PChar(ExtractFileDir(pathS)) );
    // Query IShellLink for the IPersistFile interface for saving the shortcut in persistent storage.
    gIPF:= StringToGUID('{0000010B-0000-0000-C000-000000000046}');
    Hr:= ISL.QueryInterface(gIPF , IPF);
    if Succeeded(Hr) then begin
      pathD:= ChangeFileExt(pathD,'.lnk');
      // Ensure that the string is ANSI.
//      SetLength(buf,MAX_PATH+1);
//      MultiByteToWideChar(CP_ACP, 0, PChar(pathD), -1, PWideChar(buf), MAX_PATH);
      // Save the link by calling IPersistFile::Save.
      Hr:=IPF.Save( PChar(pathD) , TRUE);
      result:= true;
    end;
  end;
end;

function TFMDW11.AutoInstall:boolean;
var
Reg: TRegistry;
Pwc: PWideChar;
pfS,pfL: string;
vers: integer;
begin
  result:= false;

  Reg:= TRegistry.Create(KEY_ALL_ACCESS);
  try
    Reg.RootKey:= HKEY_CURRENT_USER;

    if (NOT Reg.KeyExists(k_regkeyapp)) then begin
      if MessageDlg('Menu Démarrer pour Windows11 (MDW11) va être installé ;'+k_CRLF+
                    ' pour cela, le programme doit avoir été lancé en tant qu''administrateur.'+k_CRLF+
                    'Continuer?',
                    mtConfirmation, mbYesNo, 0) <> mrYes then exit;
      while NOT Reg.OpenKey(k_regkeyapp, true) do //crée la clé
        if MessageDlg('Impossible d''accéder au registre de windows ; réessayer?',
                      mtConfirmation, mbYesNo, 0) <> mrYes then exit;
      Reg.WriteString( 'data', k_datadefaut);
      Reg.WriteInteger('version', k_versprgact);
    end else begin //vérifier si maj
      Reg.OpenKey(k_regkeyapp, false);
      vers:= Reg.ReadInteger('version');
      if vers = k_versprgact then begin  //inchangé
        result:= true;
        exit;
      end;
    end;
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
  try
    result:= true;
    //ranger le fichier exe
      ShGetKnownFolderPath(StringToGUID('{6D809377-6AF0-444b-8957-A3773F02200E}'), 0, 0, Pwc); //FOLDERID_ProgramFilesX64
      pfS:= Pwc + '\MDW11\MDW11.exe';
      //faire de la place pour le nouveau
      ShDelete(pfS + '.old');
      ShRename(pfS, pfS + '.old');
      //copier le nouveau
      if ShellErr( ShCopy(ParamStr(0), pfS) ) then exit;
    //créer un raccourci
      if MessageDlg('Démarrer automatiquement (sinon, MDW11 créera un raccourci sur le bureau)?',
                    mtConfirmation, mbYesNo, 0) = mrYes then begin //auto
        ShGetKnownFolderPath( StringToGUID('{B97D20BB-F46A-4C97-BA10-5E3608430854}'), 0, 0, Pwc); //FOLDERID_Startup
        pfL:= Pwc + '\MDW11.lnk';
        if CreateLink(pfS, pfL) then exit;
        ShowMessage('Accès refusé au Menu Démarrer, rangement sur le bureau');
      end;
      //bureau
      ShGetKnownFolderPath( StringToGUID('{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}'), 0, 0, Pwc); //FOLDERID_Desktop
      pfL:= Pwc^ + '\MDW11.lnk';
      ShowMessage('Création d''un raccourci sur le bureau');
      if CreateLink(pfS, pfL) then exit;
      ShowMessage('Création refusée');
  except
    on E:exception do ShowMessage('erreur : ' + E.Message);
  end;
  result:= false;
end;

(*procedure TFMDW11.Desinstaller;
//s'exécute avec les privilèges utilisateur
var
Reg: TRegistry;
ok: boolean;
Pwc: PWideChar;
pfS,pfL: string;
begin
  if MessageDlg('Menu Démarrer pour Windows11 (MDW11) va être désinstallé ;'+k_CRLF+
                ' pour cela, le programme doit être lancé en tant qu''administrateur.'+k_CRLF+
                'Continuer?',
                mtConfirmation, mbYesNo, 0) <> mrYes then exit;
//supprime le fichier
  ShGetKnownFolderPath(StringToGUID('{6D809377-6AF0-444b-8957-A3773F02200E}'), 0, 0, Pwc); //FOLDERID_ProgramFilesX64
  pfS:= Pwc + '\MDW11';
  if NOT ShellErr( ShDelete( pfS ) ) then exit;//erreur, abandon
//vide le registre
  Reg:= TRegistry.Create(KEY_ALL_ACCESS);
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if (Reg.KeyExists(k_regkeyapp)) then Reg.DeleteKey(k_regkeyapp);
  finally
    Reg.Free;
  end;
//supprime le raccourci
  ShGetKnownFolderPath( StringToGUID('{B97D20BB-F46A-4C97-BA10-5E3608430854}'), 0, 0, Pwc); //FOLDERID_Startup
  pfL:= Pwc + '\MDW11.lnk';
  DeleteFile(pfL);
  ShGetKnownFolderPath( StringToGUID('{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}'), 0, 0, Pwc); //FOLDERID_Desktop
  pfL:= Pwc^ + '\MDW11.lnk';
  DeleteFile(pfL);
  halt;
end;      *)

end.
