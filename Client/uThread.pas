unit uThread;

interface

uses
  System.Classes, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdGlobal, System.SysUtils, IdException;

type
  TReadThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  public
    IdTCPClient: TIdTCPClient;
    msg: String;
    procedure UpdateData;
  end;

implementation

uses uClient;

procedure TReadThread.Execute;
begin

  while not Terminated do

  begin
    if IdTCPClient.Connected then
    begin

      try
        if IdTCPClient.IOHandler.InputBufferIsEmpty then
          IdTCPClient.IOHandler.CheckForDataOnSource(0);

        while not IdTCPClient.IOHandler.InputBufferIsEmpty do
        begin
          msg := IdTCPClient.IOHandler.ReadLn(IndyTextEncoding_UTF8);
          Synchronize(UpdateData); // 視覺元件要用 Synchronize 才不會 hang on
        end;
      except on E: EIdException do
        ; // 例外處理
      end;

    end;

  end;
end;

procedure TReadThread.UpdateData;
begin
  FormClient.ParseCmd(msg);
end;

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

  Synchronize(UpdateCaption);

  and UpdateCaption could look like,

  procedure TReadThread.UpdateCaption;
  begin
  Form1.Caption := 'Updated in a thread';
  end;

  or

  Synchronize(
  procedure
  begin
  Form1.Caption := 'Updated in thread via an anonymous method'
  end
  )
  );

  where an anonymous method is passed.

  Similarly, the developer can call the Queue method with similar parameters as
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.
}
end.
