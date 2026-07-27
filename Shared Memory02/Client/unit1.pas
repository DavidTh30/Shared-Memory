unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  uPageFileStream;

type
  TData = record
    FUniqueID: DWORD;
    FName: string;
  end;

type

  { TForm1 }

  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private

  public
    function Receive(out Data: TData): Boolean;
    procedure log(s:string);
    constructor Create(TheOwner: TComponent);  override;
    procedure OnIdle(Sender: TObject; var Done: boolean);
    procedure OnIdleEnd(Sender: TObject);
  end;

const
  CMapName = '{9D809F6B-FC10-4E4F-B352-4A7773762BAA}'; // Any unique name

var
  Form1: TForm1;
  Memo_: TMemo;
  DataIn, DataOut: TData;

implementation

{$R *.lfm}

{ TForm1 }

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

procedure TForm1.log(s:string);
begin
  Memo_.Append(s);
end;

constructor TForm1.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  Memo_:=Memo1;
  Application.OnIdle := @OnIdle;
  Application.OnIdleEnd:=@OnIdleEnd;

  DataIn.FUniqueID := 15;
  DataIn.FName := 'Some string';

  log('TForm1.Create');

end;

procedure TForm1.OnIdle(Sender: TObject; var Done: boolean);
begin
  if Receive(DataOut) then
  begin
    Label2.Caption:='ID= '+ DataOut.FUniqueID.ToString;
    Label3.Caption:='Name= '+ DataOut.FName;
  end
  else
    log(SysErrorMessage(GetLastOSError));

  if memo1.Lines.Count > 20 then memo1.Lines.Delete(0);

  Done := false;
end;

procedure TForm1.OnIdleEnd(Sender: TObject);
begin
  // OnIdleEnd run when OnIdle  Done := true;
end;


procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

end.

