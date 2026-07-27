unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uPageFileStream, Windows;

type
  TData = record
    FUniqueID: DWORD;
    FName: string;
  end;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private

  public
    function Receive(out Data: TData): Boolean;
    constructor Create(TheOwner: TComponent);  override;
    procedure OnIdle(Sender: TObject; var Done: boolean);
    procedure OnIdleEnd(Sender: TObject);
  end;

const
  CMapName = '{9D809F6B-FC10-4E4F-B352-4A7773762BAA}'; // Any unique name

var
  Form1: TForm1;
  Stream: TPageFileStream;
  DataIn, DataOut: TData;

implementation

{$R *.lfm}

{ TForm1 }

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

function TForm1.Receive(out Data: TData): Boolean;
var
  Stream: TPageFileStream;
begin
  Stream := TPageFileStream.CreateForRead(CMapName);
  try
    Result := (pfsValid in Stream.States) and (Stream.Size >= SizeOf(Data));
    if Result then
    begin
      Data.FUniqueID := Stream.ReadDWord;
      Data.FName := Stream.ReadAnsiString;
    end;
  finally
    Stream.Free;
  end;
end;

constructor TForm1.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Memo_:=Memo1;
  Application.OnIdle := @OnIdle;
  Application.OnIdleEnd:=@OnIdleEnd;

  DataIn.FUniqueID := 0;
  DataIn.FName := '';

  log({$I %LINE%}+' TForm1.Create');

end;

procedure TForm1.OnIdle(Sender: TObject; var Done: boolean);
begin
  try

    if Stream<> nil then begin Stream.Free; Stream:=nil; end;
    // SizeOf(DataIn) + Length(DataIn.FName) is enough
    if Stream = nil then Stream := TPageFileStream.Create(SizeOf(DataIn) + Length(DataIn.FName), CMapName);
    //if Stream <> nil then Stream.DoMap(FILE_MAP_WRITE);

    Randomize;
    DataIn.FUniqueID := Random(1000);
    DataIn.FName := RandomString(10);
    Stream.WriteDWord(DataIn.FUniqueID);
    Stream.WriteAnsiString(DataIn.FName);
    log('Cmd_Send: DataIn.FUniqueID= '+DataIn.FUniqueID.ToString);
  finally
    if memo1.Lines.Count > 20 then memo1.Lines.Delete(0);
  end;

  Done := false;
end;

procedure TForm1.OnIdleEnd(Sender: TObject);
begin
  // OnIdleEnd run when OnIdle  Done := true;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Stream<> nil then begin Stream.Free; Stream:=nil; end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  boo:boolean;
begin
  Application.OnIdle := nil;
  OnIdle(Sender,boo);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Application.OnIdle := @OnIdle;
end;

end.

