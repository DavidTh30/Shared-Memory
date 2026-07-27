unit Unit1;

{$mode objfpc}{$H+}

interface

//HANDLE CreateFileMappingA(
//  [in]           HANDLE                hFile,
//  [in, optional] LPSECURITY_ATTRIBUTES lpFileMappingAttributes,
//  [in]           DWORD                 flProtect,
//  [in]           DWORD                 dwMaximumSizeHigh,
//  [in]           DWORD                 dwMaximumSizeLow,
//  [in, optional] LPCSTR                lpName
//);

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Windows,
  Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    Label1: TLabel;
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private

  public
    procedure OnIdle(Sender: TObject; var Done: boolean);
    procedure OnIdleEnd(Sender: TObject);
    constructor Create(TheOwner: TComponent);  override;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.OnIdle(Sender: TObject; var Done: boolean);
var
  MyPWideChar: PWideChar;
begin
  //SetLastError(0);
  //
  //if pBuf <> nil then
  //begin
  //  UnmapViewOfFile(pBuf);
  //  //SetPointer(nil, 0); //For only TPageFileStream class
  //end;
  //
  //pBuf := PChar(MapViewOfFile(
  //  hMapFile,            // Handle to map object
  //  FILE_MAP_ALL_ACCESS, // Read/write permission
  //  0,
  //  0,
  //  MEMORY_SIZE
  //));
  //
  //if pBuf = nil then
  //begin
  //  //Writeln('Could not map view of file. Error: ', GetLastError);
  //  _tprintf('Could not map view of file. Error: '+ SysErrorMessage(GetLastError));
  //  CloseHandle(hMapFile);
  //  Exit;
  //end;
  //
  //MyPWideChar := PWideChar(RandomString(20)); // Direct typecast
  //StrCopy(pBuf, PChar(RandomString(20)));

  if pBuf <> nil then
  begin
    Label1.Caption:='String: '+String(pBuf);
  end;

  Done := false;
end;

procedure TForm1.OnIdleEnd(Sender: TObject);
begin
  // OnIdleEnd run when OnIdle  Done := true;
end;

constructor TForm1.Create(TheOwner: TComponent);
var
  myString: String;
begin
inherited Create(TheOwner);
  Memo_:=Memo1;
  Application.OnIdle := @OnIdle;
  Application.OnIdleEnd:=@OnIdleEnd;


  ca[TChars.a] := 3;
  SetLastError(0);

   hMapFile := CreateFileMapping(
    INVALID_HANDLE_VALUE, // Use paging file instead of an actual file
    nil,                  // Default security
    PAGE_READWRITE,       // Read/write access
    0,                    // Maximum object size (high-order DWORD)
    MEMORY_SIZE,          // Maximum object size (low-order DWORD)
    szName              // Name of mapping object
  );

  if hMapFile = 0 then
  begin
    _tprintf('Could not create file mapping object. Error: '+ SysErrorMessage(GetLastError));
    Exit;
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
    //Writeln('Could not map view of file. Error: ', GetLastError);
    _tprintf('Could not map view of file. Error: '+ SysErrorMessage(GetLastError));
    CloseHandle(hMapFile);
    Exit;
  end;

  StrCopy(pBuf, 'Hello from first process file mapping!');

  myString := String(pBuf);
  _tprintf('Message: '+myString);
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if pBuf <> nil then
  begin
    UnmapViewOfFile(pBuf);
    //SetPointer(nil, 0); //For only TPageFileStream class
  end;
  if hMapFile <> 0 then
  begin
    CloseHandle(hMapFile);
    hMapFile := 0;
  end;

  //_tprintf('Execution completed successfully.');

end;

end.

