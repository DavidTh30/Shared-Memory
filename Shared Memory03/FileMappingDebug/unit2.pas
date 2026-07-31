unit Unit2;

{$mode ObjFPC}{$H+}
{$LONGSTRINGS ON}

interface

uses
  Classes, SysUtils, StdCtrls, Windows;

procedure _tprintf(s:string);
procedure _tprintf2(s:string);
function RandomString(Size: Integer): String;

type
  //{$ScopedEnum On}
  TChars = (
    a, c, g, t
  );

  ch_array = array[TChars] of 1..4;

const
  MEMORY_SIZE = 1024; // 1 KB
  CMapName = 'Global//StringDebug01';
  CMapName2 = 'Global//StringDebug02';

var
  Memo_: TMemo;
  Memo__: TMemo;
  hMapFile: THandle;
  pBuf: PChar;
  hMapFile2: THandle;
  pBuf2: PChar;
  MutexHandle: THandle;
  OldString:string;
  OldString2:string;
  {$IFDEF Windows}
  var
   StartUp: StartUpInfoA;
  {$ENDIF}

implementation

procedure _tprintf(s:string);
begin
  Memo_.Append(s);
  if ((Upcase(s)='CLEAR') or (Upcase(s)='CLEAN')) then
  begin
    Memo_.Clear;
  end;
  if Memo_.Lines.Count > 20 then Memo_.Lines.Delete(0);
end;

procedure _tprintf2(s:string);
begin
  Memo__.Append(s);
  if ((Upcase(s)='CLEAR') or (Upcase(s)='CLEAN')) then
  begin
    Memo__.Clear;
  end;
  if Memo__.Lines.Count > 20 then Memo__.Lines.Delete(0);
end;

function RandomString(Size: Integer): String;
const
  // The pool of allowed characters
  Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
var
  i, Len: Integer;
begin
  Result := '';
  Len := Length(Chars);
  SetLength(Result, Size); // Pre-allocate string memory for performance

  for i := 1 to Size do
  begin
    // Random(Len) returns 0 to Len-1. Pascal strings are 1-indexed.
    Result[i] := Chars[Random(Len) + 1];
  end;
end;

end.

