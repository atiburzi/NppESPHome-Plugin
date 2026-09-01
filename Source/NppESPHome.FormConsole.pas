// Dockable ANSI terminal used to host interactive ESPHome command sessions.
// Renders UTF-8 and ANSI/VT output, forwards keyboard input through ConPTY,
// manages terminal scrolling, and presents session status and controls.
unit NppESPHome.FormConsole;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, NppPlugin, NppPluginDockingForm, NppESPHome.ConPty,
  Vcl.ToolWin, System.ImageList, Vcl.ImgList, Vcl.VirtualImageList,
  Vcl.VirtualImage, Vcl.Buttons, Vcl.Dialogs;

const
  WM_CONSOLE_SCROLL_BOTTOM = WM_APP + $523;

type
  // Visual and lifecycle states displayed by the console header.
  TConsoleStatus = (csReady, csRunning, csInterrupted, csError);

  // Incremental states used while parsing ANSI escape sequences across chunks.
  TAnsiParserState = (apsText, apsEscape, apsCsi, apsOsc, apsOscEscape);

  // Active SGR attributes applied to subsequently rendered terminal text.
  TTerminalStyle = record
    Foreground: TColor;
    Background: TColor;
    HasForeground: Boolean;
    HasBackground: Boolean;
    Bold: Boolean;
    Italic: Boolean;
    Underline: Boolean;
    Inverse: Boolean;
  end;

  // Hosts one ConPTY session and translates its terminal stream into a styled
  // RichEdit view while preserving interactive keyboard behavior.
  TFormConsole = class(TNppPluginDockingForm)
    RichEditConsole: TRichEdit;
    VirtualImageList: TVirtualImageList;
    PanelCommands: TPanel;
    PanelSession: TPanel;
    LabelTitle: TLabel;
    LabelStatus: TLabel;
    SpeedButtonStop: TSpeedButton;
    PanelSpace: TPanel;
    SpeedButtonClear: TSpeedButton;
    PanelIndicator: TPanel;
    PaintBoxActivity: TPaintBox;
    SpeedButtonSelectAll: TSpeedButton;
    SpeedButtonCopy: TSpeedButton;
    SpeedButtonSave: TSpeedButton;
    SpeedButtonFollow: TSpeedButton;
    TimerUI: TTimer;
    SaveDialogLog: TSaveDialog;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure RichEditConsoleKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RichEditConsoleKeyPress(Sender: TObject; var Key: Char);
    procedure RichEditConsoleSelectionChange(Sender: TObject);
    procedure PaintBoxActivityPaint(Sender: TObject);
    procedure SpeedButtonCopyClick(Sender: TObject);
    procedure SpeedButtonClearClick(Sender: TObject);
    procedure SpeedButtonFollowClick(Sender: TObject);
    procedure SpeedButtonSaveClick(Sender: TObject);
    procedure SpeedButtonSelectAllClick(Sender: TObject);
    procedure SpeedButtonStopClick(Sender: TObject);
    procedure TimerUITimer(Sender: TObject);
  private
    FSession: TConPtySession;
    FParserState: TAnsiParserState;
    FCsiBuffer: AnsiString;
    FUtf8Buffer: TBytes;
    FCurrentStyle: TTerminalStyle;
    FDefaultForeground: TColor;
    FDefaultBackground: TColor;
    FCursorPosition: Integer;
    FSavedCursorPosition: Integer;
    FTerminalRows: Integer;
    FPendingCarriageReturn: Boolean;
    FSuppressNextKeyPress: Boolean;
    FStopRequested: Boolean;
    FScrollMessagePending: Boolean;
    FSessionTitle: string;
    FConsoleStatus: TConsoleStatus;
    FStartedTick: UInt64;
    FLastActivityPaintTick: UInt64;
    FCopyFeedbackUntil: UInt64;
    FScrollbackLines: Integer;
    FClearOnCommandStart: Boolean;
    FFollowOutput: Boolean;
    FProgrammaticScroll: Boolean;
    FActivityReset: Boolean;
    FOriginalRichEditWindowProc: TWndMethod;
    FActivityColor: TColor;
    FInactiveColor: TColor;
    FErrorColor: TColor;

    procedure WMConPtyOutput(var Message: TMessage); message WM_CONPTY_OUTPUT;
    procedure WMConPtyExit(var Message: TMessage); message WM_CONPTY_EXIT;
    procedure WMConsoleScrollBottom(var Message: TMessage);
      message WM_CONSOLE_SCROLL_BOTTOM;
    procedure AddUtf8Byte(const Value: Byte);
    procedure ApplyCurrentStyle(const StartPosition, TextLength: Integer);
    procedure CarriageReturn;
    procedure ClearTerminal;
    procedure DrainPendingMessages;
    procedure EnsureLineExists(const LineNumber: Integer);
    procedure EraseInLine(const Mode: Integer);
    procedure ExecuteCsi(const FinalByte: AnsiChar);
    procedure FlushUtf8(const FlushIncomplete: Boolean = False);
    function GetCsiParam(const Params: TArray<string>; const Index,
      DefaultValue: Integer): Integer;
    function GetProcessId: Cardinal;
    function GetRunning: Boolean;
    function GetLineEnd(const CharacterPosition: Integer): Integer;
    function GetLineCount: Integer;
    function GetLineStart(const CharacterPosition: Integer): Integer;
    function GetScreenOriginLine: Integer;
    function GetTextLength: Integer;
    function IsViewAtBottom: Boolean;
    procedure LineFeed;
    procedure MoveCursorHorizontal(const Delta: Integer);
    procedure MoveCursorVertical(const Delta: Integer);
    procedure NotifyOutputActivity;
    procedure ProcessByte(const Value: Byte);
    procedure ProcessOutput(const Data: TBytes);
    procedure ReplaceAtCursor(const Text: string);
    procedure ResetActivityIndicator;
    procedure ResetAnsiStyle;
    procedure ResetParser;
    procedure ResizeSession;
    procedure SendKeySequence(const Sequence: string);
    procedure SetFollowOutput(const Value, ScrollNow: Boolean);
    procedure SetCursorColumn(const Column: Integer);
    procedure SetCursorPosition(const Row, Column: Integer);
    procedure SetCursorRow(const Row: Integer);
    procedure SetStatus(const Text: string; const Status: TConsoleStatus);
    function TrimScrollback: Integer;
    procedure UpdateCopyButton;
    procedure UpdateSaveButton;
    procedure UpdateRunningStatus;
    procedure RichEditConsoleWindowProc(var Message: TMessage);
  public
    constructor Create(NppParent: TNppPlugin; DlgId: Integer); override;
    destructor Destroy; override;
    procedure ApplyPreferences;
    procedure StartCommand(const CommandLine, CurrentDirectory,
      DisplayTitle: string);
    procedure StopCommand;
    procedure ToggleDarkMode; override;
    property Running: Boolean read GetRunning;
    property ProcessId: Cardinal read GetProcessId;
  end;

var
  FormConsole: TFormConsole;

implementation

uses
  Winapi.RichEdit, Vcl.Clipbrd, System.Math, System.IOUtils, NppMessages,
  NppESPHome.Plugin, NppESPHome.Shared;

{$R *.dfm}

// Localized console titles, status messages, feedback, and runtime errors.
resourcestring
  rsConsoleWindowCaption = 'Console';
  rsConsoleDefaultTitle = 'Console';
  rsConsoleStatusReady = 'Ready';
  rsConsoleStatusRunning = 'Running  ·  %.2d:%.2d';
  rsConsoleStatusUnableToStart = 'Unable to start';
  rsConsoleStatusStopped = 'Stopped';
  rsConsoleStatusCompleted = 'Completed';
  rsConsoleStatusExitedWithCode = 'Exited with code %d';
  rsConsoleCopy = 'Copy';
  rsConsoleCopied = 'Copied';
  rsConsoleSelectAll = 'Select all';
  rsConsoleClear = 'Clear';
  rsConsoleStop = 'Stop';
  rsConsoleSave = 'Save';
  rsConsoleFollow = 'Follow';
  rsConsoleSelectAllHint = 'Selects all console output.';
  rsConsoleCopyHint = 'Copies the selected console text.';
  rsConsoleClearHint = 'Clears the console output.';
  rsConsoleStopHint = 'Stops the current running command.';
  rsConsoleSaveHint = 'Saves the console output to a file.';
  rsConsoleFollowEnabledHint = 'Following new output. Click to pause.';
  rsConsoleFollowPausedHint = 'Output following is paused. Click to resume.';
  rsConsoleSaveLogTitle = 'Save console log';
  rsConsoleLogFileFilter =
    'Log files (*.log)|*.log|Text files (*.txt)|*.txt|All files (*.*)|*.*';
  rsConsoleDefaultLogFileName = 'ESPHome-console-%s.log';
  rsConsoleSaveLogError = 'Unable to save the console log:' + sLineBreak + '%s';
  rsConsoleNotInitialized = 'The embedded console is not initialized.';

const
  MaxTerminalCharacters = 2000000;
  TerminalCharacterHeadroom = 500000;
  TerminalCharacterTrimChunk = 500000;
  ActivityFrameMilliseconds = 33;
  ActivityPeriodMilliseconds = 760;
  ActivityBarDelayMilliseconds = 130;
  ActivityMinBarHeight = 3;
  ActivityMaxBarHeight = 16;

  AnsiPalette: array[0..15] of TColor = (
    $000000, $0000AA, $00AA00, $00AAAA,
    $AA0000, $AA00AA, $AAAA00, $C0C0C0,
    $808080, $0000FF, $00FF00, $00FFFF,
    $FF0000, $FF00FF, $FFFF00, $FFFFFF);

// *****************************************************************************
// Purpose: Converts an ANSI 256-color palette index into a VCL RGB color.
// *****************************************************************************
function Ansi256Color(const Index: Integer): TColor;
const
  CubeValue: array[0..5] of Byte = (0, 95, 135, 175, 215, 255);
var
  Value: Integer;
  RedValue: Integer;
  GreenValue: Integer;
  BlueValue: Integer;
begin
  if Index < 0 then
    Exit(clWindowText);
  if Index < 16 then
    Exit(AnsiPalette[Index]);
  if Index < 232 then
  begin
    Value := Index - 16;
    RedValue := CubeValue[Value div 36];
    GreenValue := CubeValue[(Value div 6) mod 6];
    BlueValue := CubeValue[Value mod 6];
    Exit(RGB(RedValue, GreenValue, BlueValue));
  end;
  if Index < 256 then
  begin
    Value := 8 + ((Index - 232) * 10);
    Exit(RGB(Value, Value, Value));
  end;
  Result := clWindowText;
end;

// *****************************************************************************
// Purpose: Returns the byte length of the complete UTF-8 prefix in a buffer so
// an incomplete multibyte character can remain pending for the next chunk.
// *****************************************************************************
function CompleteUtf8Length(const Data: TBytes): Integer;
var
  Index: Integer;
  Needed: Integer;
  CheckIndex: Integer;
  Valid: Boolean;
begin
  Result := 0;
  Index := 0;
  while Index < Length(Data) do
  begin
    if Data[Index] < $80 then
      Needed := 1
    else if (Data[Index] and $E0) = $C0 then
      Needed := 2
    else if (Data[Index] and $F0) = $E0 then
      Needed := 3
    else if (Data[Index] and $F8) = $F0 then
      Needed := 4
    else
      Needed := 1;

    if Index + Needed > Length(Data) then
      Break;

    Valid := True;
    for CheckIndex := Index + 1 to Index + Needed - 1 do
      if (Data[CheckIndex] and $C0) <> $80 then
      begin
        Valid := False;
        Break;
      end;
    if not Valid then
      Needed := 1;

    Inc(Index, Needed);
    Result := Index;
  end;
end;

// ============================================================================
// TFormConsole Implementation
// ============================================================================

// *****************************************************************************
// Purpose: Creates the bottom-docked console, initializes terminal colors and
// parser state, and prepares an idle ConPTY session for the form handle.
// *****************************************************************************
constructor TFormConsole.Create(NppParent: TNppPlugin; DlgId: Integer);
begin
  FNppDefaultDockingMask := DWS_DF_CONT_BOTTOM;
  inherited Create(NppParent, DlgId);
  DefaultCloseAction := caHide;
  RichEditConsole.MaxLength := MaxTerminalCharacters +
    TerminalCharacterHeadroom;
  FDefaultForeground := RichEditConsole.Font.Color;
  FDefaultBackground := RichEditConsole.Color;
  FActivityColor := RGB(22, 131, 79);
  FInactiveColor := RGB(111, 116, 121);
  FErrorColor := RGB(189, 43, 53);
  FScrollbackLines := ciDefaultIntConsoleScrollbackLines;
  FClearOnCommandStart := cbDefaultIntConsoleClearOnStart;
  FFollowOutput := True;
  FTerminalRows := 30;
  FSession := TConPtySession.Create(Handle);
  FOriginalRichEditWindowProc := RichEditConsole.WindowProc;
  RichEditConsole.WindowProc := RichEditConsoleWindowProc;
  ResetParser;
  Caption := rsConsoleWindowCaption;
  FSessionTitle := rsConsoleDefaultTitle;
  LabelTitle.Caption := FSessionTitle;
  SpeedButtonSelectAll.Caption := rsConsoleSelectAll;
  SpeedButtonSelectAll.Hint := rsConsoleSelectAllHint;
  SpeedButtonCopy.Caption := rsConsoleCopy;
  SpeedButtonCopy.Hint := rsConsoleCopyHint;
  SpeedButtonSave.Caption := rsConsoleSave;
  SpeedButtonSave.Hint := rsConsoleSaveHint;
  SpeedButtonClear.Caption := rsConsoleClear;
  SpeedButtonClear.Hint := rsConsoleClearHint;
  SpeedButtonStop.Caption := rsConsoleStop;
  SpeedButtonStop.Hint := rsConsoleStopHint;
  SpeedButtonFollow.Caption := rsConsoleFollow;
  SaveDialogLog.Title := rsConsoleSaveLogTitle;
  SaveDialogLog.Filter := rsConsoleLogFileFilter;
  UpdateCopyButton;
  UpdateSaveButton;
  SetFollowOutput(True, False);
  SetStatus(rsConsoleStatusReady, csReady);
  ApplyPreferences;
end;

// *****************************************************************************
// Purpose: Stops and releases the ConPTY session, then frees queued output
// payloads still assigned to the form before it is destroyed.
// *****************************************************************************
destructor TFormConsole.Destroy;
begin
  if Assigned(FOriginalRichEditWindowProc) then
    RichEditConsole.WindowProc := FOriginalRichEditWindowProc;
  if Assigned(FSession) then
  begin
    FSession.Stop;
    FreeAndNil(FSession);
  end;
  DrainPendingMessages;
  inherited;
end;

// *****************************************************************************
// Purpose: Removes queued ConPTY messages during shutdown and frees output
// chunks whose ownership can no longer be transferred to the form handler.
// *****************************************************************************
procedure TFormConsole.DrainPendingMessages;
var
  PendingMessage: TMsg;
  Chunk: TConPtyOutputChunk;
begin
  if not HandleAllocated then
    Exit;
  while PeekMessage(PendingMessage, Handle, WM_CONPTY_OUTPUT,
    WM_CONPTY_EXIT, PM_REMOVE) do
    if PendingMessage.message = WM_CONPTY_OUTPUT then
    begin
      Chunk := TConPtyOutputChunk(PendingMessage.lParam);
      Chunk.Free;
    end;
end;

// *****************************************************************************
// Purpose: Updates the console state text, Stop-button availability, activity
// animation state, and pending repaint in one operation.
// *****************************************************************************
procedure TFormConsole.SetStatus(const Text: string; const Status: TConsoleStatus);
begin
  FConsoleStatus := Status;
  FActivityReset := False;
  LabelStatus.Caption := Text;
  SpeedButtonStop.Enabled := Status = csRunning;
  SpeedButtonStop.Visible := Status = csRunning;
  FLastActivityPaintTick := 0;
  PaintBoxActivity.Invalidate;
end;

// *****************************************************************************
// Purpose: Clears terminal contents and parser state, restores the default
// header title, and returns keyboard focus to the console.
// *****************************************************************************
procedure TFormConsole.SpeedButtonClearClick(Sender: TObject);
begin
  ClearTerminal;
  SetFollowOutput(True, False);
  if not Running then
    ResetActivityIndicator;
  FSessionTitle := rsConsoleDefaultTitle;
  LabelTitle.Caption := FSessionTitle;
  UpdateCopyButton;
  RichEditConsole.SetFocus;
end;

// *****************************************************************************
// Purpose: Selects all rendered terminal text and refreshes Copy availability.
// *****************************************************************************
procedure TFormConsole.SpeedButtonSelectAllClick(Sender: TObject);
begin
  RichEditConsole.SelectAll;
  UpdateCopyButton;
  RichEditConsole.SetFocus;
end;

// *****************************************************************************
// Purpose: Copies the current terminal selection and briefly displays visual
// confirmation on the Copy button.
// *****************************************************************************
procedure TFormConsole.SpeedButtonCopyClick(Sender: TObject);
begin
  if RichEditConsole.SelLength <= 0 then
    Exit;
  RichEditConsole.CopyToClipboard;
  SpeedButtonCopy.Caption := rsConsoleCopied;
  FCopyFeedbackUntil := GetTickCount64 + 900;
  RichEditConsole.SetFocus;
end;

// *****************************************************************************
// Purpose: Saves the currently rendered plain-text console output as UTF-8.
// *****************************************************************************
procedure TFormConsole.SpeedButtonSaveClick(Sender: TObject);
begin
  if GetTextLength = 0 then
    Exit;

  SaveDialogLog.FileName := Format(rsConsoleDefaultLogFileName,
    [FormatDateTime('yyyymmdd-hhnnss', Now)]);
  if Assigned(ProjectList) and Assigned(ProjectList.Current) then
    SaveDialogLog.InitialDir := ExtractFilePath(ProjectList.Current.FileName);
  if not SaveDialogLog.Execute(Handle) then
    Exit;

  try
    TFile.WriteAllText(SaveDialogLog.FileName, RichEditConsole.Text,
      TEncoding.UTF8);
  except
    on E: Exception do
      Application.MessageBox(PChar(Format(rsConsoleSaveLogError,
        [E.Message])), PChar(rsMessageBoxError), MB_OK or MB_ICONERROR);
  end;
  RichEditConsole.SetFocus;
end;

// *****************************************************************************
// Purpose: Toggles automatic following and returns immediately to the newest
// output when the user enables it from the toolbar.
// *****************************************************************************
procedure TFormConsole.SpeedButtonFollowClick(Sender: TObject);
begin
  SetFollowOutput(SpeedButtonFollow.Down, SpeedButtonFollow.Down);
  RichEditConsole.SetFocus;
end;

// *****************************************************************************
// Purpose: Stops the active integrated command from the console toolbar.
// *****************************************************************************
procedure TFormConsole.SpeedButtonStopClick(Sender: TObject);
begin
  StopCommand;
end;

// *****************************************************************************
// Purpose: Reports whether the owned ConPTY session currently has a running
// client process.
// *****************************************************************************
function TFormConsole.GetRunning: Boolean;
begin
  Result := Assigned(FSession) and FSession.Running;
end;

// *****************************************************************************
// Purpose: Returns the process identifier exposed by the current ConPTY
// session, or zero when the session is idle.
// *****************************************************************************
function TFormConsole.GetProcessId: Cardinal;
begin
  if Assigned(FSession) then
    Result := FSession.ProcessId
  else
    Result := 0;
end;

// *****************************************************************************
// Purpose: Loads the current project's integrated-console preferences, applies
// colors and font, and refreshes terminal size and scrollback behavior.
// *****************************************************************************
procedure TFormConsole.ApplyPreferences;
var
  CurrentProject: TProject;
  ForegroundColor: Integer;
  BackgroundColor: Integer;
  FontName: string;
  FontSize: Integer;
  SavedSelectionStart: Integer;
  SavedSelectionLength: Integer;
  SavedReadOnly: Boolean;
begin
  CurrentProject := nil;
  if Assigned(ProjectList) then
    CurrentProject := ProjectList.Current;

  ForegroundColor := ciDefaultIntConsoleForegroundColor;
  BackgroundColor := ciDefaultIntConsoleBackgroundColor;
  FontName := csDefaultIntConsoleFontName;
  FontSize := ciDefaultIntConsoleFontSize;
  FScrollbackLines := ciDefaultIntConsoleScrollbackLines;
  FClearOnCommandStart := cbDefaultIntConsoleClearOnStart;

  if Assigned(CurrentProject) then
  begin
    ForegroundColor := CurrentProject.GetOption(
      csKeyIntConsoleForegroundColor, ForegroundColor);
    BackgroundColor := CurrentProject.GetOption(
      csKeyIntConsoleBackgroundColor, BackgroundColor);
    FontName := CurrentProject.GetOption(csKeyIntConsoleFontName, FontName);
    FontSize := EnsureRange(CurrentProject.GetOption(
      csKeyIntConsoleFontSize, FontSize), ciMinIntConsoleFontSize,
      ciMaxIntConsoleFontSize);
    FScrollbackLines := EnsureRange(CurrentProject.GetOption(
      csKeyIntConsoleScrollbackLines, FScrollbackLines),
      ciMinIntConsoleScrollbackLines, ciMaxIntConsoleScrollbackLines);
    FClearOnCommandStart := CurrentProject.GetOption(
      csKeyIntConsoleClearOnStart, FClearOnCommandStart);
  end;

  if Screen.Fonts.IndexOf(FontName) < 0 then
    FontName := csDefaultIntConsoleFontName;
  FDefaultForeground := TColor(ForegroundColor);
  FDefaultBackground := TColor(BackgroundColor);
  RichEditConsole.Color := FDefaultBackground;
  RichEditConsole.Font.Name := FontName;
  RichEditConsole.Font.Size := FontSize;
  RichEditConsole.Font.Color := FDefaultForeground;

  // Font changes are safe to apply to existing output because they preserve
  // the per-range foreground and background colors emitted through ANSI SGR.
  if GetTextLength > 0 then
  begin
    SavedSelectionStart := RichEditConsole.SelStart;
    SavedSelectionLength := RichEditConsole.SelLength;
    SavedReadOnly := RichEditConsole.ReadOnly;
    SendMessage(RichEditConsole.Handle, WM_SETREDRAW, 0, 0);
    RichEditConsole.ReadOnly := False;
    try
      RichEditConsole.SelectAll;
      RichEditConsole.SelAttributes.Name := FontName;
      RichEditConsole.SelAttributes.Size := FontSize;
      RichEditConsole.SelStart := Min(SavedSelectionStart, GetTextLength);
      RichEditConsole.SelLength := Min(SavedSelectionLength,
        GetTextLength - RichEditConsole.SelStart);
    finally
      RichEditConsole.ReadOnly := SavedReadOnly;
      SendMessage(RichEditConsole.Handle, WM_SETREDRAW, 1, 0);
      RichEditConsole.Invalidate;
    end;
  end;

  TimerUI.Interval := ActivityFrameMilliseconds;
  ResizeSession;
  PaintBoxActivity.Invalidate;
end;

// *****************************************************************************
// Purpose: Clears previous output, initializes the command header and timing,
// starts a new ConPTY session, and transfers focus to the terminal.
// *****************************************************************************
procedure TFormConsole.StartCommand(const CommandLine, CurrentDirectory,
  DisplayTitle: string);
begin
  if not Assigned(FSession) then
    raise EInvalidOperation.Create(rsConsoleNotInitialized);
  ApplyPreferences;
  SetFollowOutput(True, False);
  if FClearOnCommandStart then
    ClearTerminal
  else
  begin
    RichEditConsole.ReadOnly := False;
    try
      FCursorPosition := GetTextLength;
      FSavedCursorPosition := FCursorPosition;
      ResetParser;
      if FCursorPosition > 0 then
        ReplaceAtCursor(sLineBreak);
    finally
      RichEditConsole.ReadOnly := True;
    end;
    UpdateSaveButton;
  end;
  FStopRequested := False;
  FSessionTitle := DisplayTitle;
  LabelTitle.Caption := DisplayTitle;
  FStartedTick := GetTickCount64;
  SetStatus(Format(rsConsoleStatusRunning, [0, 0]), csRunning);
  Show;
  ResizeSession;
  try
    FSession.Start(CommandLine, CurrentDirectory, 120, 30);
    ResizeSession;
  except
    SetStatus(rsConsoleStatusUnableToStart, csError);
    raise;
  end;
  RichEditConsole.SetFocus;
end;

// *****************************************************************************
// Purpose: Records a user-requested stop, terminates the active session, and
// changes the console state to interrupted.
// *****************************************************************************
procedure TFormConsole.StopCommand;
begin
  FStopRequested := True;
  if Assigned(FSession) then
    FSession.Stop;
  SetStatus(rsConsoleStatusStopped, csInterrupted);
end;

// *****************************************************************************
// Purpose: Persists the hidden docking-form state and synchronizes the related
// Notepad++ menu item when the console is closed.
// *****************************************************************************
procedure TFormConsole.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  if Action = caHide then
  begin
    ConfigIniFile.WriteBool(csSectionGeneral, csKeyConsoleWindow, False);
    Plugin.CheckMenuItem(Plugin.GetIndexFromFuncItemName(fiShowHideConsole),
      False);
  end;
end;

// *****************************************************************************
// Purpose: Propagates docking-form size changes to the pseudoconsole.
// *****************************************************************************
procedure TFormConsole.FormResize(Sender: TObject);
begin
  ResizeSession;
end;

// *****************************************************************************
// Purpose: Converts the terminal client area to character rows and columns and
// applies the resulting dimensions to the ConPTY session.
// *****************************************************************************
procedure TFormConsole.ResizeSession;
var
  CharacterWidth: Integer;
  CharacterHeight: Integer;
  Columns: Integer;
  Rows: Integer;
begin
  if not RichEditConsole.HandleAllocated then
    Exit;
  Canvas.Font.Assign(RichEditConsole.Font);
  CharacterWidth := Max(1, Canvas.TextWidth('M'));
  CharacterHeight := Max(1, Canvas.TextHeight('Mg'));
  Columns := Max(1, RichEditConsole.ClientWidth div CharacterWidth);
  Rows := Max(1, RichEditConsole.ClientHeight div CharacterHeight);
  if Columns > High(SmallInt) then
    Columns := High(SmallInt);
  if Rows > High(SmallInt) then
    Rows := High(SmallInt);
  FTerminalRows := Rows;
  if Assigned(FSession) then
    FSession.Resize(Columns, Rows);
end;

// *****************************************************************************
// Purpose: Accepts ownership of an output chunk, discards stale generations,
// renders current data, and releases the transferred payload.
// *****************************************************************************
procedure TFormConsole.WMConPtyOutput(var Message: TMessage);
var
  Chunk: TConPtyOutputChunk;
begin
  Chunk := TConPtyOutputChunk(Message.LParam);
  try
    if Assigned(FSession) and (Chunk.Generation = FSession.Generation) then
    begin
      ProcessOutput(Chunk.Data);
      NotifyOutputActivity;
    end;
  finally
    Chunk.Free;
  end;
end;

// *****************************************************************************
// Purpose: Maps the child-process exit code and stop reason to the appropriate
// completed, interrupted, or error console state.
// *****************************************************************************
procedure TFormConsole.WMConPtyExit(var Message: TMessage);
var
  ExitCode: Cardinal;
  WasStopped: Boolean;
begin
  if not Assigned(FSession) or
    (Cardinal(Message.LParam) <> FSession.Generation) then
    Exit;
  ExitCode := Cardinal(Message.WParam);
  WasStopped := FStopRequested;
  FSession.Stop;
  FStopRequested := False;
  if WasStopped then
    SetStatus(rsConsoleStatusStopped, csInterrupted)
  else if ExitCode = 0 then
    SetStatus(rsConsoleStatusCompleted, csReady)
  else if ExitCode = Cardinal(-1) then
    SetStatus(rsConsoleStatusStopped, csInterrupted)
  else
    SetStatus(Format(rsConsoleStatusExitedWithCode, [ExitCode]), csError);
end;

// *****************************************************************************
// Purpose: Clears rendered output and resets terminal cursor and parser state
// without changing the lifecycle state of the active session.
// *****************************************************************************
procedure TFormConsole.ClearTerminal;
begin
  RichEditConsole.ReadOnly := False;
  try
    RichEditConsole.Clear;
  finally
    RichEditConsole.ReadOnly := True;
  end;
  FCursorPosition := 0;
  FSavedCursorPosition := 0;
  ResetParser;
  UpdateSaveButton;
end;

// *****************************************************************************
// Purpose: Displays the neutral activity bars without changing process state.
// New output from a running session reactivates the animated indicator.
// *****************************************************************************
procedure TFormConsole.ResetActivityIndicator;
begin
  FActivityReset := True;
  FLastActivityPaintTick := 0;
  PaintBoxActivity.Invalidate;
end;

// *****************************************************************************
// Purpose: Enables the Copy command only while the terminal has a selection.
// *****************************************************************************
procedure TFormConsole.UpdateCopyButton;
begin
  SpeedButtonCopy.Enabled := RichEditConsole.SelLength > 0;
end;

// *****************************************************************************
// Purpose: Enables log saving only while the console contains rendered text.
// *****************************************************************************
procedure TFormConsole.UpdateSaveButton;
begin
  SpeedButtonSave.Enabled := GetTextLength > 0;
end;

// *****************************************************************************
// Purpose: Keeps Copy-button availability synchronized with the current text
// selection.
// *****************************************************************************
procedure TFormConsole.RichEditConsoleSelectionChange(Sender: TObject);
begin
  UpdateCopyButton;
end;

// *****************************************************************************
// Purpose: Records incoming-output activity and requests immediate animation
// repaints when sustained message traffic delays the UI timer.
// *****************************************************************************
procedure TFormConsole.NotifyOutputActivity;
var
  CurrentTick: UInt64;
begin
  CurrentTick := GetTickCount64;
  if FActivityReset and (FConsoleStatus = csRunning) then
  begin
    FActivityReset := False;
    FLastActivityPaintTick := 0;
  end;
  if (FConsoleStatus = csRunning) and
    ((FLastActivityPaintTick = 0) or
    (CurrentTick - FLastActivityPaintTick >= ActivityFrameMilliseconds)) then
  begin
    // WM_TIMER is low priority and can be starved by sustained ConPTY output.
    // Repaint from the output handler as well, but throttle it to keep parsing
    // responsive during very chatty log sessions.
    FLastActivityPaintTick := CurrentTick;
    PaintBoxActivity.Repaint;
  end;
end;

// *****************************************************************************
// Purpose: Updates the running caption with elapsed time only when its value
// changes.
// *****************************************************************************
procedure TFormConsole.UpdateRunningStatus;
var
  ElapsedSeconds: UInt64;
  Minutes: Integer;
  Seconds: Integer;
  StatusText: string;
begin
  if FConsoleStatus <> csRunning then
    Exit;
  ElapsedSeconds := (GetTickCount64 - FStartedTick) div 1000;
  Minutes := Integer(ElapsedSeconds div 60);
  Seconds := Integer(ElapsedSeconds mod 60);
  StatusText := Format(rsConsoleStatusRunning, [Minutes, Seconds]);
  if LabelStatus.Caption <> StatusText then
    LabelStatus.Caption := StatusText;
end;

// *****************************************************************************
// Purpose: Advances running-state visuals and restores the Copy button after
// its temporary confirmation caption expires.
// *****************************************************************************
procedure TFormConsole.TimerUITimer(Sender: TObject);
var
  CurrentTick: UInt64;
begin
  CurrentTick := GetTickCount64;
  UpdateRunningStatus;

  if (FConsoleStatus = csRunning) and not FActivityReset and
    ((FLastActivityPaintTick = 0) or
    (CurrentTick - FLastActivityPaintTick >= ActivityFrameMilliseconds)) then
  begin
    FLastActivityPaintTick := CurrentTick;
    PaintBoxActivity.Repaint;
  end;

  if (FCopyFeedbackUntil <> 0) and (CurrentTick >= FCopyFeedbackUntil) then
  begin
    FCopyFeedbackUntil := 0;
    SpeedButtonCopy.Caption := rsConsoleCopy;
    UpdateCopyButton;
  end;
end;

// *****************************************************************************
// Purpose: Draws the animated running wave or the fixed bars associated with
// completed, interrupted, and error states.
// *****************************************************************************
procedure TFormConsole.PaintBoxActivityPaint(Sender: TObject);
var
  Index: Integer;
  BarWidth: Integer;
  BarGap: Integer;
  BarHeight: Integer;
  TotalWidth: Integer;
  Left: Integer;
  Top: Integer;
  Corner: Integer;
  BarColor: TColor;
  CurrentTick: UInt64;
  AnimationElapsed: UInt64;
  BarDelay: UInt64;
  BarCyclePosition: UInt64;
  AnimationPosition: Double;
  EasedPosition: Double;
  UnscaledBarHeight: Integer;
begin
  PaintBoxActivity.Canvas.Brush.Style := bsSolid;
  PaintBoxActivity.Canvas.Brush.Color := PanelCommands.Color;
  PaintBoxActivity.Canvas.FillRect(PaintBoxActivity.ClientRect);

  if FActivityReset then
    BarColor := FInactiveColor
  else
    case FConsoleStatus of
      csRunning: BarColor := FActivityColor;
      csInterrupted, csError: BarColor := FErrorColor;
    else
      BarColor := FInactiveColor;
    end;

  BarWidth := Max(3, MulDiv(3, CurrentPPI, 96));
  BarGap := Max(2, MulDiv(2, CurrentPPI, 96));
  Corner := Max(2, MulDiv(2, CurrentPPI, 96));
  TotalWidth := BarWidth * 3 + BarGap * 2;
  Left := (PaintBoxActivity.ClientWidth - TotalWidth) div 2;
  CurrentTick := GetTickCount64;
  if CurrentTick >= FStartedTick then
    AnimationElapsed := CurrentTick - FStartedTick
  else
    AnimationElapsed := 0;

  PaintBoxActivity.Canvas.Pen.Style := psClear;
  PaintBoxActivity.Canvas.Brush.Color := BarColor;
  for Index := 0 to 2 do
  begin
    if FActivityReset then
      BarHeight := MulDiv(5, CurrentPPI, 96)
    else if FConsoleStatus = csRunning then
    begin
      // Use a 760 ms ease-in-out wave with a 130 ms stagger between bars.
      BarDelay := UInt64(Index * ActivityBarDelayMilliseconds);
      if AnimationElapsed < BarDelay then
        AnimationPosition := 0
      else
      begin
        BarCyclePosition := (AnimationElapsed - BarDelay) mod
          UInt64(ActivityPeriodMilliseconds);
        AnimationPosition := BarCyclePosition /
          ActivityPeriodMilliseconds;
      end;
      EasedPosition := 0.5 - (0.5 * Cos(AnimationPosition * 2 * Pi));
      UnscaledBarHeight := ActivityMinBarHeight +
        Round((ActivityMaxBarHeight - ActivityMinBarHeight) *
        EasedPosition);
      BarHeight := MulDiv(UnscaledBarHeight, CurrentPPI, 96);
    end
    else if FConsoleStatus in [csInterrupted, csError] then
      BarHeight := MulDiv(12, CurrentPPI, 96)
    else
      BarHeight := MulDiv(5, CurrentPPI, 96);
    Top := (PaintBoxActivity.ClientHeight - BarHeight) div 2;
    PaintBoxActivity.Canvas.RoundRect(Left, Top, Left + BarWidth,
      Top + BarHeight, Corner, Corner);
    Inc(Left, BarWidth + BarGap);
  end;
  PaintBoxActivity.Canvas.Pen.Style := psSolid;
  FLastActivityPaintTick := CurrentTick;
end;

// *****************************************************************************
// Purpose: Restores the ANSI parser, UTF-8 buffer, carriage-return tracking,
// and terminal style to their initial state.
// *****************************************************************************
procedure TFormConsole.ResetParser;
begin
  FParserState := apsText;
  FCsiBuffer := '';
  SetLength(FUtf8Buffer, 0);
  FPendingCarriageReturn := False;
  ResetAnsiStyle;
end;

// *****************************************************************************
// Purpose: Restores the active SGR attributes to the terminal defaults.
// *****************************************************************************
procedure TFormConsole.ResetAnsiStyle;
begin
  FCurrentStyle := Default(TTerminalStyle);
end;

// *****************************************************************************
// Purpose: Appends one raw byte to the UTF-8 sequence awaiting decoding.
// *****************************************************************************
procedure TFormConsole.AddUtf8Byte(const Value: Byte);
var
  BufferLength: Integer;
begin
  BufferLength := Length(FUtf8Buffer);
  SetLength(FUtf8Buffer, BufferLength + 1);
  FUtf8Buffer[BufferLength] := Value;
end;

// *****************************************************************************
// Purpose: Decodes and renders the complete UTF-8 prefix, optionally flushing
// an incomplete tail instead of preserving it for subsequent output.
// *****************************************************************************
procedure TFormConsole.FlushUtf8(const FlushIncomplete: Boolean);
var
  ByteCount: Integer;
  CompleteBytes: TBytes;
  Text: string;
begin
  if Length(FUtf8Buffer) = 0 then
    Exit;
  if FlushIncomplete then
    ByteCount := Length(FUtf8Buffer)
  else
    ByteCount := CompleteUtf8Length(FUtf8Buffer);
  if ByteCount = 0 then
    Exit;

  CompleteBytes := Copy(FUtf8Buffer, 0, ByteCount);
  Text := TEncoding.UTF8.GetString(CompleteBytes);
  FUtf8Buffer := Copy(FUtf8Buffer, ByteCount,
    Length(FUtf8Buffer) - ByteCount);
  if Text <> '' then
    ReplaceAtCursor(Text);
end;

// *****************************************************************************
// Purpose: Feeds output bytes through the terminal parser under a redraw lock,
// trims scrollback, and schedules automatic bottom scrolling.
// *****************************************************************************
procedure TFormConsole.ProcessOutput(const Data: TBytes);
var
  Index: Integer;
  SavedScrollPosition: TPoint;
  SavedSelectionStart: Integer;
  SavedSelectionLength: Integer;
  TrimmedCharacters: Integer;
  PreserveView: Boolean;
begin
  PreserveView := not FFollowOutput;
  SavedScrollPosition := Default(TPoint);
  SavedSelectionStart := 0;
  SavedSelectionLength := 0;
  if PreserveView then
  begin
    SendMessage(RichEditConsole.Handle, EM_GETSCROLLPOS, 0,
      LPARAM(@SavedScrollPosition));
    SavedSelectionStart := RichEditConsole.SelStart;
    SavedSelectionLength := RichEditConsole.SelLength;
  end;

  RichEditConsole.ReadOnly := False;
  SendMessage(RichEditConsole.Handle, WM_SETREDRAW, 0, 0);
  try
    for Index := 0 to Length(Data) - 1 do
      ProcessByte(Data[Index]);
    FlushUtf8(False);
    TrimmedCharacters := TrimScrollback;
    if FFollowOutput then
    begin
      // The parser's VT cursor is independent from the RichEdit caret and can
      // legitimately point before the backing text end after cursor commands.
      RichEditConsole.SelStart := GetTextLength;
      RichEditConsole.SelLength := 0;
    end
    else
    begin
      SavedSelectionStart := EnsureRange(
        SavedSelectionStart - TrimmedCharacters, 0, GetTextLength);
      RichEditConsole.SelStart := SavedSelectionStart;
      RichEditConsole.SelLength := Min(SavedSelectionLength,
        GetTextLength - SavedSelectionStart);
    end;
    UpdateCopyButton;
    UpdateSaveButton;
  finally
    RichEditConsole.ReadOnly := True;
    SendMessage(RichEditConsole.Handle, WM_SETREDRAW, 1, 0);
    RichEditConsole.Invalidate;
    if FFollowOutput then
    begin
      // RichEdit recalculates its scrollbar after the current window message.
      // Defer and coalesce the scroll so it sees the updated range.
      if not FScrollMessagePending then
        FScrollMessagePending := PostMessage(Handle,
          WM_CONSOLE_SCROLL_BOTTOM, 0, 0);
    end
    else
    begin
      FProgrammaticScroll := True;
      try
        SendMessage(RichEditConsole.Handle, EM_SETSCROLLPOS, 0,
          LPARAM(@SavedScrollPosition));
      finally
        FProgrammaticScroll := False;
      end;
    end;
  end;
end;

// *****************************************************************************
// Purpose: Performs the deferred, coalesced scroll that follows newly rendered
// output to the bottom of the terminal.
// *****************************************************************************
procedure TFormConsole.WMConsoleScrollBottom(var Message: TMessage);
begin
  FScrollMessagePending := False;
  if not RichEditConsole.HandleAllocated or not FFollowOutput then
    Exit;
  FProgrammaticScroll := True;
  try
    RichEditConsole.SelStart := GetTextLength;
    RichEditConsole.SelLength := 0;
    RichEditConsole.Perform(EM_SCROLLCARET, 0, 0);
    RichEditConsole.Perform(EM_LINESCROLL, 0, GetLineCount);
    RichEditConsole.Perform(WM_VSCROLL, SB_BOTTOM, 0);
    RichEditConsole.Update;
  finally
    FProgrammaticScroll := False;
  end;
end;

// *****************************************************************************
// Purpose: Reports whether the RichEdit vertical viewport currently reaches
// the bottom of its scroll range.
// *****************************************************************************
function TFormConsole.IsViewAtBottom: Boolean;
var
  ScrollInfo: TScrollInfo;
  BottomPosition: Integer;
begin
  Result := True;
  if not RichEditConsole.HandleAllocated then
    Exit;
  ScrollInfo := Default(TScrollInfo);
  ScrollInfo.cbSize := SizeOf(ScrollInfo);
  ScrollInfo.fMask := SIF_ALL;
  if not GetScrollInfo(RichEditConsole.Handle, SB_VERT, ScrollInfo) then
    Exit;
  BottomPosition := ScrollInfo.nMax - Max(0, Integer(ScrollInfo.nPage) - 1);
  Result := ScrollInfo.nPos >= BottomPosition;
end;

// *****************************************************************************
// Purpose: Synchronizes the Follow toolbar state and optionally schedules an
// immediate return to the newest rendered output.
// *****************************************************************************
procedure TFormConsole.SetFollowOutput(const Value, ScrollNow: Boolean);
begin
  FFollowOutput := Value;
  SpeedButtonFollow.Down := Value;
  if Value then
    SpeedButtonFollow.Hint := rsConsoleFollowEnabledHint
  else
    SpeedButtonFollow.Hint := rsConsoleFollowPausedHint;

  if Value and ScrollNow and not FScrollMessagePending then
    FScrollMessagePending := PostMessage(Handle,
      WM_CONSOLE_SCROLL_BOTTOM, 0, 0);
end;

// *****************************************************************************
// Purpose: Detects user-originated vertical scrolling and pauses Follow while
// the viewport is away from the last line; reaching the bottom resumes it.
// *****************************************************************************
procedure TFormConsole.RichEditConsoleWindowProc(var Message: TMessage);
var
  UserScrolled: Boolean;
begin
  UserScrolled := not FProgrammaticScroll and
    ((Message.Msg = WM_VSCROLL) or (Message.Msg = WM_MOUSEWHEEL) or
    ((Message.Msg = WM_KEYUP) and
    (Word(Message.WParam) in [VK_UP, VK_DOWN, VK_HOME, VK_END,
    VK_PRIOR, VK_NEXT])));
  FOriginalRichEditWindowProc(Message);
  if UserScrolled then
    SetFollowOutput(IsViewAtBottom, False);
end;

// *****************************************************************************
// Purpose: Incrementally parses UTF-8 data, C0 controls, escape sequences, CSI
// parameters, and OSC payloads from one pseudoconsole output byte.
// *****************************************************************************
procedure TFormConsole.ProcessByte(const Value: Byte);
var
  FinalByte: AnsiChar;
begin
  if FPendingCarriageReturn then
  begin
    if Value = 10 then
    begin
      FPendingCarriageReturn := False;
      CarriageReturn;
      LineFeed;
      Exit;
    end;
    FPendingCarriageReturn := False;
    CarriageReturn;
  end;

  case FParserState of
    apsText:
      case Value of
        7:
          MessageBeep(MB_OK);
        8:
          begin
            FlushUtf8(True);
            MoveCursorHorizontal(-1);
          end;
        9:
          begin
            FlushUtf8(True);
            ReplaceAtCursor(StringOfChar(' ', 8 -
              ((FCursorPosition - GetLineStart(FCursorPosition)) mod 8)));
          end;
        10:
          begin
            FlushUtf8(True);
            LineFeed;
          end;
        13:
          begin
            FlushUtf8(True);
            FPendingCarriageReturn := True;
          end;
        27:
          begin
            FlushUtf8(True);
            FParserState := apsEscape;
          end;
        32..126, 128..255:
          AddUtf8Byte(Value);
      end;
    apsEscape:
      begin
        case AnsiChar(Value) of
          '[':
            begin
              FCsiBuffer := '';
              FParserState := apsCsi;
            end;
          ']': FParserState := apsOsc;
          'c':
            begin
              ClearTerminal;
              FParserState := apsText;
            end;
        else
          FParserState := apsText;
        end;
      end;
    apsCsi:
      begin
        if (Value >= $40) and (Value <= $7E) then
        begin
          FinalByte := AnsiChar(Value);
          ExecuteCsi(FinalByte);
          FCsiBuffer := '';
          FParserState := apsText;
        end
        else if Length(FCsiBuffer) < 128 then
          FCsiBuffer := FCsiBuffer + AnsiChar(Value);
      end;
    apsOsc:
      if Value = 7 then
        FParserState := apsText
      else if Value = 27 then
        FParserState := apsOscEscape;
    apsOscEscape:
      if Value = Ord('\') then
        FParserState := apsText
      else
        FParserState := apsOsc;
  end;
end;

// *****************************************************************************
// Purpose: Returns a CSI parameter by index and uses the supplied default for
// missing or invalid values.
// *****************************************************************************
function TFormConsole.GetCsiParam(const Params: TArray<string>;
  const Index, DefaultValue: Integer): Integer;
begin
  Result := DefaultValue;
  if (Index >= 0) and (Index < Length(Params)) and (Params[Index] <> '') then
    TryStrToInt(Params[Index], Result);
end;

// *****************************************************************************
// Purpose: Applies supported CSI cursor, erase, save/restore, device-report,
// and SGR styling commands to the terminal model.
// *****************************************************************************
procedure TFormConsole.ExecuteCsi(const FinalByte: AnsiChar);
var
  ParameterText: string;
  Params: TArray<string>;
  Index: Integer;
  Value: Integer;
  ColorIndex: Integer;
  RedValue: Integer;
  GreenValue: Integer;
  BlueValue: Integer;
begin
  ParameterText := string(FCsiBuffer);
  while (ParameterText <> '') and CharInSet(ParameterText[1], ['?', '>', '!']) do
    Delete(ParameterText, 1, 1);
  Params := ParameterText.Split([';']);

  case FinalByte of
    'm':
      begin
        if Length(Params) = 0 then
          Params := ['0'];
        Index := 0;
        while Index < Length(Params) do
        begin
          Value := GetCsiParam(Params, Index, 0);
          case Value of
            0: ResetAnsiStyle;
            1: FCurrentStyle.Bold := True;
            3: FCurrentStyle.Italic := True;
            4: FCurrentStyle.Underline := True;
            7: FCurrentStyle.Inverse := True;
            22: FCurrentStyle.Bold := False;
            23: FCurrentStyle.Italic := False;
            24: FCurrentStyle.Underline := False;
            27: FCurrentStyle.Inverse := False;
            30..37:
              begin
                FCurrentStyle.Foreground := AnsiPalette[Value - 30];
                FCurrentStyle.HasForeground := True;
              end;
            39: FCurrentStyle.HasForeground := False;
            40..47:
              begin
                FCurrentStyle.Background := AnsiPalette[Value - 40];
                FCurrentStyle.HasBackground := True;
              end;
            49: FCurrentStyle.HasBackground := False;
            90..97:
              begin
                FCurrentStyle.Foreground := AnsiPalette[Value - 90 + 8];
                FCurrentStyle.HasForeground := True;
              end;
            100..107:
              begin
                FCurrentStyle.Background := AnsiPalette[Value - 100 + 8];
                FCurrentStyle.HasBackground := True;
              end;
            38, 48:
              if GetCsiParam(Params, Index + 1, -1) = 5 then
              begin
                ColorIndex := GetCsiParam(Params, Index + 2, 0);
                if Value = 38 then
                begin
                  FCurrentStyle.Foreground := Ansi256Color(ColorIndex);
                  FCurrentStyle.HasForeground := True;
                end
                else
                begin
                  FCurrentStyle.Background := Ansi256Color(ColorIndex);
                  FCurrentStyle.HasBackground := True;
                end;
                Inc(Index, 2);
              end
              else if GetCsiParam(Params, Index + 1, -1) = 2 then
              begin
                RedValue := EnsureRange(GetCsiParam(Params, Index + 2, 0), 0, 255);
                GreenValue := EnsureRange(GetCsiParam(Params, Index + 3, 0), 0, 255);
                BlueValue := EnsureRange(GetCsiParam(Params, Index + 4, 0), 0, 255);
                if Value = 38 then
                begin
                  FCurrentStyle.Foreground := RGB(RedValue, GreenValue, BlueValue);
                  FCurrentStyle.HasForeground := True;
                end
                else
                begin
                  FCurrentStyle.Background := RGB(RedValue, GreenValue, BlueValue);
                  FCurrentStyle.HasBackground := True;
                end;
                Inc(Index, 4);
              end;
          end;
          Inc(Index);
        end;
      end;
    'A': MoveCursorVertical(-GetCsiParam(Params, 0, 1));
    'B', 'e': MoveCursorVertical(GetCsiParam(Params, 0, 1));
    'C': MoveCursorHorizontal(GetCsiParam(Params, 0, 1));
    'D': MoveCursorHorizontal(-GetCsiParam(Params, 0, 1));
    'E':
      begin
        MoveCursorVertical(GetCsiParam(Params, 0, 1));
        SetCursorColumn(1);
      end;
    'F':
      begin
        MoveCursorVertical(-GetCsiParam(Params, 0, 1));
        SetCursorColumn(1);
      end;
    'G': SetCursorColumn(GetCsiParam(Params, 0, 1));
    'H', 'f': SetCursorPosition(GetCsiParam(Params, 0, 1),
      GetCsiParam(Params, 1, 1));
    'd': SetCursorRow(GetCsiParam(Params, 0, 1));
    'J':
      if GetCsiParam(Params, 0, 0) in [2, 3] then
        ClearTerminal;
    'K': EraseInLine(GetCsiParam(Params, 0, 0));
    's': FSavedCursorPosition := FCursorPosition;
    'u': FCursorPosition := Min(FSavedCursorPosition, GetTextLength);
    'n':
      if GetCsiParam(Params, 0, 0) = 6 then
        SendKeySequence(#27'[1;1R');
  end;
end;

// *****************************************************************************
// Purpose: Queries the current RichEdit text length without copying terminal
// content.
// *****************************************************************************
function TFormConsole.GetTextLength: Integer;
begin
  Result := SendMessage(RichEditConsole.Handle, WM_GETTEXTLENGTH, 0, 0);
end;

// *****************************************************************************
// Purpose: Returns the number of logical RichEdit lines, using one as the
// minimum.
// *****************************************************************************
function TFormConsole.GetLineCount: Integer;
begin
  Result := Max(1, SendMessage(RichEditConsole.Handle, EM_GETLINECOUNT, 0, 0));
end;

// *****************************************************************************
// Purpose: Calculates the first logical line of the current terminal screen
// within the retained scrollback buffer.
// *****************************************************************************
function TFormConsole.GetScreenOriginLine: Integer;
begin
  Result := Max(0, GetLineCount - Max(1, FTerminalRows));
end;

// *****************************************************************************
// Purpose: Appends line breaks until the requested zero-based logical line is
// available in the RichEdit buffer.
// *****************************************************************************
procedure TFormConsole.EnsureLineExists(const LineNumber: Integer);
var
  TextEnd: Integer;
begin
  while GetLineCount <= LineNumber do
  begin
    TextEnd := GetTextLength;
    SendMessage(RichEditConsole.Handle, EM_SETSEL, TextEnd, TextEnd);
    SendMessage(RichEditConsole.Handle, EM_REPLACESEL, 0,
      LPARAM(PChar(sLineBreak)));
  end;
end;

// *****************************************************************************
// Purpose: Resolves the character offset at the beginning of the containing
// logical line.
// *****************************************************************************
function TFormConsole.GetLineStart(const CharacterPosition: Integer): Integer;
var
  LineNumber: Integer;
begin
  LineNumber := SendMessage(RichEditConsole.Handle, EM_LINEFROMCHAR,
    CharacterPosition, 0);
  Result := SendMessage(RichEditConsole.Handle, EM_LINEINDEX, LineNumber, 0);
  if Result < 0 then
    Result := 0;
end;

// *****************************************************************************
// Purpose: Resolves the character offset immediately after the containing line.
// *****************************************************************************
function TFormConsole.GetLineEnd(const CharacterPosition: Integer): Integer;
begin
  Result := GetLineStart(CharacterPosition) +
    SendMessage(RichEditConsole.Handle, EM_LINELENGTH, CharacterPosition, 0);
end;

// *****************************************************************************
// Purpose: Emulates terminal overwrite semantics at the virtual cursor, applies
// the active style, and advances the cursor past the rendered text.
// *****************************************************************************
procedure TFormConsole.ReplaceAtCursor(const Text: string);
var
  LineEnd: Integer;
  ReplaceLength: Integer;
  StartPosition: Integer;
begin
  if Text = '' then
    Exit;
  FCursorPosition := Min(FCursorPosition, GetTextLength);
  LineEnd := GetLineEnd(FCursorPosition);
  ReplaceLength := Min(Length(Text), Max(0, LineEnd - FCursorPosition));
  StartPosition := FCursorPosition;

  SendMessage(RichEditConsole.Handle, EM_SETSEL, StartPosition,
    StartPosition + ReplaceLength);
  SendMessage(RichEditConsole.Handle, EM_REPLACESEL, 0, LPARAM(PChar(Text)));
  ApplyCurrentStyle(StartPosition, Length(Text));
  FCursorPosition := StartPosition + Length(Text);
end;

// *****************************************************************************
// Purpose: Builds a RichEdit character format from the active terminal style
// and applies it to the specified text range.
// *****************************************************************************
procedure TFormConsole.ApplyCurrentStyle(const StartPosition,
  TextLength: Integer);
var
  CharFormat: TCharFormat2;
  Foreground: TColor;
  Background: TColor;
  TemporaryColor: TColor;
begin
  if TextLength <= 0 then
    Exit;
  if FCurrentStyle.HasForeground then
    Foreground := FCurrentStyle.Foreground
  else
    Foreground := FDefaultForeground;
  if FCurrentStyle.HasBackground then
    Background := FCurrentStyle.Background
  else
    Background := FDefaultBackground;
  if FCurrentStyle.Inverse then
  begin
    TemporaryColor := Foreground;
    Foreground := Background;
    Background := TemporaryColor;
  end;

  FillChar(CharFormat, SizeOf(CharFormat), 0);
  CharFormat.cbSize := SizeOf(CharFormat);
  CharFormat.dwMask := CFM_COLOR or CFM_BACKCOLOR or CFM_BOLD or CFM_ITALIC or
    CFM_UNDERLINE;
  CharFormat.crTextColor := ColorToRGB(Foreground);
  CharFormat.crBackColor := ColorToRGB(Background);
  if FCurrentStyle.Bold then
    CharFormat.dwEffects := CharFormat.dwEffects or CFE_BOLD;
  if FCurrentStyle.Italic then
    CharFormat.dwEffects := CharFormat.dwEffects or CFE_ITALIC;
  if FCurrentStyle.Underline then
    CharFormat.dwEffects := CharFormat.dwEffects or CFE_UNDERLINE;

  SendMessage(RichEditConsole.Handle, EM_SETSEL, StartPosition,
    StartPosition + TextLength);
  SendMessage(RichEditConsole.Handle, EM_SETCHARFORMAT, SCF_SELECTION,
    LPARAM(@CharFormat));
  SendMessage(RichEditConsole.Handle, EM_SETSEL, FCursorPosition,
    FCursorPosition);
end;

// *****************************************************************************
// Purpose: Moves the virtual terminal cursor to the start of its current line.
// *****************************************************************************
procedure TFormConsole.CarriageReturn;
begin
  FCursorPosition := GetLineStart(FCursorPosition);
end;

// *****************************************************************************
// Purpose: Moves the cursor to the same column on the next logical line,
// creating the line and any required column padding.
// *****************************************************************************
procedure TFormConsole.LineFeed;
var
  CurrentLine: Integer;
  Column: Integer;
  TargetLine: Integer;
  TargetLineStart: Integer;
  TargetLineEnd: Integer;
begin
  CurrentLine := SendMessage(RichEditConsole.Handle, EM_LINEFROMCHAR,
    FCursorPosition, 0);
  Column := FCursorPosition - GetLineStart(FCursorPosition);
  TargetLine := CurrentLine + 1;
  EnsureLineExists(TargetLine);
  TargetLineStart := SendMessage(RichEditConsole.Handle, EM_LINEINDEX,
    TargetLine, 0);
  TargetLineEnd := TargetLineStart + SendMessage(RichEditConsole.Handle,
    EM_LINELENGTH, TargetLineStart, 0);
  if TargetLineStart + Column <= TargetLineEnd then
    FCursorPosition := TargetLineStart + Column
  else
  begin
    FCursorPosition := TargetLineEnd;
    ReplaceAtCursor(StringOfChar(' ', TargetLineStart + Column -
      TargetLineEnd));
  end;
end;

// *****************************************************************************
// Purpose: Moves the cursor horizontally while constraining it to the current
// logical line.
// *****************************************************************************
procedure TFormConsole.MoveCursorHorizontal(const Delta: Integer);
var
  LineStart: Integer;
  LineEnd: Integer;
begin
  LineStart := GetLineStart(FCursorPosition);
  LineEnd := GetLineEnd(FCursorPosition);
  FCursorPosition := EnsureRange(FCursorPosition + Delta, LineStart, LineEnd);
end;

// *****************************************************************************
// Purpose: Moves the cursor vertically while retaining its current column and
// constraining the destination to existing terminal content.
// *****************************************************************************
procedure TFormConsole.MoveCursorVertical(const Delta: Integer);
var
  CurrentLine: Integer;
  TargetLine: Integer;
  Column: Integer;
  TargetLineStart: Integer;
  TargetLineEnd: Integer;
begin
  CurrentLine := SendMessage(RichEditConsole.Handle, EM_LINEFROMCHAR,
    FCursorPosition, 0);
  Column := FCursorPosition - GetLineStart(FCursorPosition);
  TargetLine := Max(0, CurrentLine + Delta);
  EnsureLineExists(TargetLine);
  TargetLineStart := SendMessage(RichEditConsole.Handle, EM_LINEINDEX,
    TargetLine, 0);
  TargetLineEnd := TargetLineStart + SendMessage(RichEditConsole.Handle,
    EM_LINELENGTH, TargetLineStart, 0);
  if TargetLineStart + Column <= TargetLineEnd then
    FCursorPosition := TargetLineStart + Column
  else
  begin
    FCursorPosition := TargetLineEnd;
    ReplaceAtCursor(StringOfChar(' ', TargetLineStart + Column -
      TargetLineEnd));
  end;
end;

// *****************************************************************************
// Purpose: Places the cursor at a one-based column on its current line, padding
// the line with spaces when required.
// *****************************************************************************
procedure TFormConsole.SetCursorColumn(const Column: Integer);
var
  LineStart: Integer;
  LineEnd: Integer;
  TargetPosition: Integer;
begin
  LineStart := GetLineStart(FCursorPosition);
  LineEnd := GetLineEnd(FCursorPosition);
  TargetPosition := LineStart + Max(0, Column - 1);
  if TargetPosition > LineEnd then
  begin
    FCursorPosition := LineEnd;
    ReplaceAtCursor(StringOfChar(' ', TargetPosition - LineEnd));
  end
  else
    FCursorPosition := TargetPosition;
end;

// *****************************************************************************
// Purpose: Places the cursor at one-based screen-relative row and column
// coordinates, creating missing logical lines as needed.
// *****************************************************************************
procedure TFormConsole.SetCursorPosition(const Row, Column: Integer);
var
  TargetLine: Integer;
  TargetLineStart: Integer;
begin
  TargetLine := GetScreenOriginLine + Max(1, Row) - 1;
  EnsureLineExists(TargetLine);
  TargetLineStart := SendMessage(RichEditConsole.Handle, EM_LINEINDEX,
    TargetLine, 0);
  FCursorPosition := TargetLineStart;
  SetCursorColumn(Column);
end;

// *****************************************************************************
// Purpose: Changes the cursor's screen-relative row while preserving its
// column.
// *****************************************************************************
procedure TFormConsole.SetCursorRow(const Row: Integer);
var
  Column: Integer;
begin
  Column := FCursorPosition - GetLineStart(FCursorPosition) + 1;
  SetCursorPosition(Row, Column);
end;

// *****************************************************************************
// Purpose: Emulates the supported CSI erase-in-line modes without changing the
// virtual cursor position.
// *****************************************************************************
procedure TFormConsole.EraseInLine(const Mode: Integer);
var
  LineStart: Integer;
  LineEnd: Integer;
  EraseStart: Integer;
  EraseEnd: Integer;
begin
  LineStart := GetLineStart(FCursorPosition);
  LineEnd := GetLineEnd(FCursorPosition);
  case Mode of
    1:
      begin
        EraseStart := LineStart;
        EraseEnd := FCursorPosition;
      end;
    2:
      begin
        EraseStart := LineStart;
        EraseEnd := LineEnd;
        FCursorPosition := LineStart;
      end;
  else
    EraseStart := FCursorPosition;
    EraseEnd := LineEnd;
  end;
  if EraseEnd > EraseStart then
  begin
    SendMessage(RichEditConsole.Handle, EM_SETSEL, EraseStart, EraseEnd);
    SendMessage(RichEditConsole.Handle, EM_REPLACESEL, 0,
      LPARAM(PChar(StringOfChar(' ', EraseEnd - EraseStart))));
  end;
end;

// *****************************************************************************
// Purpose: Removes old content after the configured line limit or the hard
// character safety cap, adjusts cursor offsets, and returns removed characters.
// *****************************************************************************
function TFormConsole.TrimScrollback: Integer;
var
  TextLength: Integer;
  LineCount: Integer;
  TrimMargin: Integer;
  TrimLineCount: Integer;
  TrimEnd: Integer;
begin
  Result := 0;
  TextLength := GetTextLength;
  LineCount := GetLineCount;
  TrimMargin := EnsureRange(FScrollbackLines div 10, 25, 250);
  if (LineCount <= FScrollbackLines + TrimMargin) and
    (TextLength <= MaxTerminalCharacters) then
    Exit;

  if LineCount > FScrollbackLines + TrimMargin then
  begin
    TrimLineCount := LineCount - FScrollbackLines;
    TrimEnd := SendMessage(RichEditConsole.Handle, EM_LINEINDEX,
      TrimLineCount, 0);
  end
  else
  begin
    TrimEnd := SendMessage(RichEditConsole.Handle, EM_LINEINDEX,
      SendMessage(RichEditConsole.Handle, EM_LINEFROMCHAR,
      TerminalCharacterTrimChunk, 0) + 1, 0);
    if TrimEnd <= 0 then
      TrimEnd := Min(TerminalCharacterTrimChunk, TextLength);
  end;
  if TrimEnd <= 0 then
    Exit;
  SendMessage(RichEditConsole.Handle, EM_SETSEL, 0, TrimEnd);
  SendMessage(RichEditConsole.Handle, EM_REPLACESEL, 0, LPARAM(PChar('')));
  FCursorPosition := Max(0, FCursorPosition - TrimEnd);
  FSavedCursorPosition := Max(0, FSavedCursorPosition - TrimEnd);
  Result := TrimEnd;
end;

// *****************************************************************************
// Purpose: Sends an encoded keyboard sequence only while the ConPTY client is
// running.
// *****************************************************************************
procedure TFormConsole.SendKeySequence(const Sequence: string);
begin
  if Assigned(FSession) and FSession.Running then
    FSession.WriteText(Sequence);
end;

// *****************************************************************************
// Purpose: Translates navigation, function, modifier, copy, and paste keys into
// terminal input while preventing RichEdit from editing locally.
// *****************************************************************************
procedure TFormConsole.RichEditConsoleKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  ControlCharacter: Char;
begin
  FSuppressNextKeyPress := False;
  if not Assigned(FSession) or not FSession.Running then
    Exit;

  if (ssCtrl in Shift) and (Key = Ord('C')) then
  begin
    if RichEditConsole.SelLength > 0 then
      RichEditConsole.CopyToClipboard
    else
      SendKeySequence(#3);
    Key := 0;
    FSuppressNextKeyPress := True;
    Exit;
  end;
  if (ssCtrl in Shift) and (Key = Ord('V')) then
  begin
    if Clipboard.HasFormat(CF_UNICODETEXT) then
      SendKeySequence(Clipboard.AsText);
    Key := 0;
    FSuppressNextKeyPress := True;
    Exit;
  end;
  if (ssCtrl in Shift) and (Key >= Ord('A')) and (Key <= Ord('Z')) then
  begin
    ControlCharacter := Char(Key - Ord('A') + 1);
    SendKeySequence(ControlCharacter);
    Key := 0;
    FSuppressNextKeyPress := True;
    Exit;
  end;

  case Key of
    VK_UP: SendKeySequence(#27'[A');
    VK_DOWN: SendKeySequence(#27'[B');
    VK_RIGHT: SendKeySequence(#27'[C');
    VK_LEFT: SendKeySequence(#27'[D');
    VK_HOME: SendKeySequence(#27'[H');
    VK_END: SendKeySequence(#27'[F');
    VK_INSERT: SendKeySequence(#27'[2~');
    VK_DELETE: SendKeySequence(#27'[3~');
    VK_PRIOR: SendKeySequence(#27'[5~');
    VK_NEXT: SendKeySequence(#27'[6~');
    VK_F1: SendKeySequence(#27'OP');
    VK_F2: SendKeySequence(#27'OQ');
    VK_F3: SendKeySequence(#27'OR');
    VK_F4: SendKeySequence(#27'OS');
    VK_F5: SendKeySequence(#27'[15~');
    VK_F6: SendKeySequence(#27'[17~');
    VK_F7: SendKeySequence(#27'[18~');
    VK_F8: SendKeySequence(#27'[19~');
    VK_F9: SendKeySequence(#27'[20~');
    VK_F10: SendKeySequence(#27'[21~');
    VK_F11: SendKeySequence(#27'[23~');
    VK_F12: SendKeySequence(#27'[24~');
  else
    Exit;
  end;
  Key := 0;
  FSuppressNextKeyPress := True;
end;

// *****************************************************************************
// Purpose: Forwards printable and control characters not already handled by
// KeyDown and suppresses their local insertion into the RichEdit control.
// *****************************************************************************
procedure TFormConsole.RichEditConsoleKeyPress(Sender: TObject; var Key: Char);
begin
  if FSuppressNextKeyPress then
  begin
    FSuppressNextKeyPress := False;
    Key := #0;
    Exit;
  end;
  if not Assigned(FSession) or not FSession.Running then
    Exit;
  case Key of
    #10: SendKeySequence(#13);
    #13: SendKeySequence(#13);
  else
    SendKeySequence(Key);
  end;
  Key := #0;
end;

// *****************************************************************************
// Purpose: Applies the active Notepad++ palette and button resources, then
// restores the current project's terminal colors and font preferences.
// *****************************************************************************
procedure TFormConsole.ToggleDarkMode;
var
  DarkModeColors: TNppDarkModeColors;
begin
  inherited ToggleDarkMode;

  AssignWindowIcon(Icon);
  AssignImageResources(VirtualImageList);

  if Plugin.IsDarkModeEnabled then
  begin
    DarkModeColors := Default(TNppDarkModeColors);
    Plugin.GetDarkModeColors(@DarkModeColors);
    Color := TColor(DarkModeColors.Background);
    Font.Color := TColor(DarkModeColors.Text);
    FDefaultBackground := TColor(DarkModeColors.Background);
    FDefaultForeground := TColor(DarkModeColors.Text);
    PanelCommands.Color := TColor(DarkModeColors.SofterBackground);
    LabelTitle.Font.Color := TColor(DarkModeColors.Text);
    LabelStatus.Font.Color := TColor(DarkModeColors.DarkerText);
    SpeedButtonSelectAll.Font.Color := TColor(DarkModeColors.Text);
    SpeedButtonCopy.Font.Color := TColor(DarkModeColors.Text);
    SpeedButtonSave.Font.Color := TColor(DarkModeColors.Text);
    SpeedButtonFollow.Font.Color := TColor(DarkModeColors.Text);
    SpeedButtonClear.Font.Color := TColor(DarkModeColors.Text);
    SpeedButtonStop.Font.Color := RGB(255, 156, 163);
    FActivityColor := RGB(85, 214, 140);
    FInactiveColor := TColor(DarkModeColors.DisabledText);
    FErrorColor := RGB(240, 106, 115);
  end
  else
  begin
    Color := clBtnFace;
    Font.Color := clWindowText;
    FDefaultBackground := clWindow;
    FDefaultForeground := clWindowText;
    PanelCommands.Color := clBtnFace;
    LabelTitle.Font.Color := clWindowText;
    LabelStatus.Font.Color := clGrayText;
    SpeedButtonSelectAll.Font.Color := clWindowText;
    SpeedButtonCopy.Font.Color := clWindowText;
    SpeedButtonSave.Font.Color := clWindowText;
    SpeedButtonFollow.Font.Color := clWindowText;
    SpeedButtonClear.Font.Color := clWindowText;
    SpeedButtonStop.Font.Color := RGB(159, 31, 41);
    FActivityColor := RGB(22, 131, 79);
    FInactiveColor := RGB(111, 116, 121);
    FErrorColor := RGB(189, 43, 53);
  end;

  PanelIndicator.Color := PanelCommands.Color;
  PanelSession.Color := PanelCommands.Color;
  ApplyPreferences;
  Repaint;
end;


end.
