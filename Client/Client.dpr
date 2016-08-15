program Client;

uses
  Vcl.Forms,
  uClient in 'uClient.pas' {FormClient},
  UnitGlobal in '..\UnitGlobal.pas',
  uThread in 'uThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormClient, FormClient);
  Application.Run;
end.
