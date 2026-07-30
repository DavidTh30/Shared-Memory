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
  CMapName = 'Global//StringDebug01'; // Any unique name

var
  Memo_: TMemo;
  hMapFile: THandle;
  pBuf: PChar;

implementation

procedure _tprintf(s:string);
begin
  Memo_.Append(s);
  if Memo_.Lines.Count > 20 then Memo_.Lines.Delete(0);
end;

procedure _tprintf2(s:string);
begin
  SetLastError(0);
  if hMapFile = 0 then
  begin
    hMapFile := OpenFileMapping(
      FILE_MAP_ALL_ACCESS,    // read/write access
      FALSE,                 // do not inherit the name
      CMapName               // name of mapping object
    );

    if hMapFile = 0 then
    begin
      _tprintf('Could not open file mapping object Error: '+ SysErrorMessage(GetLastError));
      Exit;
    end;
    if hMapFile <> 0 then
    begin
      pBuf := PChar(MapViewOfFile(
        hMapFile,            // Handle to map object
        FILE_MAP_ALL_ACCESS, // Read/write permission
        0,
        0,
        MEMORY_SIZE
      ));

      if pBuf = nil then
      begin
        _tprintf('Could not map view of file. Error: '+ SysErrorMessage(GetLastError));
        CloseHandle(hMapFile);
        Exit;
      end;
    end;
  end;

  if pBuf <> nil then
  begin
    UnmapViewOfFile(pBuf);
  end;

  pBuf := PChar(MapViewOfFile(
    hMapFile,            // Handle to map object
    FILE_MAP_ALL_ACCESS, // Read/write permission
    0,
    0,
    MEMORY_SIZE
  ));

  if pBuf = nil then
  begin
    _tprintf('Could not map view of file. Error: '+ SysErrorMessage(GetLastError));
    CloseHandle(hMapFile);
    Exit;
  end;

  StrCopy(pBuf, PChar(s));
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

