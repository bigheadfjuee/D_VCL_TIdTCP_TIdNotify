program Server;

uses
  Vcl.Forms,
  uServer in 'uServer.pas' {FormServer},
  UnitGlobal in '..\UnitGlobal.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormServer, FormServer);
  Application.Run;
end.
