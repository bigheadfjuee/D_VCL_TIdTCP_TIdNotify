unit uClient;

interface

// IdGlobal =>  用到 TIdBytes, RawToBytes
//
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdContext,
  IdCustomTCPServer, IdTCPServer, IdGlobal, IdException, Vcl.ExtCtrls,
  UnitGlobal,
  uThread;

type
  TFormClient = class(TForm)
    BtnSendStruct: TButton;
    IdTCPClient1: TIdTCPClient;
    BtnSendTString: TButton;
    BtnSendUTF8: TButton;
    Memo1: TMemo;
    tmrAutoConnect: TTimer;
    BtnStart: TButton;
    BtnStop: TButton;
    edtHost: TLabeledEdit;
    edtPort: TLabeledEdit;
    BtnClearMemo: TButton;
    tmReadLn: TTimer;
    edtMsg: TEdit;
    btnDiscon: TButton;
    btnASCII: TButton;
    procedure BtnSendStructClick(Sender: TObject);
    procedure BtnSendTStringClick(Sender: TObject);
    procedure BtnSendUTF8Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tmrAutoConnectTimer(Sender: TObject);
    procedure IdTCPClient1Connected(Sender: TObject);
    procedure BtnStopClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure IdTCPClient1AfterBind(Sender: TObject);
    procedure IdTCPClient1BeforeBind(Sender: TObject);
    procedure IdTCPClient1Disconnected(Sender: TObject);
    procedure IdTCPClient1SocketAllocated(Sender: TObject);
    procedure IdTCPClient1Status(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure IdTCPClient1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure IdTCPClient1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure IdTCPClient1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure BtnClearMemoClick(Sender: TObject);
    procedure tmReadLnTimer(Sender: TObject);
    procedure btnDisconClick(Sender: TObject);
    procedure edtMsgKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnASCIIClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    thread: TReadThread;
    procedure InitConnectGUI(init: Boolean);
    procedure EnableSendBtn(enable: Boolean);
  public
    { Public declarations }
    procedure ParseCmd(cmd: String);
  end;

var
  FormClient: TFormClient;
  SendData: TMyData;

implementation

{$R *.dfm}

procedure TFormClient.FormCreate(Sender: TObject);
begin
  // 先使用 IdTCPClient1 中的設定值
  edtHost.Text := IdTCPClient1.Host;
  edtPort.Text := IntToStr(IdTCPClient1.Port);

  InitConnectGUI(True);
  EnableSendBtn(False);

end;

procedure TFormClient.FormShow(Sender: TObject);
begin
  // 執行後自動連線
  BtnStartClick(Sender);
end;

procedure TFormClient.IdTCPClient1AfterBind(Sender: TObject);
begin
  Memo1.Lines.Add('C-AfterBind');
end;

procedure TFormClient.IdTCPClient1BeforeBind(Sender: TObject);
begin
  Memo1.Lines.Add('C-BeforeBind');
end;

procedure TFormClient.IdTCPClient1Connected(Sender: TObject);
begin
  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('C-Connected');

  BtnStop.Enabled := False;
  EnableSendBtn(True);

  // 用 thread 的方法
  thread := TReadThread.Create;
  thread.IdTCPClient := IdTCPClient1;
  thread.FreeOnTerminate := True;

  // 用 timer 的方法，會影響 mian thread
  // tmReadLn.Enabled := True;
end;

procedure TFormClient.IdTCPClient1Disconnected(Sender: TObject);
begin
  tmReadLn.Enabled := False;
  thread.Terminate;
  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('C-Disconnected');
end;

procedure TFormClient.IdTCPClient1SocketAllocated(Sender: TObject);
begin
  Memo1.Lines.Add('C-SocketAllocated');
end;

procedure TFormClient.IdTCPClient1Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin
  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('C-Status: ' + AStatusText);
end;

procedure TFormClient.IdTCPClient1Work(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  // 這邊會一直 run
  // Memo1.Lines.Add('C-Client1Work');
end;

procedure TFormClient.IdTCPClient1WorkBegin(ASender: TObject;
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  Memo1.Lines.Add('C-WorkBegin');
end;

procedure TFormClient.IdTCPClient1WorkEnd(ASender: TObject;
  AWorkMode: TWorkMode);
begin
  Memo1.Lines.Add('C-WorkEnd');
end;

procedure TFormClient.tmrAutoConnectTimer(Sender: TObject);
begin
  if not IdTCPClient1.Connected then
  begin
    Memo1.Lines.Add('Timer1每5秒自動連線中…');
    try
      IdTCPClient1.Connect;
    except
      on E: EIdException do
        Memo1.Lines.Add('== EIdException: ' + E.Message);
    end;
  end
  else
  begin
    tmrAutoConnect.Enabled := False;
    Memo1.Lines.Add('自動連線已連上，關閉tmrAutoConnect');
  end;
end;

// 只是比較用，實際使用時，用 thread 比較好
procedure TFormClient.tmReadLnTimer(Sender: TObject);
var
  S: String;
begin

  try
    if IdTCPClient1.IOHandler.InputBufferIsEmpty then
      IdTCPClient1.IOHandler.CheckForDataOnSource(0);
    while not IdTCPClient1.IOHandler.InputBufferIsEmpty do
    begin
      S := IdTCPClient1.IOHandler.ReadLn(IndyTextEncoding_UTF8);
      Memo1.Lines.Add(S);
    end;
  except
    on E: EIdException do
      IdTCPClient1.Disconnect;
  end;

end;

procedure TFormClient.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if IdTCPClient1.Connected then
  begin
    try
      IdTCPClient1.Disconnect;
    except
      on E: EIdException do
        ShowMessage('EIdException: ' + E.Message);
    end;
  end;

end;

procedure TFormClient.btnASCIIClick(Sender: TObject);
begin
  if not IdTCPClient1.Connected then
  begin
    Memo1.Lines.Add('IdTCPClient 已斷線');
    Exit;
  end;

  IdTCPClient1.IOHandler.WriteLn(edtMsg.Text, IndyTextEncoding_ASCII);
end;

procedure TFormClient.BtnClearMemoClick(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TFormClient.btnDisconClick(Sender: TObject);
begin
  IdTCPClient1.Disconnect;
  InitConnectGUI(False);
  EnableSendBtn(False);
end;

procedure TFormClient.BtnSendStructClick(Sender: TObject);
begin

  if not IdTCPClient1.Connected then
  begin
    Memo1.Lines.Add('IdTCPClient 已斷線');
    Exit;
  end;

  SendData.ID := 10;
  StrPCopy(SendData.Name, 'Roger');
  StrPCopy(SendData.Sex, '男');
  SendData.Age := 25;
  StrPCopy(SendData.Address, '高雄市');
  SendData.UpdateTime := Now;

  IdTCPClient1.IOHandler.Write(MY_CMD_STRUCT);
  // 把自訂的型態用 RawToBytes 送出
  IdTCPClient1.IOHandler.Write(RawToBytes(SendData, SizeOf(SendData)));
end;

procedure TFormClient.BtnSendTStringClick(Sender: TObject);
var
  sList: TStrings;
  I: Integer;
begin

  if not IdTCPClient1.Connected then
  begin
    Memo1.Lines.Add('IdTCPClient 已斷線');
    Exit;
  end;

  sList := TStringList.Create;
  for I := 0 to 30 do
  begin
    sList.Add('數據index' + IntToStr(I));
  end;
  IdTCPClient1.IOHandler.Write(MY_CMD_TSTRING);
  IdTCPClient1.IOHandler.Write(sList.Count);
  IdTCPClient1.IOHandler.Write(ToBytes(sList.Text, IndyTextEncoding_UTF8));
end;

procedure TFormClient.BtnSendUTF8Click(Sender: TObject);
begin

  if not IdTCPClient1.Connected then
  begin
    Memo1.Lines.Add('IdTCPClient 已斷線');
    Exit;
  end;

  IdTCPClient1.IOHandler.Write(MY_CMD_UTF8);
  // 中文要指定編碼，接收時也要進行相應的轉換，否則中文會顯示成?號
  IdTCPClient1.IOHandler.WriteLn(edtMsg.Text, IndyTextEncoding_UTF8);
end;

procedure TFormClient.BtnStartClick(Sender: TObject);
begin
  IdTCPClient1.Host := edtHost.Text;
  IdTCPClient1.Port := StrToInt(edtPort.Text);

  Memo1.Lines.Add('tmrAutoConnect已啟動，稍待 ' + FloatToStr(tmrAutoConnect.Interval /
    1000) + ' 秒');

  InitConnectGUI(True);
end;

procedure TFormClient.BtnStopClick(Sender: TObject);
begin
  InitConnectGUI(False);
end;

procedure TFormClient.edtMsgKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = vk_Return then
    BtnSendUTF8Click(Sender);
end;

procedure TFormClient.ParseCmd(cmd: String);
begin
  Memo1.Lines.Add(cmd);
end;

procedure TFormClient.InitConnectGUI(init: Boolean);
begin
  tmrAutoConnect.Enabled := init;
  BtnStart.Enabled := not init;
  BtnStop.Enabled := init;
  btnDiscon.Enabled := init;
end;

procedure TFormClient.EnableSendBtn(enable: Boolean);
begin
  BtnSendStruct.Enabled := enable;
  BtnSendTString.Enabled := enable;
  BtnSendUTF8.Enabled := enable;
  btnASCII.Enabled := enable;
end;

end.
