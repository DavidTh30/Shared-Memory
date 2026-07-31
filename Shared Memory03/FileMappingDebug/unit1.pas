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
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  Windows, Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
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

  if pBuf <> nil then
  begin
    if String(pBuf) <> OldString then
    begin
      OldString:=String(pBuf);
      _tprintf(OldString);
      //StrCopy(pBuf, '');
    end;
  end;

  if pBuf2 <> nil then
  begin
    if String(pBuf2) <> OldString2 then
    begin
      OldString2:=String(pBuf2);
      _tprintf2(OldString2);
      //StrCopy(pBuf2, '');
    end;
  end;

  Done := false;
end;

procedure TForm1.OnIdleEnd(Sender: TObject);
begin
  // OnIdleEnd run when OnIdle  Done := true;
end;

constructor TForm1.Create(TheOwner: TComponent);
begin
inherited Create(TheOwner);

  Application.Name:='FileMappingDebug';
  MutexHandle := CreateMutex(nil, True, PAnsiChar(Application.Name));
   if (MutexHandle = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    if MutexHandle <> 0 then begin CloseHandle(MutexHandle); MutexHandle:=0; end;
    Halt;
  end;

  Memo_:=Memo1;
  Memo__:=Memo2;

  {$IFDEF Windows}
    GetStartupInfo(StartUp);
    //_tprintf('Startup.dwFlags: '+Startup.dwFlags.ToString);
    //if (Startup.dwFlags = $401) then _tprintf('Strart up using GUI app Explorer');
    //if (Startup.dwFlags = $000) then _tprintf('Strart up using GUI app CMD');
    //if (Startup.dwFlags = $C01) then _tprintf('Strart up using GUI app Shortcut');
    //if (Startup.dwFlags = $001) then _tprintf('Strart up using Console app Explorer');
    //if (Startup.dwFlags = $801)then _tprintf('Strart up using Console app Shortcut');
  //            GUI app	             GUI app	        GUI app	               Console app          Console app	          Console app
  //Variable	Explorer	     CMD	        Shortcut	       Explorer	            CMD	                  Shortcut
  //dwFlags	0x00000401	     0x00000000	        0x00000C01	       0x00000001 	    0x00000000	          0x00000801
  //wShowWindow	0x0001	             0x0001	        0x0001	               0x0001	            0x0001	          0x0001
  //hStdOutput	0x0000000000010001   0xFFFFFFFFFFFFFFFF	0x0000000000010001     0xFFFFFFFFFFFFFFFF   0xFFFFFFFFFFFFFFFF	  0xFFFFFFFFFFFFFFFF
  {$ENDIF}

  Application.OnIdle := @OnIdle;
  Application.OnIdleEnd:=@OnIdleEnd;

  SetLastError(0);

   hMapFile := CreateFileMapping(
    INVALID_HANDLE_VALUE, // Use paging file instead of an actual file
    nil,                  // Default security
    PAGE_READWRITE,       // Read/write access
    0,                    // Maximum object size (high-order DWORD)
    MEMORY_SIZE,          // Maximum object size (low-order DWORD)
    CMapName              // Name of mapping object
  );

  if hMapFile = 0 then
  begin
    _tprintf('Could not create file mapping object. Error: '+ SysErrorMessage(GetLastError));
    halt;
  end;

   hMapFile2 := CreateFileMapping(
    INVALID_HANDLE_VALUE, // Use paging file instead of an actual file
    nil,                  // Default security
    PAGE_READWRITE,       // Read/write access
    0,                    // Maximum object size (high-order DWORD)
    MEMORY_SIZE,          // Maximum object size (low-order DWORD)
    CMapName2              // Name of mapping object
  );

  if hMapFile2 = 0 then
  begin
    _tprintf2('Could not create file mapping object. Error: '+ SysErrorMessage(GetLastError));
    halt;
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
    halt;
  end;

  pBuf2 := PChar(MapViewOfFile(
    hMapFile2,            // Handle to map object
    FILE_MAP_ALL_ACCESS, // Read/write permission
    0,
    0,
    MEMORY_SIZE
  ));

  if pBuf2 = nil then
  begin
    _tprintf2('Could not map view of file. Error: '+ SysErrorMessage(GetLastError));
    CloseHandle(hMapFile2);
    halt;
  end;

  StrCopy(pBuf, '');
  StrCopy(pBuf2, '');

end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if MutexHandle <> 0 then begin CloseHandle(MutexHandle); MutexHandle:=0; end;
  if pBuf <> nil then
  begin
    UnmapViewOfFile(pBuf);
    pBuf:=nil
  end;
  if hMapFile <> 0 then
  begin
    CloseHandle(hMapFile);
    hMapFile := 0;
  end;

  if pBuf2 <> nil then
  begin
    UnmapViewOfFile(pBuf2);
    pBuf2:=nil
  end;
  if hMapFile2 <> 0 then
  begin
    CloseHandle(hMapFile2);
    hMapFile2 := 0;
  end;

  CloseHandle(MutexHandle);
  //_tprintf('Execution completed successfully.');

end;

end.

