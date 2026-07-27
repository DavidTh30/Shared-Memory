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
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, windows,
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
  myString: String;
begin

  SetLastError(0);

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

  StrCopy(pBuf, PChar(RandomString(20)));


  if pBuf <> nil then
  begin
    myString := String(pBuf);
    //_tprintf('Sender PID: '+ pBuf^.ProcessID);
    //_tprintf('Message: '+ pBuf^.Message);
    Label1.Caption:='String: '+String(pBuf);
  end;

  Done := false;
end;

procedure TForm1.OnIdleEnd(Sender: TObject);
begin
  // OnIdleEnd run when OnIdle  Done := true;
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

constructor TForm1.Create(TheOwner: TComponent);
var
  myString: String;
begin
inherited Create(TheOwner);
  Memo_:=Memo1;
  Application.OnIdle := @OnIdle;
  Application.OnIdleEnd:=@OnIdleEnd;

  SetLastError(0);

  hMapFile := OpenFileMapping(
    FILE_MAP_ALL_ACCESS,    // read/write access
    FALSE,                 // do not inherit the name
    szName               // name of mapping object
  );

  if hMapFile = 0 then
  begin
    //Writeln('Could not open file mapping object Error: ', GetLastError);
    _tprintf('Could not open file mapping object Error: '+ SysErrorMessage(GetLastError));
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

  if pBuf <> nil then
  begin
    myString := String(pBuf);
    //showmessage('Sender PID: '+ pBuf^.ProcessID);
    //showmessage('Message: '+ pBuf^.Message);
    _tprintf('Message: '+myString);

    //_tprintf('Sender PID: '+ pBuf^.ProcessID);
    //_tprintf('Message: '+ pBuf^.Message);
  end;
end;


end.

