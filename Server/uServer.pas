unit uServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdContext, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, Vcl.StdCtrls, IdGlobal, IdException,
  IdSocketHandle, IdThread, IdSync,
  Vcl.ExtCtrls, UnitGlobal;

type
  TMyIdNotify = class(TIdNotify)
  protected
    procedure DoNotify; override;
  public
    mMyData: TMyData;
    isMyData: Boolean;
    strMsg: String;
  end;

type
  TFormServer = class(TForm)
    Memo1: TMemo;
    BtnStart: TButton;
    BtnStop: TButton;
    BtnBroadcast: TButton;
    IdTCPServer1: TIdTCPServer;
    LedtPort: TLabeledEdit;
    ListBoxClient: TListBox;
    edtSend: TEdit;
    btnSend: TButton;
    btnClearMemo: TButton;
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure BtnStartClick(Sender: TObject);
    procedure BtnStopClick(Sender: TObject);
    procedure IdTCPServer1AfterBind(Sender: TObject);
    procedure IdTCPServer1BeforeBind(AHandle: TIdSocketHandle);
    procedure IdTCPServer1BeforeListenerRun(AThread: TIdThread);
    procedure IdTCPServer1Connect(AContext: TIdContext);
    procedure IdTCPServer1ContextCreated(AContext: TIdContext);
    procedure IdTCPServer1Disconnect(AContext: TIdContext);
    procedure IdTCPServer1Exception(AContext: TIdContext;
      AException: Exception);
    procedure IdTCPServer1ListenException(AThread: TIdListenerThread;
      AException: Exception);
    procedure IdTCPServer1Status(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure BtnBroadcastClick(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure btnClearMemoClick(Sender: TObject);
    procedure edtSendKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure SendMessage;
    procedure Multi_cast;

    { Private declarations }
  public
    { Public declarations }
    procedure StopServer;
  end;

  // --------------------------------------------
type
  TMyContext = class(TIdContext)
  public
    UserName: String;
    Password: String;
  end;

var
  FormServer: TFormServer;

implementation

{$R *.dfm}

procedure TFormServer.BtnBroadcastClick(Sender: TObject);
begin
  Multi_cast;
end;

procedure TFormServer.btnClearMemoClick(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TFormServer.btnSendClick(Sender: TObject);
var
  str: TStringBuilder;
begin
  SendMessage;
end;

procedure TFormServer.BtnStartClick(Sender: TObject);
var
  str: String;
begin
  IdTCPServer1.Bindings.DefaultPort := StrToInt(LedtPort.Text);
  Memo1.Lines.Add('IdTCPServer.Bindings.DefaultPort' + LedtPort.Text);

  try
    IdTCPServer1.Active := True;
    Memo1.Lines.Add('IdTCPServer1.Active := True;');
  except
    on E: EIdException do
      Memo1.Lines.Add('== EIdException: ' + E.Message);
  end;

  BtnStop.Enabled := True;
  BtnStart.Enabled := False;
end;

procedure TFormServer.BtnStopClick(Sender: TObject);
begin
  StopServer;
  BtnStart.Enabled := True;
  BtnStop.Enabled := False;
end;

procedure TFormServer.edtSendKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    Multi_cast;
end;

procedure TFormServer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  StopServer;
end;

procedure TFormServer.SendMessage;
var
  List: TList;
  str: TStringBuilder;
begin

  if ListBoxClient.ItemIndex = -1 then
  begin
    Memo1.Lines.Add('�п�ܤ@�� Client');
  end
  else
  begin

    try
      List := IdTCPServer1.Contexts.LockList;
      if List.Count = 0 then
      begin
        exit;
      end;
      TIdContext(List[ListBoxClient.ItemIndex]).Connection.IOHandler.WriteLn
        (edtSend.Text, IndyTextEncoding_UTF8);
    finally
      IdTCPServer1.Contexts.UnlockList;
    end;

    str := TStringBuilder.Create;
    str.Append('SendMessage(');
    str.Append(ListBoxClient.Items[ListBoxClient.ItemIndex]);
    str.Append('): ');
    str.Append(edtSend.Text);
    Memo1.Lines.Add(str.ToString);
    str.DisposeOf;
  end;

end;

procedure TFormServer.Multi_cast;
var
  List: TList;
  I: Integer;
begin
  List := IdTCPServer1.Contexts.LockList;
  try
    if List.Count = 0 then
    begin
      Memo1.Lines.Add('�S��Client�s�u�I');
      exit;
    end
    else
      Memo1.Lines.Add('Multi_cast:' + edtSend.Text);

    for I := 0 to List.Count - 1 do
    begin
      try
        TIdContext(List[I]).Connection.IOHandler.WriteLn(edtSend.Text,
          IndyTextEncoding_UTF8);

      except
        on E: EIdException do
          Memo1.Lines.Add('== EIdException: ' + E.Message);
      end;
    end;

  finally
    IdTCPServer1.Contexts.UnlockList;
  end;

end;

procedure TFormServer.IdTCPServer1AfterBind(Sender: TObject);
begin
  Memo1.Lines.Add('S-AfterBind');
end;

procedure TFormServer.IdTCPServer1BeforeBind(AHandle: TIdSocketHandle);
begin
  Memo1.Lines.Add('S-BeforeBind');
end;

procedure TFormServer.IdTCPServer1BeforeListenerRun(AThread: TIdThread);
begin
  Memo1.Lines.Add('S-BeforeListenerRun');
end;

procedure TFormServer.IdTCPServer1Connect(AContext: TIdContext);
var
  str: String;
begin
  str := AContext.Binding.PeerIP + '_' + AContext.Binding.PeerPort.ToString;
  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('S-Connect: ' + str);

  ListBoxClient.Items.Add(str);
  // �۰ʿ�̫ܳ�s�W��
  if ListBoxClient.Count > -1 then
    ListBoxClient.ItemIndex := ListBoxClient.Count - 1;
end;

procedure TFormServer.IdTCPServer1ContextCreated(AContext: TIdContext);
var
  str: String;
begin
  str := AContext.Binding.PeerIP + '_' + AContext.Binding.PeerPort.ToString;
  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('S-ContextCreated ' + str);
end;

procedure TFormServer.IdTCPServer1Disconnect(AContext: TIdContext);
var
  Index: Integer;
  str: String;
begin
  str := AContext.Binding.PeerIP + '_' + AContext.Binding.PeerPort.ToString;

  Index := ListBoxClient.Items.IndexOf(str);
  ListBoxClient.Items.Delete(index);

  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('S-Disconnect: ' + str);
end;

procedure TFormServer.IdTCPServer1Exception(AContext: TIdContext;
  AException: Exception);
var
  str: String;
begin
  str := AContext.Binding.PeerIP + '_' + AContext.Binding.PeerPort.ToString;
  Memo1.Lines.Add('IdTCPServer1Exception: ' + str);
  Memo1.Lines.Add('S-Exception:' + AException.Message);
end;

procedure TMyIdNotify.DoNotify;
begin
  if isMyData then
  begin
    with FormServer.Memo1.Lines do
    begin
      Add('ID:' + Inttostr(mMyData.Id));
      Add('Name:' + StrPas(mMyData.Name));
      Add('Sex:' + mMyData.sex);
      Add('Age:' + Inttostr(mMyData.age));
      Add('UpdateTime:' + DateTimeToStr(mMyData.UpdateTime));
    end;
  end
  else
  begin
    FormServer.Memo1.Lines.Add(strMsg);
  end;

end;

// ���󤺫ت� thread �H
procedure TFormServer.IdTCPServer1Execute(AContext: TIdContext);
var
  ReadData: TMyData;
  buf: TIdBytes;
  sCmd: Char;
  sList: TStrings;
  I, ListCount: Integer;
  size: Integer;
  str: String;
  WasSplit: Boolean;
begin

  // �r Z ����O�����Φr��
  // str := AContext.Connection.IOHandler.ReadLnSplit(WasSplit, 'Z', 5000, -1,
  // IndyTextEncoding_ASCII);

  // if not str.IsEmpty then
  // Memo1.Lines.Add(str);

  // ����Ū�@�� (�۰ʥδ���r���Ϲj)
  // Memo1.Lines.Add(AContext.Connection.IOHandler.ReadLn(IndyTextEncoding_UTF8));

  // �̦U�O�����O(�Ĥ@��char)�A�ѪR���P�����
  sCmd := AContext.Connection.IOHandler.ReadChar;

  // Tony Test
  // sCmd := #12;

  if sCmd = MY_CMD_STRUCT then // �������c��
  begin
    AContext.Connection.IOHandler.ReadBytes(buf, SizeOf(ReadData));
    BytesToRaw(buf, ReadData, SizeOf(ReadData));
    // �]�� FMX �ëD Thread safe�A�ҥH�n�� TIdNotify.Notify;
    with TMyIdNotify.Create do
    begin
      mMyData := ReadData;
      isMyData := True;
      Notify;
    end;
  end
  else if sCmd = MY_CMD_TSTRING then // ���� TStrings
  begin
    ListCount := AContext.Connection.IOHandler.ReadLongInt;
    sList := TStringList.Create;
    try
      AContext.Connection.IOHandler.ReadStrings(sList, ListCount,
        IndyTextEncoding_UTF8);
      for I := 0 to sList.Count - 1 do
      begin
        // �]�� FMX �ëD Thread safe�A�ҥH�n�� TIdNotify.Notify;
        with TMyIdNotify.Create do
        begin
          strMsg := sList.Strings[I];
          isMyData := False;
          Notify;
        end;

      end;
    finally
      sList.Free;
    end;
  end
  else if sCmd = MY_CMD_UTF8 then // ���� UFT8�r��
  begin
    with TMyIdNotify.Create do
    begin
      strMsg := AContext.Connection.IOHandler.ReadLn(IndyTextEncoding_UTF8);
      isMyData := False;
      Notify;
    end;;
    // echo
    AContext.Connection.IOHandler.WriteLn('����UTF8 : ', IndyTextEncoding_UTF8);
  end
  else
  begin // �䥦���N��@ ASCII ����r
    with TMyIdNotify.Create do
    begin
      strMsg := sCmd + AContext.Connection.IOHandler.ReadLn
        (IndyTextEncoding_ASCII);
      isMyData := False;
      Notify;
    end;;
  end;

  AContext.Connection.IOHandler.InputBuffer.Clear; // �M�������ѧO���R�O
end;

procedure TFormServer.IdTCPServer1ListenException(AThread: TIdListenerThread;
  AException: Exception);
begin
  Memo1.Lines.Add('S-ListenException: ' + AException.Message);
end;

procedure TFormServer.IdTCPServer1Status(ASender: TObject;
  const AStatus: TIdStatus; const AStatusText: string);
begin
  Memo1.Lines.Add(DateTimeToStr(Now));
  Memo1.Lines.Add('S-Status: ' + AStatusText);
end;

procedure TFormServer.StopServer;
var
  Index: Integer;
  Context: TIdContext;
begin
  if IdTCPServer1.Active then
  begin
    IdTCPServer1.OnDisconnect := nil;
    ListBoxClient.Clear;

    with IdTCPServer1.Contexts.LockList do
    begin
      if Count > 0 then
      begin
        try
          for index := 0 to Count - 1 do
          begin
            Context := Items[index];
            if Context = nil then
              continue;
            Context.Connection.IOHandler.WriteBufferClear;
            Context.Connection.IOHandler.InputBuffer.Clear;
            Context.Connection.IOHandler.Close;

            if Context.Connection.Connected then
              Context.Connection.Disconnect;
          end;
        finally
          IdTCPServer1.Contexts.UnlockList;
        end;
      end;
    end;

    try
      IdTCPServer1.Active := False;
      Memo1.Lines.Add('IdTCPServer1.Active := False');
    except
      on E: EIdException do
        Memo1.Lines.Add('== EIdException: ' + E.Message);
    end;

  end;
  IdTCPServer1.OnDisconnect := IdTCPServer1Disconnect;
end;

end.
