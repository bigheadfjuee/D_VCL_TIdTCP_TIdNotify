unit uMyData;
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
implementation
end.
