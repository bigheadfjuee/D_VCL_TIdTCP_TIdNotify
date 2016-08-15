unit UnitGlobal;

interface
type
  TMyData = record
      ID:Integer;
      Name:Array[0..20] of Char;
      Sex:Array[0..10] of Char;
      Age:Byte;
      Address:Array[0..256] of Char;
      UpdateTime:double;
  end;
const
    MY_CMD_STRUCT  = #99;
    MY_CMD_TSTRING = #111;
    MY_CMD_UTF8    = #12;
    MY_CMD_LOGIN   = #10;

implementation

end.
