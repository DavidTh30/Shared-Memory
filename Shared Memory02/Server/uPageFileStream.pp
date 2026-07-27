{$MODE OBJFPC}
{$LONGSTRINGS ON}

unit uPageFileStream;

{ TPageFileStream is a stream in the system page file }

interface

uses
  Classes, StdCtrls, sysutils;

procedure log(s:string);

type
  { TPage FileStream does not throw an exception, but sets flags in the state
    If pfsValid is not contained in the States, then the error code explaining
    the cause can be obtained through GetLastError
    Real size (and stream size) may be other, then wanted, because system
    allocate by page or open existing with other settings
  }

  TPageFileStreamStates = set of (
    pfsValid, // The result of calling Create was successful
    pfsOpenExisting // An existing one is open, but no new one is created,
      // but in write mode
    );

  {
    Usage:

    call Create with parameters
    MapSize - must be greater than zero
    MapName - for interprocess communication
    The size of the stream does not change after Create, but it can differ
    from MapSize.

    call CreateForRead if you only need to read
    If used read only mode then don't write to data

    Use the Size property to determine the actual size
  }

  TPageFileStream = class(TCustomMemoryStream)
  strict private

    FStates: TPageFileStreamStates;

  public
    FMapHandle: THandle;
    procedure DoMap(DesiredAccess: DWORD);
    constructor Create(MapSize: SizeUInt; const MapName: UnicodeString = '');
    constructor CreateForRead(const MapName: UnicodeString);
    destructor Destroy; override;
    function Write(const Buffer; Count: LongInt): LongInt; override;
    property States: TPageFileStreamStates read FStates;
  end;

var
  Memo_: TMemo;

implementation

uses Windows;

procedure log(s:string);
begin
  Memo_.Append(s);
end;

constructor TPageFileStream.Create(MapSize: SizeUInt; const MapName: UnicodeString);
begin
  inherited Create;
  SetLastError(0);
  // ! Not PWideChar(MapName), because PWideChar('') <> nil
  FMapHandle := CreateFileMappingW(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE,
    Hi(MapSize), Lo(MapSize), Pointer(MapName));
  if FMapHandle <> 0 then
  begin
    if GetLastError = ERROR_ALREADY_EXISTS then
    begin
      Include(FStates, pfsOpenExisting);
      log({$I %LINE%}+' GetLastError= '+SysErrorMessage(GetLastError));
      //exit;
    end;
    DoMap(FILE_MAP_WRITE);
    log({$I %LINE%}+' FMapHandle:='+IntToStr(FMapHandle));
  end
  else
  begin
    log({$I %LINE%}+' GetLastError= '+SysErrorMessage(GetLastError));
    log({$I %LINE%}+' FMapHandle:='+IntToStr(FMapHandle));
  end;
end;

constructor TPageFileStream.CreateForRead(const MapName: UnicodeString);
begin
  inherited Create;
  FMapHandle := OpenFileMappingW(FILE_MAP_READ, False, Pointer(MapName));
  if FMapHandle <> 0 then
  begin
    Include(FStates, pfsOpenExisting);
    DoMap(FILE_MAP_READ);
  end;
end;

destructor TPageFileStream.Destroy;
begin
  if Memory <> nil then
  begin
    UnmapViewOfFile(Memory);
    SetPointer(nil, 0); //For only TPageFileStream class
  end;
  if FMapHandle <> 0 then
  begin
    CloseHandle(FMapHandle);
    FMapHandle := 0;
  end;
  inherited;
end;

procedure TPageFileStream.DoMap(DesiredAccess: DWORD);
var
  P: Pointer;
  Info: TMemoryBasicInformation;
begin
  SetLastError(0);
  P := MapViewOfFile(FMapHandle, DesiredAccess, 0, 0, 0);
  if Assigned(P) then
  begin
    log({$I %LINE%}+' Assigned(P)');
    log({$I %LINE%}+' GetLastError= '+SysErrorMessage(GetLastError));
    if VirtualQuery(P, @Info, SizeOf(Info)) <> 0 then
    begin
      log({$I %LINE%}+' VirtualQuery <> 0');
      SetPointer(P, Info.RegionSize);
      Include(FStates, pfsValid);
    end;
  end;
end;

function TPageFileStream.Write(const Buffer; Count: LongInt): LongInt;
var
  OldPos, NewPos: Int64;
begin
  Result := 0;
  OldPos := Position;
  if (OldPos >= 0) and (Count >= 0) then
  begin
    NewPos := OldPos + Count;
    if (NewPos > 0) and (NewPos < Size) then
    begin
      System.Move(Buffer, PByte(Memory)[OldPos], Count);
      Position := NewPos;
      Result := Count;
    end;
  end;
end;

end.

