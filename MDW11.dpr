program MDW11;

uses
  Vcl.Forms,
  UMDW11 in 'UMDW11.pas' {FMDW11},
  UMDW11PRMS in 'UMDW11PRMS.pas' {FMDW11PRMS},
  UEdRacc in 'UEdRacc.pas' {FEdRacc};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskBar:= false;
  Application.CreateForm(TFMDW11, FMDW11);
  Application.CreateForm(TFMDW11PRMS, FMDW11PRMS);
  Application.CreateForm(TFEdRacc, FEdRacc);
  Application.Run;
end.
