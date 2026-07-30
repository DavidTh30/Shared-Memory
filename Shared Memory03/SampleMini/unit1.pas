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
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
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
begin


  Done := false;
end;

procedure TForm1.OnIdleEnd(Sender: TObject);
begin
  // OnIdleEnd run when OnIdle  Done := true;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Memo_ <> nil then
  begin
    Memo_.Free;
    Memo_:=nil;
  end;

  if pBuf <> nil then
  begin
    UnmapViewOfFile(pBuf);
  end;
  if hMapFile <> 0 then
  begin
    CloseHandle(hMapFile);
    hMapFile := 0;
  end;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  _tprintf2(RandomString(20));
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  _tprintf2('clear');
end;

constructor TForm1.Create(TheOwner: TComponent);
begin
inherited Create(TheOwner);

  Memo_:= Tmemo.Create(self);

  Application.OnIdle := @OnIdle;
  Application.OnIdleEnd:=@OnIdleEnd;

  SetLastError(0);

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


end.

