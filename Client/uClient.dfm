object FormClient: TFormClient
  Left = 0
  Top = 0
  Caption = 'FormClient'
  ClientHeight = 389
  ClientWidth = 584
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Consolas'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object BtnSendStruct: TButton
    Left = 376
    Top = 176
    Width = 159
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Send Struct'
    TabOrder = 0
    OnClick = BtnSendStructClick
  end
  object BtnSendTString: TButton
    Left = 376
    Top = 200
    Width = 159
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Send TString'
    TabOrder = 1
    OnClick = BtnSendTStringClick
  end
  object BtnSendUTF8: TButton
    Left = 376
    Top = 265
    Width = 159
    Height = 32
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Send UTF8'
    TabOrder = 2
    OnClick = BtnSendUTF8Click
  end
  object Memo1: TMemo
    Left = 6
    Top = 1
    Width = 366
    Height = 376
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object BtnStart: TButton
    Left = 377
    Top = 74
    Width = 158
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #38283#22987#33258#21205#36899#32218
    TabOrder = 4
    OnClick = BtnStartClick
  end
  object BtnStop: TButton
    Left = 376
    Top = 98
    Width = 159
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #20572#27490#33258#21205#36899#32218
    TabOrder = 5
    OnClick = BtnStopClick
  end
  object edtHost: TLabeledEdit
    Left = 416
    Top = 6
    Width = 145
    Height = 25
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    EditLabel.Width = 40
    EditLabel.Height = 17
    EditLabel.Margins.Left = 2
    EditLabel.Margins.Top = 2
    EditLabel.Margins.Right = 2
    EditLabel.Margins.Bottom = 2
    EditLabel.Caption = 'Host:'
    LabelPosition = lpLeft
    TabOrder = 6
    Text = #22312'IdTCPClient'#20013
  end
  object edtPort: TLabeledEdit
    Left = 416
    Top = 34
    Width = 58
    Height = 25
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    EditLabel.Width = 40
    EditLabel.Height = 17
    EditLabel.Margins.Left = 2
    EditLabel.Margins.Top = 2
    EditLabel.Margins.Right = 2
    EditLabel.Margins.Bottom = 2
    EditLabel.Caption = 'Port:'
    LabelPosition = lpLeft
    TabOrder = 7
  end
  object BtnClearMemo: TButton
    Left = 376
    Top = 352
    Width = 159
    Height = 25
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Clear Memo'
    TabOrder = 8
    OnClick = BtnClearMemoClick
  end
  object edtMsg: TEdit
    Left = 376
    Top = 236
    Width = 159
    Height = 25
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabOrder = 9
    Text = #20320#22909#65281#12425#12376#12423#12373#12435
    OnKeyUp = edtMsgKeyUp
  end
  object btnDiscon: TButton
    Left = 376
    Top = 122
    Width = 159
    Height = 20
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #26039#32218
    TabOrder = 10
    OnClick = btnDisconClick
  end
  object btnASCII: TButton
    Left = 376
    Top = 301
    Width = 159
    Height = 29
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'Send ASCII'
    TabOrder = 11
    OnClick = btnASCIIClick
  end
  object IdTCPClient1: TIdTCPClient
    OnStatus = IdTCPClient1Status
    OnDisconnected = IdTCPClient1Disconnected
    OnWork = IdTCPClient1Work
    OnWorkBegin = IdTCPClient1WorkBegin
    OnWorkEnd = IdTCPClient1WorkEnd
    OnConnected = IdTCPClient1Connected
    ConnectTimeout = 3000
    Host = '192.168.1.181'
    IPVersion = Id_IPv4
    Port = 6667
    ReadTimeout = -1
    OnBeforeBind = IdTCPClient1BeforeBind
    OnAfterBind = IdTCPClient1AfterBind
    OnSocketAllocated = IdTCPClient1SocketAllocated
    Left = 104
    Top = 48
  end
  object tmrAutoConnect: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = tmrAutoConnectTimer
    Left = 200
    Top = 40
  end
  object tmReadLn: TTimer
    Enabled = False
    OnTimer = tmReadLnTimer
    Left = 264
    Top = 144
  end
end
