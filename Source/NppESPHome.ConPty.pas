// Windows pseudoconsole host for the NppESPHome dockable terminal.
// Dynamically loads ConPTY, manages the child process and pipe lifetime, and
// forwards asynchronous output and exit notifications to the console form.
unit NppESPHome.ConPty;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Math;

const
  WM_CONPTY_OUTPUT = WM_APP + $521;
  WM_CONPTY_EXIT = WM_APP + $522;

type
  THPCON = THandle;

  // Owns one output block posted from the reader thread to the UI window.
  // Generation identifies the session so delayed messages can be discarded.
  TConPtyOutputChunk = class
  public
    Data: TBytes;
    Generation: Cardinal;
    constructor Create(const AData: TBytes; const ACount: Cardinal;
      const AGeneration: Cardinal);
  end;

  TConPtySession = class;

  // Drains the ConPTY output pipe without blocking the Notepad++ UI thread.
  TConPtyReaderThread = class(TThread)
  private
    FOwner: TConPtySession;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TConPtySession);
  end;

  // Owns one bidirectional Windows pseudoconsole session, including its pipes,
  // process handles, reader thread, size, and UI notification target.
  TConPtySession = class
  private
    FInputWrite: THandle;
    FOutputRead: THandle;
    FPseudoConsole: THPCON;
    FProcessInfo: TProcessInformation;
    FReader: TConPtyReaderThread;
    FNotifyWindow: HWND;
    FRunning: LongInt;
    FStopping: LongInt;
    FGeneration: Cardinal;
    function GetProcessId: Cardinal;
    function GetRunning: Boolean;
    procedure PostOutput(const Buffer: TBytes; const Count: Cardinal);
    procedure PostExit(const ExitCode: Cardinal);
  public
    constructor Create(const ANotifyWindow: HWND);
    destructor Destroy; override;

    class function IsSupported: Boolean; static;
    procedure Start(const CommandLine, CurrentDirectory: string;
      const Columns, Rows: SmallInt);
    procedure Stop;
    procedure Resize(const Columns, Rows: SmallInt);
    procedure WriteBytes(const Data: TBytes);
    procedure WriteText(const Text: string);

    property Generation: Cardinal read FGeneration;
    property ProcessId: Cardinal read GetProcessId;
    property Running: Boolean read GetRunning;
  end;

implementation

// Localized errors that can propagate from the pseudoconsole to the UI.
resourcestring
  rsConPtyWin32Error = '%s failed. Error %d: %s';
  rsConPtyUnavailable =
    'Windows Pseudoconsole (ConPTY) is not available on this system.';
  rsConPtyCreatePseudoConsoleError =
    'CreatePseudoConsole failed (HRESULT 0x%.8x).';
  rsConPtyOperationCreateInputPipe = 'CreatePipe(input)';
  rsConPtyOperationCreateOutputPipe = 'CreatePipe(output)';
  rsConPtyOperationInitializeAttributeList =
    'InitializeProcThreadAttributeList';
  rsConPtyOperationUpdateAttribute = 'UpdateProcThreadAttribute(ConPTY)';
  rsConPtyOperationCreateProcess = 'CreateProcessW(ConPTY)';

const
  PROC_THREAD_ATTRIBUTE_PSEUDOCONSOLE = $00020016;

type
  TStartupInfoExW = record
    StartupInfo: TStartupInfoW;
    AttributeList: PProcThreadAttributeList;
  end;

  TCreatePseudoConsole = function(Size: DWORD; InputRead, OutputWrite: THandle;
    Flags: DWORD; var PseudoConsole: THPCON): HRESULT; stdcall;
  TResizePseudoConsole = function(PseudoConsole: THPCON;
    Size: DWORD): HRESULT; stdcall;
  TClosePseudoConsole = procedure(PseudoConsole: THPCON); stdcall;
  TUpdateProcThreadAttributeProc = function(
    AttributeList: PProcThreadAttributeList; Flags: DWORD;
    Attribute: NativeUInt; Value: Pointer; ValueSize: NativeUInt;
    PreviousValue: Pointer; ReturnSize: PNativeUInt): BOOL; stdcall;
function CreateProcessWWithExtendedStartup(ApplicationName: LPCWSTR;
  CommandLine: LPWSTR; ProcessAttributes, ThreadAttributes: PSecurityAttributes;
  InheritHandles: BOOL; CreationFlags: DWORD; Environment: Pointer;
  CurrentDirectory: LPCWSTR; StartupInfo, ProcessInformation: Pointer): BOOL;
  stdcall; external kernel32 name 'CreateProcessW';

var
  CreatePseudoConsoleProc: TCreatePseudoConsole;
  ResizePseudoConsoleProc: TResizePseudoConsole;
  ClosePseudoConsoleProc: TClosePseudoConsole;
  UpdateProcThreadAttributeProc: TUpdateProcThreadAttributeProc;
  ConPtyApiLoaded: Boolean;
  ConPtyApiAvailable: Boolean;

// *****************************************************************************
// Purpose: Resolves the ConPTY entry points from Kernel32 on first use and
// caches whether the complete API required by the session is available.
// *****************************************************************************
function LoadConPtyApi: Boolean;
var
  KernelModule: HMODULE;
begin
  if not ConPtyApiLoaded then
  begin
    ConPtyApiLoaded := True;
    KernelModule := GetModuleHandle('kernel32.dll');
    if KernelModule <> 0 then
    begin
      CreatePseudoConsoleProc := TCreatePseudoConsole(GetProcAddress(
        KernelModule, PAnsiChar(AnsiString('CreatePseudoConsole'))));
      ResizePseudoConsoleProc := TResizePseudoConsole(GetProcAddress(
        KernelModule, PAnsiChar(AnsiString('ResizePseudoConsole'))));
      ClosePseudoConsoleProc := TClosePseudoConsole(GetProcAddress(
        KernelModule, PAnsiChar(AnsiString('ClosePseudoConsole'))));
      UpdateProcThreadAttributeProc := TUpdateProcThreadAttributeProc(
        GetProcAddress(KernelModule,
          PAnsiChar(AnsiString('UpdateProcThreadAttribute'))));
    end;
    ConPtyApiAvailable := Assigned(CreatePseudoConsoleProc) and
      Assigned(ResizePseudoConsoleProc) and Assigned(ClosePseudoConsoleProc);
    ConPtyApiAvailable := ConPtyApiAvailable and
      Assigned(UpdateProcThreadAttributeProc);
  end;
  Result := ConPtyApiAvailable;
end;

// *****************************************************************************
// Purpose: Clamps a pseudoconsole row or column count to the minimum accepted
// by the Windows API.
// *****************************************************************************
function ValidDimension(const Value: SmallInt): SmallInt;
begin
  if Value < 1 then
    Result := 1
  else
    Result := Value;
end;

// *****************************************************************************
// Purpose: Packs the validated column and row counts into the COORD-compatible
// DWORD representation used by the dynamically declared ConPTY functions.
// *****************************************************************************
function PackConsoleSize(const Columns, Rows: SmallInt): DWORD;
begin
  Result := DWORD(Word(ValidDimension(Columns))) or
    (DWORD(Word(ValidDimension(Rows))) shl 16);
end;

// *****************************************************************************
// Purpose: Raises an EOSError that includes the failed ConPTY operation, the
// current Win32 error code, and its system description.
// *****************************************************************************
procedure RaiseConPtyWin32Error(const Operation: string);
var
  ErrorCode: Cardinal;
begin
  ErrorCode := GetLastError;
  raise EOSError.CreateFmt(rsConPtyWin32Error,
    [Operation, ErrorCode, SysErrorMessage(ErrorCode)]);
end;

// ============================================================================
// TConPtyOutputChunk Implementation
// ============================================================================

// *****************************************************************************
// Purpose: Copies a reader-thread buffer into a message-owned payload and
// associates it with the session generation that produced it.
// *****************************************************************************
constructor TConPtyOutputChunk.Create(const AData: TBytes;
  const ACount, AGeneration: Cardinal);
begin
  inherited Create;
  SetLength(Data, ACount);
  if ACount > 0 then
    Move(AData[0], Data[0], ACount);
  Generation := AGeneration;
end;

// ============================================================================
// TConPtyReaderThread Implementation
// ============================================================================

// *****************************************************************************
// Purpose: Creates a suspended, explicitly owned reader thread for one ConPTY
// session. The session starts it only after process creation succeeds.
// *****************************************************************************
constructor TConPtyReaderThread.Create(AOwner: TConPtySession);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FOwner := AOwner;
end;

// *****************************************************************************
// Purpose: Polls and drains the ConPTY output pipe, posts data to the UI, and
// reports the process exit after preserving any final pseudoconsole output.
// *****************************************************************************
procedure TConPtyReaderThread.Execute;
const
  PollIntervalMs = 20;
var
  Available: DWORD;
  BytesRead: DWORD;
  Buffer: TBytes;
  ProcessExitCode: DWORD;
  ExitReported: Boolean;
begin
  SetLength(Buffer, 8192);
  ExitReported := False;

  while InterlockedCompareExchange(FOwner.FStopping, 0, 0) = 0 do
  begin
    Available := 0;
    if not PeekNamedPipe(FOwner.FOutputRead, nil, 0, nil, @Available, nil) then
      Break;

    if Available > 0 then
    begin
      BytesRead := 0;
      if not ReadFile(FOwner.FOutputRead, Buffer[0],
        Min(Cardinal(Length(Buffer)), Available), BytesRead, nil) then
        Break;
      if BytesRead > 0 then
        FOwner.PostOutput(Buffer, BytesRead);
      Continue;
    end;

    if WaitForSingleObject(FOwner.FProcessInfo.hProcess, PollIntervalMs) =
      WAIT_OBJECT_0 then
    begin
      if not ExitReported then
      begin
        ProcessExitCode := DWORD(-1);
        GetExitCodeProcess(FOwner.FProcessInfo.hProcess, ProcessExitCode);
        InterlockedExchange(FOwner.FRunning, 0);
        FOwner.PostExit(ProcessExitCode);
        ExitReported := True;
      end;
      // Keep draining the pseudoconsole after the initial process exits. The
      // HPCON can still own descendants or a final frame; Stop will close it
      // while this reader remains active.
      Sleep(PollIntervalMs);
    end;
  end;

  InterlockedExchange(FOwner.FRunning, 0);
  if not ExitReported then
  begin
    ProcessExitCode := DWORD(-1);
    if FOwner.FProcessInfo.hProcess <> 0 then
      GetExitCodeProcess(FOwner.FProcessInfo.hProcess, ProcessExitCode);
    FOwner.PostExit(ProcessExitCode);
  end;
end;

// ============================================================================
// TConPtySession Implementation
// ============================================================================

// *****************************************************************************
// Purpose: Initializes an idle session that will deliver output and exit
// messages to the supplied window handle.
// *****************************************************************************
constructor TConPtySession.Create(const ANotifyWindow: HWND);
begin
  inherited Create;
  FNotifyWindow := ANotifyWindow;
  FillChar(FProcessInfo, SizeOf(FProcessInfo), 0);
end;

// *****************************************************************************
// Purpose: Stops any active pseudoconsole, releases its resources, and removes
// the UI notification target before destroying the session.
// *****************************************************************************
destructor TConPtySession.Destroy;
begin
  Stop;
  FNotifyWindow := 0;
  inherited;
end;

// *****************************************************************************
// Purpose: Reports whether all Windows APIs required to host ConPTY are
// available on the current system.
// *****************************************************************************
class function TConPtySession.IsSupported: Boolean;
begin
  Result := LoadConPtyApi;
end;

// *****************************************************************************
// Purpose: Returns the process identifier of the current pseudoconsole client,
// or zero when no process is attached.
// *****************************************************************************
function TConPtySession.GetProcessId: Cardinal;
begin
  Result := FProcessInfo.dwProcessId;
end;

// *****************************************************************************
// Purpose: Reads the thread-safe running flag shared with the output reader.
// *****************************************************************************
function TConPtySession.GetRunning: Boolean;
begin
  Result := InterlockedCompareExchange(FRunning, 0, 0) <> 0;
end;

// *****************************************************************************
// Purpose: Copies an output block and posts ownership of it to the console
// window, freeing the payload immediately if the message cannot be queued.
// *****************************************************************************
procedure TConPtySession.PostOutput(const Buffer: TBytes;
  const Count: Cardinal);
var
  Chunk: TConPtyOutputChunk;
begin
  if (FNotifyWindow = 0) or (Count = 0) then
    Exit;
  Chunk := TConPtyOutputChunk.Create(Buffer, Count, FGeneration);
  if not PostMessage(FNotifyWindow, WM_CONPTY_OUTPUT, 0, LPARAM(Chunk)) then
    Chunk.Free;
end;

// *****************************************************************************
// Purpose: Posts the process exit code and current generation to the console
// window without blocking the reader thread.
// *****************************************************************************
procedure TConPtySession.PostExit(const ExitCode: Cardinal);
begin
  if FNotifyWindow <> 0 then
    PostMessage(FNotifyWindow, WM_CONPTY_EXIT, WPARAM(ExitCode),
      LPARAM(FGeneration));
end;

// *****************************************************************************
// Purpose: Replaces any previous session, creates the ConPTY pipes and process,
// attaches the pseudoconsole attribute, and starts asynchronous output reading.
// *****************************************************************************
procedure TConPtySession.Start(const CommandLine, CurrentDirectory: string;
  const Columns, Rows: SmallInt);
var
  InputRead: THandle;
  OutputWrite: THandle;
  StartupInfoEx: TStartupInfoExW;
  AttributeListSize: NativeUInt;
  ConsoleSize: DWORD;
  MutableCommandLine: string;
  CurrentDirectoryPtr: PWideChar;
  CreateResult: HRESULT;
begin
  Stop;
  if not LoadConPtyApi then
    raise ENotSupportedException.Create(rsConPtyUnavailable);

  Inc(FGeneration);
  if FGeneration = 0 then
    Inc(FGeneration);
  InterlockedExchange(FStopping, 0);
  InputRead := 0;
  OutputWrite := 0;
  FillChar(FProcessInfo, SizeOf(FProcessInfo), 0);
  FillChar(StartupInfoEx, SizeOf(StartupInfoEx), 0);
  StartupInfoEx.StartupInfo.cb := SizeOf(StartupInfoEx);

  try
    try
    if not CreatePipe(InputRead, FInputWrite, nil, 0) then
        RaiseConPtyWin32Error(rsConPtyOperationCreateInputPipe);
    if not CreatePipe(FOutputRead, OutputWrite, nil, 0) then
      RaiseConPtyWin32Error(rsConPtyOperationCreateOutputPipe);

    ConsoleSize := PackConsoleSize(Columns, Rows);
    CreateResult := CreatePseudoConsoleProc(ConsoleSize, InputRead,
      OutputWrite, 0, FPseudoConsole);
    if CreateResult < 0 then
      raise EOSError.CreateFmt(rsConPtyCreatePseudoConsoleError,
        [Cardinal(CreateResult)]);
    // CreatePseudoConsole duplicates its ends into conhost. Retaining these
    // host-side copies can prevent correct pipe lifetime and EOF detection.
    CloseHandle(InputRead);
    InputRead := 0;
    CloseHandle(OutputWrite);
    OutputWrite := 0;

    AttributeListSize := 0;
    InitializeProcThreadAttributeList(nil, 1, 0, AttributeListSize);
    GetMem(StartupInfoEx.AttributeList, AttributeListSize);
    FillChar(StartupInfoEx.AttributeList^, AttributeListSize, 0);
    if not InitializeProcThreadAttributeList(StartupInfoEx.AttributeList, 1,
      0, AttributeListSize) then
      RaiseConPtyWin32Error(rsConPtyOperationInitializeAttributeList);

    if not UpdateProcThreadAttributeProc(StartupInfoEx.AttributeList, 0,
      PROC_THREAD_ATTRIBUTE_PSEUDOCONSOLE, Pointer(FPseudoConsole),
      SizeOf(FPseudoConsole), nil, nil) then
      RaiseConPtyWin32Error(rsConPtyOperationUpdateAttribute);

    // When the plugin host itself has redirected standard handles, Windows can
    // copy them into the child even though a pseudoconsole attribute is set.
    // Explicitly selecting the (zeroed) STARTUPINFO handles prevents that
    // inheritance and lets ConPTY install its console handles instead.
    StartupInfoEx.StartupInfo.dwFlags := STARTF_USESTDHANDLES;
    MutableCommandLine := CommandLine;
    UniqueString(MutableCommandLine);
    if CurrentDirectory = '' then
      CurrentDirectoryPtr := nil
    else
      CurrentDirectoryPtr := PWideChar(CurrentDirectory);

    if not CreateProcessWWithExtendedStartup(nil, PWideChar(MutableCommandLine),
      nil, nil, False, EXTENDED_STARTUPINFO_PRESENT, nil,
      CurrentDirectoryPtr, @StartupInfoEx, @FProcessInfo) then
      RaiseConPtyWin32Error(rsConPtyOperationCreateProcess);

    CloseHandle(FProcessInfo.hThread);
    FProcessInfo.hThread := 0;
    InterlockedExchange(FRunning, 1);
    FReader := TConPtyReaderThread.Create(Self);
    FReader.Start;
    except
      Stop;
      raise;
    end;
  finally
    if StartupInfoEx.AttributeList <> nil then
    begin
      DeleteProcThreadAttributeList(StartupInfoEx.AttributeList);
      FreeMem(StartupInfoEx.AttributeList);
    end;
    if InputRead <> 0 then
      CloseHandle(InputRead);
    if OutputWrite <> 0 then
      CloseHandle(OutputWrite);
  end;
end;

// *****************************************************************************
// Purpose: Closes a running pseudoconsole in pipe-safe order, drains its final
// output, waits for the reader, and releases all process and pipe handles.
// *****************************************************************************
procedure TConPtySession.Stop;
begin
  if FInputWrite <> 0 then
  begin
    CloseHandle(FInputWrite);
    FInputWrite := 0;
  end;

  if Assigned(FReader) then
  begin
    // ClosePseudoConsole may emit a final frame. Keep the reader alive until
    // the close completes and the pipe reaches EOF. This both prevents the
    // documented close deadlock and preserves output buffered by ConPTY until
    // the client process exits.
    if FPseudoConsole <> 0 then
    begin
      if Assigned(ClosePseudoConsoleProc) then
        ClosePseudoConsoleProc(FPseudoConsole);
      FPseudoConsole := 0;
    end;
    FReader.WaitFor;
    FreeAndNil(FReader);
    InterlockedExchange(FStopping, 1);
  end
  else
  begin
    // During startup failure there is no reader to drain a final frame.
    // Closing the read end makes the pseudoconsole writer fail instead.
    InterlockedExchange(FStopping, 1);
    if FOutputRead <> 0 then
    begin
      CloseHandle(FOutputRead);
      FOutputRead := 0;
    end;
  end;

  if FPseudoConsole <> 0 then
  begin
    if Assigned(ClosePseudoConsoleProc) then
      ClosePseudoConsoleProc(FPseudoConsole);
    FPseudoConsole := 0;
  end;

  if FOutputRead <> 0 then
  begin
    CloseHandle(FOutputRead);
    FOutputRead := 0;
  end;

  if FProcessInfo.hThread <> 0 then
  begin
    CloseHandle(FProcessInfo.hThread);
    FProcessInfo.hThread := 0;
  end;
  if FProcessInfo.hProcess <> 0 then
  begin
    CloseHandle(FProcessInfo.hProcess);
    FProcessInfo.hProcess := 0;
  end;
  FProcessInfo.dwProcessId := 0;
  InterlockedExchange(FRunning, 0);
end;

// *****************************************************************************
// Purpose: Resizes the active pseudoconsole to the supplied terminal dimensions
// when the ConPTY handle and resize API are available.
// *****************************************************************************
procedure TConPtySession.Resize(const Columns, Rows: SmallInt);
var
  ConsoleSize: DWORD;
begin
  if (FPseudoConsole = 0) or not Assigned(ResizePseudoConsoleProc) then
    Exit;
  ConsoleSize := PackConsoleSize(Columns, Rows);
  ResizePseudoConsoleProc(FPseudoConsole, ConsoleSize);
end;

// *****************************************************************************
// Purpose: Writes the complete byte array to the ConPTY input pipe, handling
// partial writes until all bytes are sent or the pipe closes.
// *****************************************************************************
procedure TConPtySession.WriteBytes(const Data: TBytes);
var
  BytesWritten: DWORD;
  Offset: Cardinal;
  Remaining: Cardinal;
begin
  if (FInputWrite = 0) or (Length(Data) = 0) then
    Exit;
  Offset := 0;
  while Offset < Cardinal(Length(Data)) do
  begin
    Remaining := Cardinal(Length(Data)) - Offset;
    BytesWritten := 0;
    if not WriteFile(FInputWrite, Data[Offset], Remaining, BytesWritten, nil) then
      Break;
    if BytesWritten = 0 then
      Break;
    Inc(Offset, BytesWritten);
  end;
end;

// *****************************************************************************
// Purpose: Encodes Unicode text as UTF-8 and forwards it to the ConPTY input
// pipe.
// *****************************************************************************
procedure TConPtySession.WriteText(const Text: string);
begin
  WriteBytes(TEncoding.UTF8.GetBytes(Text));
end;

end.
