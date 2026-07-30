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
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  windows, Unit2;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    Shape1: TShape;
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

  if FileMappingActive(CMapName) then  Shape1.Brush.Color:=clGreen else Shape1.Brush.Color:=clWhite;

  Done := false;
end;

procedure TForm1.OnIdleEnd(Sender: TObject);
begin
  // OnIdleEnd run when OnIdle  Done := true;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if MutexHandle <> 0 then begin CloseHandle(MutexHandle); MutexHandle:=0; end;

  if pBuf <> nil then
  begin
    UnmapViewOfFile(pBuf);
    pBuf:=nil;
  end;
  if hMapFile <> 0 then
  begin
    CloseHandle(hMapFile);
    hMapFile := 0;
  end;

  CloseHandle(MutexHandle);
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
  Memo_:=Memo1;
  Application.OnIdle := @OnIdle;
  Application.OnIdleEnd:=@OnIdleEnd;

  Application.Name:='SampleClient';
  MutexHandle := CreateMutex(nil, True, PAnsiChar(Application.Name));  //CompanyName.ProductName.AppName
   if (MutexHandle = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    if MutexHandle <> 0 then begin CloseHandle(MutexHandle); MutexHandle:=0; end;
    Halt;
  end;

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


end;


end.

