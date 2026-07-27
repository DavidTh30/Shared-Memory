unit Unit2;

{$mode ObjFPC}{$H+}
{$LONGSTRINGS ON}

interface

uses
  Classes, SysUtils, StdCtrls, Windows;

procedure _tprintf(s:string);
function RandomString(Size: Integer): String;

type
  //{$ScopedEnum On}
  TChars = (
    a, c, g, t
  );

  ch_array = array[TChars] of 1..4;

const
  BUF_SIZE = 256;
  MEMORY_SIZE = 1024; // 1 KB
  MAP_NAME = 'MySharedMemoryObject';
  szName  = 'Global//MyFileMappingObject';
  // Can't use 'Global\\MyFileMappingObject'
  //szName  = 'Global\\MyFileMappingObject';

  //{$MACRO ON}
  //{$DEFINE BUF_SIZE := 256}
  CMapName = '{9D809F6B-FC10-4E4F-B352-4A7773762BAA}'; // Any unique name

var
  ca: ch_array;
  //Can't use Dynamic array of char
  //szName: array of TCHAR = ('G','l','o','b','a','l','\','\','M','Y');//TEXT("Global\\MyFileMappingObject");
  szMsg: array of TCHAR = ('M','e','s','s','a','g','e',' ','f','r'); //TEXT("Message from first process.");
  Memo_: TMemo;
  hMapFile: THandle;
  pBuf: PChar;

implementation

procedure _tprintf(s:string);
begin
  Memo_.Append(s);
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

