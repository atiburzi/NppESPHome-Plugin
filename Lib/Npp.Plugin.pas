{
  Base class for Notepad++ plugin development.

  The content of this file was originally provided by Damjan Zobo Cvetko
  Modified by Andreas Heim for using in the plugin framework for Delphi.

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
}

unit Npp.Plugin;

interface
uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.IOUtils, System.Types, Npp.Scintilla.Api, Npp.Api,
  Npp.Host, Npp.Commands, Npp.Toolbar;


type
  // ***************************************************************************
  // Purpose: Identifies the concrete plugin class created by the DLL exports.
  // ***************************************************************************
  TNppPluginClass = class of TNppPlugin;

  // ***************************************************************************
  // Purpose: Coordinates plugin lifecycle, notifications, host, commands, and toolbar.
  // ***************************************************************************
  TNppPlugin = class(TObject)
  private
    FNppData: TNppData;
    FPluginName: nppString;
    FPluginMajorVersion: Integer;
    FPluginMinorVersion: Integer;
    FPluginReleaseNumber: Integer;
    FPluginBuildNumber: Integer;
    FPluginCopyright: string;
    FSCNotification: PSCNotification;
    FShutdownStarted: Boolean;
    FShutdownComplete: Boolean;
    FHost: TNppHost;
    FCommands: TNppCommands;
    FToolbar: TNppToolbar;
    FToolbarRefreshState: IInterface;

    function GetVarSizeStringValue(DirType: cardinal; MaxSize: cardinal = $0000FFFF): string;

  protected
    // Internal utils
    procedure GetVersionInfo;
    procedure ConfigureToolbar(const IconProvider: TNppToolbarIconProvider;
      const DisabledIconProvider: TNppToolbarDisabledIconProvider = nil);

    // Notepad++ notification handlers
    procedure DoNppnReady; virtual;
    procedure DoNppnToolbarModification; virtual;
    procedure DoNppnFileBeforeClose; virtual;
    procedure DoNppnFileOpened; virtual;
    procedure DoNppnFileClosed; virtual;
    procedure DoNppnFileBeforeOpen; virtual;
    procedure DoNppnFileBeforeSave; virtual;
    procedure DoNppnFileSaved; virtual;
    procedure DoNppnShutdown; virtual;
    procedure DoNppnBufferActivated; virtual;
    procedure DoNppnLangChanged; virtual;
    procedure DoNppnWordStylesUpdated; virtual;
    procedure DoNppnShortcutRemapped; virtual;
    procedure DoNppnFileBeforeLoad; virtual;
    procedure DoNppnFileLoadFailed; virtual;
    procedure DoNppnReadOnlyChanged; virtual;
    procedure DoNppnDocOrderChanged; virtual;
    procedure DoNppnSnapshotDirtyFileLoaded; virtual;
    procedure DoNppnBeforeShutDown; virtual;
    procedure DoNppnCancelShutDown; virtual;
    procedure DoNppnFileBeforeRename; virtual;
    procedure DoNppnFileRenameCancel; virtual;
    procedure DoNppnFileRenamed; virtual;
    procedure DoNppnFileBeforeDelete; virtual;
    procedure DoNppnFileDeleteFailed; virtual;
    procedure DoNppnFileDeleted; virtual;
    procedure DoNppnDarkModeChanged; virtual;
    procedure DoNppnCmdLinePluginMsg; virtual;
    procedure DoNppExternalLexerBuffer; virtual;
    procedure DoNppGlobalModified; virtual;
    procedure DoNppNativeLangChanged; virtual;
    procedure DoNppToolbarIconsetChanged; virtual;

  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure BeforeDestruction; override;

    // Basic plugin properties
    property NppData: TNppData read FNppData;
    property Host: TNppHost read FHost;
    property PluginName: nppString read FPluginName write FPluginName;
    property PluginMajorVersion: Integer read FPluginMajorVersion write FPluginMajorVersion;
    property PluginMinorVersion: Integer read FPluginMinorVersion write FPluginMinorVersion;
    property SCNotification: PSCNotification read FSCNotification;
    property IsShuttingDown: Boolean read FShutdownStarted;
    property IsShutdownComplete: Boolean read FShutdownComplete;
    property Commands: TNppCommands read FCommands;
    property Toolbar: TNppToolbar read FToolbar;

    // Plugin interface methods
    procedure MessageProc(var Msg: TMessage); virtual;
    procedure BeNotified(SN: PSCNotification);
    procedure Shutdown;
    procedure SetInfo(NppData: TNppData); virtual;
    function GetFuncsArray(out FuncsCount: Integer): PFuncItem;
    function GetName: nppPChar;
    function GetCurrentScintilla: HWND;

    function GetMajorVersion: Integer;
    function GetMinorVersion: Integer;
    function GetReleaseNumber: Integer;
    function GetBuildNumber: Integer;
    function GetCopyright: string;

    function GetNppVersion(var MajorVersion, MinorVersion: Integer): Integer;
    function IsNppMinVersion(AMajorVersion, AMinorVersion: Integer): Boolean;
    function IsDarkModeEnabled: Boolean;

    function GetNppDir: string;
    function GetPluginDir: string;
    function GetPluginConfigDir: string;
    function GetPluginDocDir: string;
    function GetPluginDllPath: string;

    function GetNppWindowTitle: string;

    function GetFullCurrentPath: string;
    function GetCurrentDirectory: string;
    function GetFullFileName: string;
    function GetFileNameWithoutExt: string;
    function GetFileNameExt: string;

    function GetEncoding: Integer;
    function GetEOLFormat: Integer;
    function GetLanguageType: Integer;
    function GetLanguageName(ALangType: TNppLang): string;
    function GetLanguageDesc(ALangType: TNppLang): string;

    function GetCurrentViewIdx: Integer; overload;
    function GetCurrentViewIdx(ScHandle: HWND): Integer; overload;
    function GetCurrentDocIndex(AViewIdx: Integer): Integer;
    function GetCurrentLine: NativeInt;
    function GetCurrentColumn: LongInt;

    function GetCurrentBufferId: NativeInt;
    function GetBufferIdFromPos(AViewIdx, ADocIdx: Integer): NativeInt;
    function GetPosFromBufferId(ABufferId: NativeInt; out ADocIdx: Integer): Integer;
    function GetFullPathFromBufferId(ABufferId: NativeInt): string;
    function GetCurrentBufferDirty(AViewIdx: Integer): Boolean;
    function GetDarkModeColors(PColors: PNppDarkModeColors): Boolean;
    function GetToolbarIconSetChoice: Integer;

    function GetOpenFilesCnt(CntType: Integer): Integer;
    function GetOpenFiles(CntType: Integer): TStringDynArray;

    function GetLineCount(AViewIdx: Integer): NativeInt;
    function GetCurrentPos(AViewIdx: Integer): NativeInt;
    function GetLineFromPosition(AViewIdx: Integer; APosition: NativeInt): NativeInt;
    function GetFirstVisibleLine(AViewIdx: Integer): NativeInt;
    function GetLinesOnScreen(AViewIdx: Integer): NativeInt;

    procedure GetFilePos(out FileName: string; out Line: NativeInt; out Column: LongInt);
    function GetCurrentWord: string;

    function OpenFile(FileName: string; ReadOnly: Boolean = false): Boolean; overload;
    function OpenFile(FileName: string; Line: NativeInt; ReadOnly: Boolean = false): Boolean; overload;
    function SaveFile(FileName: string): Boolean; overload;
    function SaveCurrentFile: Boolean; overload;
    function SaveAllFiles: Boolean; overload;
    function SwitchToFile(FileName: string): Boolean;

    procedure ReloadFile(FileName: string; Alert: Boolean);
    procedure ReloadCurrentFile(Alert: Boolean);

  end;

implementation
uses
  FileVersionInfo, System.Math, System.Classes;

resourcestring
  rsToolbarConfigurationDuringShutdown =
    'The toolbar cannot be configured while the plugin is shutting down';
  rsToolbarAlreadyConfigured = 'The toolbar is already configured';

type
  // ***************************************************************************
  // Purpose: Protects queued toolbar refreshes from accessing a destroyed plugin.
  // ***************************************************************************
  IToolbarRefreshState = interface
    ['{EF4D540A-5D74-439A-9E12-08BB110F49F1}']
    function GetPlugin: TNppPlugin;
    procedure Deactivate;
    property Plugin: TNppPlugin read GetPlugin;
  end;

  // ***************************************************************************
  // Purpose: Implements the shared lifetime guard captured by queued callbacks.
  // ***************************************************************************
  TToolbarRefreshState = class(TInterfacedObject, IToolbarRefreshState)
  private
    FPlugin: TNppPlugin;
  public
    constructor Create(APlugin: TNppPlugin);
    function GetPlugin: TNppPlugin;
    procedure Deactivate;
  end;

// *****************************************************************************
// Purpose: Creates and initializes the TToolbarRefreshState instance.
// *****************************************************************************
constructor TToolbarRefreshState.Create(APlugin: TNppPlugin);
begin
  inherited Create;
  FPlugin := APlugin;
end;

// *****************************************************************************
// Purpose: Clears the weak plugin reference used by queued toolbar refreshes.
// *****************************************************************************
procedure TToolbarRefreshState.Deactivate;
begin
  FPlugin := nil;
end;

// *****************************************************************************
// Purpose: Returns the plugin instance while asynchronous refreshes remain active.
// *****************************************************************************
function TToolbarRefreshState.GetPlugin: TNppPlugin;
begin
  Result := FPlugin;
end;

// =============================================================================
// Class TNppPlugin
// =============================================================================

// -----------------------------------------------------------------------------
// Create / Destroy
// -----------------------------------------------------------------------------

// *****************************************************************************
// Purpose: Creates and initializes the TNppPlugin instance.
// *****************************************************************************
constructor TNppPlugin.Create;
var
  EmptyData: TNppData;
begin
  inherited;
  FillChar(EmptyData, SizeOf(EmptyData), 0);
  FHost := TNppHost.Create(EmptyData);
  FCommands := TNppCommands.Create(FHost);
  FToolbarRefreshState := TToolbarRefreshState.Create(Self);
  FShutdownStarted := False;
  FShutdownComplete := False;
end;

// *****************************************************************************
// Purpose: Releases resources owned by the TNppPlugin instance.
// *****************************************************************************
destructor TNppPlugin.Destroy;
var
  RefreshState: IToolbarRefreshState;
begin
  if Supports(FToolbarRefreshState, IToolbarRefreshState, RefreshState) then
    RefreshState.Deactivate;
  FToolbarRefreshState := nil;
  FreeAndNil(FToolbar);
  FreeAndNil(FCommands);
  FHost.Free;
  inherited;
end;

// *****************************************************************************
// Purpose: Creates the optional toolbar service owned by the plugin.
// *****************************************************************************
procedure TNppPlugin.ConfigureToolbar(const IconProvider: TNppToolbarIconProvider;
  const DisabledIconProvider: TNppToolbarDisabledIconProvider);
begin
  if FShutdownStarted then
    raise EInvalidOpException.Create(
      rsToolbarConfigurationDuringShutdown);
  if Assigned(FToolbar) then
    raise EInvalidOpException.Create(rsToolbarAlreadyConfigured);
  if not Assigned(IconProvider) then
    raise EArgumentNilException.Create('IconProvider');

  FToolbar := TNppToolbar.Create(FHost, FCommands, IconProvider,
    DisabledIconProvider);
end;

// *****************************************************************************
// Purpose: Invalidates asynchronous state before object destruction begins.
// *****************************************************************************
procedure TNppPlugin.BeforeDestruction;
begin
  inherited;
end;

// -----------------------------------------------------------------------------
// Plugin interface
// -----------------------------------------------------------------------------

// *****************************************************************************
// Purpose: Processes a Windows message forwarded by the Notepad++ plugin entry point.
// *****************************************************************************
procedure TNppPlugin.MessageProc(var Msg: TMessage);
begin
  if (Msg.Msg = WM_CREATE) then
    FCommands.ApplySeparators;
  Dispatch(Msg);
end;

// *****************************************************************************
// Purpose: Dispatches a Notepad++ notification to the matching virtual handler.
// *****************************************************************************
procedure TNppPlugin.BeNotified(SN: PSCNotification);
begin
  if not Assigned(SN) then
    Exit;

  FSCNotification := SN;
  try
    case SN.nmhdr.code of
      NPPN_READY: DoNppnReady;
      NPPN_FILEBEFORELOAD: DoNppnFileBeforeLoad;
      NPPN_FILELOADFAILED: DoNppnFileLoadFailed;
      NPPN_SNAPSHOTDIRTYFILELOADED: DoNppnSnapshotDirtyFileLoaded;
      NPPN_FILEBEFOREOPEN: DoNppnFileBeforeOpen;
      NPPN_FILEOPENED: DoNppnFileOpened;
      NPPN_FILEBEFORECLOSE: DoNppnFileBeforeClose;
      NPPN_FILECLOSED: DoNppnFileClosed;
      NPPN_FILEBEFORESAVE: DoNppnFileBeforeSave;
      NPPN_FILESAVED: DoNppnFileSaved;
      NPPN_FILEBEFORERENAME: DoNppnFileBeforeRename;
      NPPN_FILERENAMECANCEL: DoNppnFileRenameCancel;
      NPPN_FILERENAMED: DoNppnFileRenamed;
      NPPN_FILEBEFOREDELETE: DoNppnFileBeforeDelete;
      NPPN_FILEDELETEFAILED: DoNppnFileDeleteFailed;
      NPPN_FILEDELETED: DoNppnFileDeleted;
      NPPN_BEFORESHUTDOWN: DoNppnBeforeShutDown;
      NPPN_CANCELSHUTDOWN: DoNppnCancelShutDown;
      NPPN_SHUTDOWN: Shutdown;
      NPPN_BUFFERACTIVATED: DoNppnBufferActivated;
      NPPN_LANGCHANGED: DoNppnLangChanged;
      NPPN_READONLYCHANGED: DoNppnReadOnlyChanged;
      NPPN_DOCORDERCHANGED: DoNppnDocOrderChanged;
      NPPN_SHORTCUTREMAPPED: DoNppnShortcutRemapped;
      NPPN_WORDSTYLESUPDATED: DoNppnWordStylesUpdated;
      NPPN_TBMODIFICATION: DoNppnToolbarModification;
      NPPN_DARKMODECHANGED: DoNppnDarkModeChanged;
      NPPN_CMDLINEPLUGINMSG: DoNppnCmdLinePluginMsg;
      NPPN_EXTERNALLEXERBUFFER: DoNppExternalLexerBuffer;
      NPPN_GLOBALMODIFIED: DoNppGlobalModified;
      NPPN_NATIVELANGCHANGED: DoNppNativeLangChanged;
      NPPN_TOOLBARICONSETCHANGED: DoNppToolbarIconsetChanged;
    end;
  finally
    // The notification storage belongs to Notepad++. Never expose it after the
    // callback has returned.
    FSCNotification := nil;
  end;
end;

// *****************************************************************************
// Purpose: Runs the plugin shutdown sequence exactly once.
// *****************************************************************************
procedure TNppPlugin.Shutdown;
var
  RefreshState: IToolbarRefreshState;
begin
  if FShutdownStarted then
    Exit;

  FShutdownStarted := True;
  if Supports(FToolbarRefreshState, IToolbarRefreshState, RefreshState) then
    RefreshState.Deactivate;
  try
    DoNppnShutdown;
  finally
    FShutdownComplete := True;
  end;
end;

// *****************************************************************************
// Purpose: Stores the handles supplied by Notepad++ and synchronizes the host facade.
// *****************************************************************************
procedure TNppPlugin.SetInfo(NppData: TNppData);
begin
  Self.FNppData := NppData;
  FHost.Data := NppData;
end;

// *****************************************************************************
// Purpose: Returns the contiguous function-item array required by Notepad++.
// *****************************************************************************
function TNppPlugin.GetFuncsArray(out FuncsCount: Integer): PFuncItem;
begin
  Result := FCommands.GetFuncsArray(FuncsCount);
end;

// *****************************************************************************
// Purpose: Returns the plugin name buffer required by the Notepad++ ABI.
// *****************************************************************************
function TNppPlugin.GetName: nppPChar;
begin
  Result := nppPChar(PluginName);
end;

// *****************************************************************************
// Purpose: Returns the window handle of the currently active Scintilla view.
// *****************************************************************************
function TNppPlugin.GetCurrentScintilla: HWND;
var
  Idx: Integer;
begin
  Idx := 0;
  Result := NppData.ScintillaMainHandle;
  Host.SendNpp(NPPM_GETCURRENTSCINTILLA, 0, LPARAM(@Idx));
  if Idx <> 0 then
    Result := Self.NppData.ScintillaSecondHandle;
end;

// *****************************************************************************
// Purpose: Reads version metadata from the current plugin module.
// *****************************************************************************
procedure TNppPlugin.GetVersionInfo;
var
  lptstrFilename: string;
  wLangId: Word;
begin
  wLangId := wLangIdEnglish;
  lptstrFilename := GetPluginDllPath;

  if not FileExists(lptstrFilename) then
    exit;

  TFileVersionInfo.GetNumericVersionInfo(lptstrFilename, nfvitFileVersion, FPluginMajorVersion, FPluginMinorVersion, FPluginReleaseNumber, FPluginBuildNumber);
  TFileVersionInfo.GetVersionInfo(lptstrFilename, fvitLegalCopyright, wLangId, FPluginCopyright);
end;

// *****************************************************************************
// Purpose: Returns the major component of the plugin module version.
// *****************************************************************************
function TNppPlugin.GetMajorVersion: Integer;
begin
  Result := FPluginMajorVersion;
end;

// *****************************************************************************
// Purpose: Returns the minor component of the plugin module version.
// *****************************************************************************
function TNppPlugin.GetMinorVersion: Integer;
begin
  Result := FPluginMinorVersion;
end;

// *****************************************************************************
// Purpose: Returns the release component of the plugin module version.
// *****************************************************************************
function TNppPlugin.GetReleaseNumber: Integer;
begin
  Result := FPluginReleaseNumber;
end;

// *****************************************************************************
// Purpose: Returns the build component of the plugin module version.
// *****************************************************************************
function TNppPlugin.GetBuildNumber: Integer;
begin
  Result := FPluginBuildNumber;
end;

// *****************************************************************************
// Purpose: Returns copyright text read from the plugin module version resource.
// *****************************************************************************
function TNppPlugin.GetCopyright: string;
begin
  Result := FPluginCopyright;
end;

// *****************************************************************************
// Purpose: Reads a variable-length string returned by a Notepad++ message.
// *****************************************************************************
function TNppPlugin.GetVarSizeStringValue(DirType: Cardinal; MaxSize: Cardinal = $0000FFFF): string;
var
  Buf: nppString;
  BufLen: Cardinal;
  RetVal: LRESULT;
begin
  Result := '';
  if MaxSize = 0 then
    Exit;
  BufLen := Min(Cardinal(256), MaxSize);
  repeat
    SetLength(Buf, BufLen);
    Buf[BufLen] := #0;
    RetVal := Host.SendNpp(DirType, WPARAM(BufLen), LParam(nppPChar(Buf)));
    if RetVal <> 0 then
      break;
    if BufLen >= MaxSize then
      exit;
    if BufLen > MaxSize div 2 then
      BufLen := MaxSize
    else
      BufLen := BufLen * 2;
  until false;
  SetString(Result, nppPChar(Buf), StrLen(nppPChar(Buf)));
end;

// *****************************************************************************
// Purpose: Delegates normalized Notepad++ version retrieval to the host facade.
// *****************************************************************************
function TNppPlugin.GetNppVersion(var MajorVersion, MinorVersion: Integer): Integer;
begin
  Result := Host.GetNppVersion(MajorVersion, MinorVersion);
end;

// *****************************************************************************
// Purpose: Reports whether the host satisfies a required Notepad++ version.
// *****************************************************************************
function TNppPlugin.IsNppMinVersion(AMajorVersion, AMinorVersion: Integer): Boolean;
begin
  Result := Host.IsNppMinVersion(AMajorVersion, AMinorVersion);
end;

// *****************************************************************************
// Purpose: Reports whether Notepad++ currently has dark mode enabled.
// *****************************************************************************
function TNppPlugin.IsDarkModeEnabled: Boolean;
begin
  Result := false;
  if IsNppMinVersion(8, 410) then
    Result := Host.SendNpp(NPPM_ISDARKMODEENABLED, 0, LPARAM(0)) > 0;
end;

// *****************************************************************************
// Purpose: Returns the Notepad++ installation directory.
// *****************************************************************************
function TNppPlugin.GetNppDir: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETNPPDIRECTORY);
end;

// *****************************************************************************
// Purpose: Returns the Notepad++ plugin directory.
// *****************************************************************************
function TNppPlugin.GetPluginDir: string;
var
  szBuf: string;
  dwRet, dwBufLen: DWORD;
begin
  Result := '';
  dwBufLen := MAX_PATH;
  repeat
    SetLength(szBuf, dwBufLen);
    dwRet := GetModuleFileName(HInstance, PChar(szBuf), dwBufLen);
    // If dwRet is 0 there was an error
    // => leave loop
    // if dwRet is less than dwBufLen the buffer size was sufficient
    // => leave loop
    // If dwRet is equal to dwBufLen the buffer size was too small
    // => loop and retry with double sized buffer
    // dwRet greater than dwBufLen is a non-existing case
    if dwRet < dwBufLen then
      break;
    dwBufLen := dwBufLen * 2;
  until false;
  if dwRet > 0 then
  begin
    SetString(Result, PChar(szBuf), dwRet);
    Result := TPath.GetDirectoryName(Result);
  end;
end;

// *****************************************************************************
// Purpose: Returns the writable configuration directory assigned to plugins.
// *****************************************************************************
function TNppPlugin.GetPluginConfigDir: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETPLUGINSCONFIGDIR);
end;

// *****************************************************************************
// Purpose: Returns the documentation directory assigned to the current plugin.
// *****************************************************************************
function TNppPlugin.GetPluginDocDir: string;
begin
  Result := TPath.Combine(GetPluginDir(), 'doc');
end;

// *****************************************************************************
// Purpose: Returns the absolute path of the current plugin DLL.
// *****************************************************************************
function TNppPlugin.GetPluginDllPath: string;
var
  Buffer: string;
  BufferLength: DWORD;
  CharsWritten: DWORD;
begin
  Result := '';
  BufferLength := MAX_PATH;
  repeat
    SetLength(Buffer, BufferLength);
    CharsWritten := GetModuleFileName(HInstance, PChar(Buffer), BufferLength);
    if CharsWritten = 0 then
      Exit;
    if CharsWritten < BufferLength then
      Break;
    BufferLength := BufferLength * 2;
  until False;
  SetString(Result, PChar(Buffer), CharsWritten);
end;

// *****************************************************************************
// Purpose: Reads the current caption of the Notepad++ main window.
// *****************************************************************************
function TNppPlugin.GetNppWindowTitle: string;
var
  Len: Integer;
begin
  Len := GetWindowTextLength(NppData.NppHandle);
  SetLength(Result, Len);
  GetWindowText(NppData.NppHandle, PChar(Result), Len + 1);
end;

// *****************************************************************************
// Purpose: Returns the absolute path of the active document.
// *****************************************************************************
function TNppPlugin.GetFullCurrentPath: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETFULLCURRENTPATH);
end;

// *****************************************************************************
// Purpose: Returns the directory containing the active document.
// *****************************************************************************
function TNppPlugin.GetCurrentDirectory: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETCURRENTDIRECTORY);
end;

// *****************************************************************************
// Purpose: Returns the active document name including its extension.
// *****************************************************************************
function TNppPlugin.GetFullFileName: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETFILENAME);
end;

// *****************************************************************************
// Purpose: Returns the active document name without its extension.
// *****************************************************************************
function TNppPlugin.GetFileNameWithoutExt: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETNAMEPART);
end;

// *****************************************************************************
// Purpose: Returns the extension of the active document.
// *****************************************************************************
function TNppPlugin.GetFileNameExt: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETEXTPART);
end;

// *****************************************************************************
// Purpose: Returns the encoding mode of the active document.
// *****************************************************************************
function TNppPlugin.GetEncoding: Integer;
begin
  Result := Host.SendNpp(NPPM_GETBUFFERENCODING, WPARAM(GetCurrentBufferId), LPARAM(0));
end;

// *****************************************************************************
// Purpose: Returns the end-of-line format of the active document.
// *****************************************************************************
function TNppPlugin.GetEOLFormat: Integer;
begin
  Result := Host.SendNpp(NPPM_GETBUFFERFORMAT, WPARAM(GetCurrentBufferId), LPARAM(0));
end;

// *****************************************************************************
// Purpose: Returns the language identifier of the active document.
// *****************************************************************************
function TNppPlugin.GetLanguageType: Integer;
begin
  Result := Host.SendNpp(NPPM_GETBUFFERLANGTYPE, WPARAM(GetCurrentBufferId), LPARAM(0));
  if Result = -1 then
    Result := C_NO_LANGUAGE;
end;

// *****************************************************************************
// Purpose: Resolves a language identifier to its Notepad++ language name.
// *****************************************************************************
function TNppPlugin.GetLanguageName(ALangType: TNppLang): string;
var
  BufLen: LRESULT;

begin
  BufLen := Host.SendNpp(NPPM_GETLANGUAGENAME, WPARAM(ALangType), LPARAM(0));
  SetLength(Result, BufLen);

  BufLen := Host.SendNpp(NPPM_GETLANGUAGENAME, WPARAM(ALangType), LPARAM(nppPChar(Result)));
  SetLength(Result, BufLen);
end;

// *****************************************************************************
// Purpose: Resolves a language identifier to its Notepad++ description.
// *****************************************************************************
function TNppPlugin.GetLanguageDesc(ALangType: TNppLang): string;
var
  BufLen: LRESULT;

begin
  BufLen := Host.SendNpp(NPPM_GETLANGUAGEDESC, WPARAM(ALangType), LPARAM(0));
  SetLength(Result, BufLen);

  BufLen := Host.SendNpp(NPPM_GETLANGUAGEDESC, WPARAM(ALangType), LPARAM(nppPChar(Result)));
  SetLength(Result, BufLen);
end;

// *****************************************************************************
// Purpose: Returns the index of the currently active Scintilla view.
// *****************************************************************************
function TNppPlugin.GetCurrentViewIdx: Integer;
begin
  Result := Host.SendNpp(NPPM_GETCURRENTVIEW, WPARAM(0), LPARAM(0));
end;

// *****************************************************************************
// Purpose: Maps a Scintilla window handle to its Notepad++ view index.
// *****************************************************************************
function TNppPlugin.GetCurrentViewIdx(ScHandle: HWND): Integer;
begin
  if ScHandle = NppData.ScintillaMainHandle then
    Result := MAIN_VIEW

  else if ScHandle = NppData.ScintillaSecondHandle then
    Result := SUB_VIEW

  else
    Result := -1;
end;

// *****************************************************************************
// Purpose: Returns the active document index within a Notepad++ view.
// *****************************************************************************
function TNppPlugin.GetCurrentDocIndex(AViewIdx: Integer): Integer;
begin
  Result := Host.SendNpp(NPPM_GETCURRENTDOCINDEX, WPARAM(0), LPARAM(AViewIdx));
end;

// *****************************************************************************
// Purpose: Returns the zero-based line containing the current caret.
// *****************************************************************************
function TNppPlugin.GetCurrentLine: NativeInt;
begin
  Result := Host.SendNpp(NPPM_GETCURRENTLINE, WPARAM(0), LPARAM(0));
end;

// *****************************************************************************
// Purpose: Returns the zero-based column containing the current caret.
// *****************************************************************************
function TNppPlugin.GetCurrentColumn: LongInt;
begin
  Result := Host.SendNpp(NPPM_GETCURRENTCOLUMN, WPARAM(0), LPARAM(0));
end;

// *****************************************************************************
// Purpose: Returns the stable Notepad++ buffer identifier of the active document.
// *****************************************************************************
function TNppPlugin.GetCurrentBufferId: NativeInt;
begin
  Result := Host.SendNpp(NPPM_GETCURRENTBUFFERID, WPARAM(0), LPARAM(0));
end;

// *****************************************************************************
// Purpose: Resolves a view and document position to a Notepad++ buffer ID.
// *****************************************************************************
function TNppPlugin.GetBufferIdFromPos(AViewIdx, ADocIdx: Integer): NativeInt;
begin
  Result := Host.SendNpp(NPPM_GETBUFFERIDFROMPOS, WPARAM(ADocIdx), LPARAM(AViewIdx));
end;

// *****************************************************************************
// Purpose: Resolves a buffer ID to its document and view positions.
// *****************************************************************************
function TNppPlugin.GetPosFromBufferId(ABufferId: NativeInt; out ADocIdx: Integer): Integer;
var
  Pos: LRESULT;
begin
  Result := -1;
  ADocIdx := -1;
  Pos := Host.SendNpp(NPPM_GETPOSFROMBUFFERID, WPARAM(ABufferId), LParam(MAIN_VIEW));
  if Pos <> -1 then
  begin
    Result := Pos shr 30;
    ADocIdx := Pos and $3FFFFFFF;
  end;
end;

// *****************************************************************************
// Purpose: Resolves a Notepad++ buffer ID to its absolute file path.
// *****************************************************************************
function TNppPlugin.GetFullPathFromBufferId(ABufferId: NativeInt): string;
var
  BufLen: LRESULT;
begin
  BufLen := Host.SendNpp(NPPM_GETFULLPATHFROMBUFFERID, WPARAM(ABufferId), LPARAM(0));
  if BufLen < 0 then
    Exit('');
  SetLength(Result, BufLen);
  if BufLen = 0 then
    Exit;
  BufLen := Host.SendNpp(NPPM_GETFULLPATHFROMBUFFERID, WPARAM(ABufferId), LPARAM(nppPChar(Result)));
  if BufLen < 0 then
    Result := ''
  else
    SetLength(Result, BufLen);
end;

// *****************************************************************************
// Purpose: Reports whether the active buffer in a view has unsaved changes.
// *****************************************************************************
function TNppPlugin.GetCurrentBufferDirty(AViewIdx: Integer): Boolean;
begin
  case AViewIdx of
    MAIN_VIEW:
      Result := (Host.SendMainScintilla(SCI_GETMODIFY, WPARAM(0), LParam(0)) <> 0);
    SUB_VIEW:
      Result := (Host.SendSecondScintilla(SCI_GETMODIFY, WPARAM(0), LParam(0)) <> 0);
  else
    Result := false;
  end;
end;

// *****************************************************************************
// Purpose: Retrieves the current Notepad++ dark-mode color palette.
// *****************************************************************************
function TNppPlugin.GetDarkModeColors(PColors: PNppDarkModeColors): Boolean;
begin
  Result := false;
  if not Assigned(PColors) then
    Exit;
  if IsDarkModeEnabled then
    Result := Host.SendNpp(NPPM_GETDARKMODECOLORS,
      SizeOf(TNppDarkModeColors), LParam(PColors)) > 0;
end;

// *****************************************************************************
// Purpose: Returns the toolbar icon family and size selected by the user.
// *****************************************************************************
function TNppPlugin.GetToolbarIconSetChoice: Integer;
begin
  Result := Host.SendNpp(NPPM_GETTOOLBARICONSETCHOICE, 0, 0);
end;

// *****************************************************************************
// Purpose: Returns the number of open files for the requested view scope.
// *****************************************************************************
function TNppPlugin.GetOpenFilesCnt(CntType: Integer): Integer;
begin
  Result := Host.SendNpp(NPPM_GETNBOPENFILES, WPARAM(0), LParam(CntType));
end;

// *****************************************************************************
// Purpose: Returns the paths currently open in one or both Notepad++ views.
// *****************************************************************************
function TNppPlugin.GetOpenFiles(CntType: Integer): TStringDynArray;
  // ***************************************************************************
  // Purpose: Appends every valid document path from one Notepad++ view.
  // ***************************************************************************
  procedure AppendView(const CountType, ViewIndex: Integer);
  var
    FileCount: Integer;
    DocumentIndex: Integer;
    BufferId: NativeInt;
    FileName: string;
  begin
    FileCount := GetOpenFilesCnt(CountType);
    for DocumentIndex := 0 to FileCount - 1 do
    begin
      // NPPM_GETNBOPENFILES and NPPM_GETBUFFERIDFROMPOS deliberately use
      // different constant families: PRIMARY/SECOND versus MAIN/SUB.
      BufferId := GetBufferIdFromPos(ViewIndex, DocumentIndex);
      if BufferId = 0 then
        Continue;
      FileName := GetFullPathFromBufferId(BufferId);
      if FileName = '' then
        Continue;
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := FileName;
    end;
  end;

begin
  SetLength(Result, 0);
  case CntType of
    Npp.Api.ALL_OPEN_FILES:
      begin
        AppendView(Npp.Api.PRIMARY_VIEW, Npp.Api.MAIN_VIEW);
        AppendView(Npp.Api.SECOND_VIEW, Npp.Api.SUB_VIEW);
      end;
    Npp.Api.PRIMARY_VIEW:
      AppendView(Npp.Api.PRIMARY_VIEW, Npp.Api.MAIN_VIEW);
    Npp.Api.SECOND_VIEW:
      AppendView(Npp.Api.SECOND_VIEW, Npp.Api.SUB_VIEW);
  end;
end;

// *****************************************************************************
// Purpose: Returns the number of lines in the requested Scintilla view.
// *****************************************************************************
function TNppPlugin.GetLineCount(AViewIdx: Integer): NativeInt;
begin
  case AViewIdx of
    MAIN_VIEW:
      Result := Host.SendMainScintilla(SCI_GETLINECOUNT, WPARAM(0), LPARAM(0));
    SUB_VIEW:
      Result := Host.SendSecondScintilla(SCI_GETLINECOUNT, WPARAM(0), LPARAM(0));
  else
    Result := 0;
  end;
end;

// *****************************************************************************
// Purpose: Returns the current caret position in the requested Scintilla view.
// *****************************************************************************
function TNppPlugin.GetCurrentPos(AViewIdx: Integer): NativeInt;
begin
  case AViewIdx of
    MAIN_VIEW:
      Result := Host.SendMainScintilla(SCI_GETCURRENTPOS, WPARAM(0), LPARAM(0));
    SUB_VIEW:
      Result := Host.SendSecondScintilla(SCI_GETCURRENTPOS, WPARAM(0), LPARAM(0));
  else
    Result := -1;
  end;
end;

// *****************************************************************************
// Purpose: Maps a Scintilla character position to its zero-based line number.
// *****************************************************************************
function TNppPlugin.GetLineFromPosition(AViewIdx: Integer; APosition: NativeInt): NativeInt;
begin
  case AViewIdx of
    MAIN_VIEW:
      Result := Host.SendMainScintilla(SCI_LINEFROMPOSITION, WPARAM(APosition), LPARAM(0));
    SUB_VIEW:
      Result := Host.SendSecondScintilla(SCI_LINEFROMPOSITION, WPARAM(APosition), LPARAM(0));
  else
    Result := -1;
  end;
end;

// *****************************************************************************
// Purpose: Returns the first visible display line in a Scintilla view.
// *****************************************************************************
function TNppPlugin.GetFirstVisibleLine(AViewIdx: Integer): NativeInt;
begin
  case AViewIdx of
    MAIN_VIEW:
      Result := Host.SendMainScintilla(SCI_GETFIRSTVISIBLELINE, WPARAM(0), LPARAM(0));
    SUB_VIEW:
      Result := Host.SendSecondScintilla(SCI_GETFIRSTVISIBLELINE, WPARAM(0), LPARAM(0));
  else
    Result := -1;
  end;
end;

// *****************************************************************************
// Purpose: Returns the number of display lines visible in a Scintilla view.
// *****************************************************************************
function TNppPlugin.GetLinesOnScreen(AViewIdx: Integer): NativeInt;
begin
  case AViewIdx of
    MAIN_VIEW:
      Result := Host.SendMainScintilla(SCI_LINESONSCREEN, WPARAM(0), LPARAM(0));
    SUB_VIEW:
      Result := Host.SendSecondScintilla(SCI_LINESONSCREEN, WPARAM(0), LPARAM(0));
  else
    Result := 0;
  end;
end;

// *****************************************************************************
// Purpose: Returns the active file path, line, and column in one operation.
// *****************************************************************************
procedure TNppPlugin.GetFilePos(out FileName: string; out Line: NativeInt; out Column: LongInt);
begin
  FileName := GetFullCurrentPath();
  Line := GetCurrentLine();
  Column := GetCurrentColumn();
end;

// *****************************************************************************
// Purpose: Returns the word currently selected or located under the caret.
// *****************************************************************************
function TNppPlugin.GetCurrentWord: string;
begin
  // A corrupt/non-host transport must not make a word query grow toward a
  // multi-gigabyte allocation. One million UTF-16 code units is already well
  // beyond practical editor-token sizes.
  Result := GetVarSizeStringValue(NPPM_GETCURRENTWORD, $00100000);
end;

// *****************************************************************************
// Purpose: Opens or activates a file and applies the requested options.
// *****************************************************************************
function TNppPlugin.OpenFile(FileName: string; ReadOnly: Boolean = false): Boolean;
var
  Cnt: Integer;
  Found: Boolean;
  FileNames: TStringDynArray;
  ScintillaHandle: HWND;

begin
  Result := False;
  Found := False;
  FileNames := GetOpenFiles(Npp.Api.ALL_OPEN_FILES);
  for Cnt := Low(FileNames) to High(FileNames) do
    if SameFileName(FileNames[Cnt], FileName) then
    begin
      Found := True;
      Result := SwitchToFile(FileName);
      Break;
    end;

  if not Found then
    Result := Host.SendNpp(NPPM_DOOPEN, WPARAM(0),
      LPARAM(nppPChar(FileName))) <> 0;

  // Set the editor state explicitly. The corresponding menu command toggles
  // state and is therefore unsafe when the document is already read-only.
  if Result and ReadOnly then
  begin
    ScintillaHandle := GetCurrentScintilla;
    if ScintillaHandle <> 0 then
      Host.Send(ScintillaHandle, SCI_SETREADONLY, WPARAM(True), 0);
  end;
end;

// *****************************************************************************
// Purpose: Opens or activates a file and applies the requested options.
// *****************************************************************************
function TNppPlugin.OpenFile(FileName: string; Line: NativeInt; ReadOnly: Boolean = false): Boolean;
var
  Ret: Boolean;

begin
  Ret := OpenFile(FileName, ReadOnly);

  if Ret then
    case GetCurrentViewIdx() of
      MAIN_VIEW:
        Host.SendMainScintilla(SCI_GOTOLINE, WPARAM(Line), LPARAM(0));
      SUB_VIEW:
        Host.SendSecondScintilla(SCI_GOTOLINE, WPARAM(Line), LPARAM(0));
    end;

  Result := Ret;
end;

// *****************************************************************************
// Purpose: Saves the specified document through Notepad++.
// *****************************************************************************
function TNppPlugin.SaveFile(FileName: string): Boolean;
begin
  Result := Host.SendNpp(NPPM_SAVEFILE, WPARAM(0), LPARAM(nppPChar(FileName))) <> 0;
end;

// *****************************************************************************
// Purpose: Saves the active document through Notepad++.
// *****************************************************************************
function TNppPlugin.SaveCurrentFile: Boolean;
begin
  Result := Host.SendNpp(NPPM_SAVECURRENTFILE, WPARAM(0), LPARAM(0)) <> 0;
end;

// *****************************************************************************
// Purpose: Saves every modified document through Notepad++.
// *****************************************************************************
function TNppPlugin.SaveAllFiles: Boolean;
begin
  Result := Host.SendNpp(NPPM_SAVEALLFILES, WPARAM(0), LPARAM(0)) <> 0;
end;

// *****************************************************************************
// Purpose: Activates an already open document by absolute path.
// *****************************************************************************
function TNppPlugin.SwitchToFile(FileName: string): Boolean;
begin
  Result := Host.SendNpp(NPPM_SWITCHTOFILE, 0, LPARAM(nppPChar(FileName))) <> 0;
end;

// *****************************************************************************
// Purpose: Reloads a specified document and optionally warns about data loss.
// *****************************************************************************
procedure TNppPlugin.ReloadFile(FileName: string; Alert: Boolean);
begin
  Host.SendNpp(NPPM_RELOADFILE, WPARAM(Alert), LPARAM(nppPChar(FileName)));
end;

// *****************************************************************************
// Purpose: Reloads the active document and optionally warns about data loss.
// *****************************************************************************
procedure TNppPlugin.ReloadCurrentFile(Alert: Boolean);
begin
  Host.SendNpp(NPPM_RELOADBUFFERID, WPARAM(GetCurrentBufferId()), LPARAM(Alert));
end;



// -----------------------------------------------------------------------------
// Notepad++ notification handlers
// -----------------------------------------------------------------------------

// Notifies plugins that all the procedures of launching notepad++
// completed succesfully
// hwndFrom = HWND hwndNpp
// *****************************************************************************
// Purpose: Handles NPPN_READY and finalizes host-dependent plugin services.
// *****************************************************************************
procedure TNppPlugin.DoNppnReady;
begin
  // When overriding this ensure to call "inherited"

  // Retrieve version infos from plugin's DLL file
  // and write them to internal variables
  GetVersionInfo();
  if Assigned(FToolbar) then
  begin
    FToolbar.CaptureNativeButtons;
    FToolbar.Refresh;
  end;
end;

// Notifies plugins that toolbar icons can be registered.
// hwndFrom = HWND hwndNpp
// *****************************************************************************
// Purpose: Handles NPPN_TBMODIFICATION by registering configured toolbar icons.
// *****************************************************************************
procedure TNppPlugin.DoNppnToolbarModification;
begin
  if Assigned(FToolbar) then
    FToolbar.Initialize;
end;

// Notifies plugins that Npp shutdown has been triggered,
// files have not been closed yet
// hwndFrom = HWND hwndNpp
// *****************************************************************************
// Purpose: Handles NPPN_BEFORESHUTDOWN and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnBeforeShutDown;
begin
end;

// Notifies plugins that Notepad++ shut down has been cancelled
// hwndFrom = HWND hwndNpp
// *****************************************************************************
// Purpose: Handles NPPN_CANCELSHUTDOWN and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnCancelShutDown;
begin
end;

// Notifies plugins that Notepad++ is about to shut down
// hwndFrom = HWND hwndNpp
// *****************************************************************************
// Purpose: Handles NPPN_SHUTDOWN and provides an override point for cleanup.
// *****************************************************************************
procedure TNppPlugin.DoNppnShutdown;
begin
end;

// Notifies plugins that a file is about to be loaded
// hwndFrom = HWND hwndNpp
// idFrom   = NULL
// *****************************************************************************
// Purpose: Handles NPPN_FILEBEFORELOAD and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileBeforeLoad;
begin
end;

// Notifies plugins that the file load operation failed
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_FILELOADFAILED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileLoadFailed;
begin
end;

// Notifies plugins that a file is about to be opened
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_FILEBEFOREOPEN and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileBeforeOpen;
begin
end;

// Notifies plugins that the current file just opened
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_FILEOPENED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileOpened;
begin
end;

// Notifies plugins that the current file is about to be closed
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_FILEBEFORECLOSE and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileBeforeClose;
begin
end;

// Notifies plugins that the current file is just closed
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_FILECLOSED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileClosed;
begin
end;

// Notifies plugins that the current file is about to be saved
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_FILEBEFORESAVE and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileBeforeSave;
begin
end;

// Notifies plugins that the current file was just saved
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_FILESAVED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileSaved;
begin
end;

// Notifies plugins that the current file is about to be renamed
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_FILEBEFORERENAME and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileBeforeRename;
begin
end;

// Notifies plugins that user cancelled the file rename operation
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_FILERENAMECANCEL and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileRenameCancel;
begin
end;

// Notifies plugins that the current file was just renamed
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_FILERENAMED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileRenamed;
begin
end;

// Notifies plugins that the current file is about to be deleted
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_FILEBEFOREDELETE and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileBeforeDelete;
begin
end;

// Notifies plugins that the file delete operation failed
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_FILEDELETEFAILED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileDeleteFailed;
begin
end;

// Notifies plugins that the current file was just deleted
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_FILEDELETED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnFileDeleted;
begin
end;

// Notifies plugins that a buffer was activated (put to foreground).
// hwndFrom = HWND hwndNpp
// idFrom   = int activatedBufferID
// *****************************************************************************
// Purpose: Handles NPPN_BUFFERACTIVATED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnBufferActivated;
begin
end;

// Notifies plugins that the language in the current doc just changed.
// hwndFrom = HWND hwndNpp
// idFrom   = int currentBufferID
// *****************************************************************************
// Purpose: Handles NPPN_LANGCHANGED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnLangChanged;
begin
end;

// Notifies plugins that the read-only state of the current buffer was changed
// hwndFrom = int bufferID
// idFrom   = int docStatus   can be combined by
// DOCSTATUS_READONLY = 1
// DOCSTATUS_BUFFERDIRTY = 2
// *****************************************************************************
// Purpose: Handles NPPN_READONLYCHANGED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnReadOnlyChanged;
begin
end;

// Notifies plugins that document order is changed,
// Tab dragged by mouse: buffer bufferID previously had index oldIndex.
// hwndFrom = int oldIndex
// idFrom   = int bufferID
// Tab moved by menu command: buffer bufferID having index newIndex.
// hwndFrom = int newIndex
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_DOCORDERCHANGED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnDocOrderChanged;
begin
end;

// Notifies plugins that a plugin command shortcut is remapped.
// hwndFrom = PShortcutKey ShortcutKeyStructure
// idFrom   = int cmdID
// *****************************************************************************
// Purpose: Handles NPPN_SHORTCUTREMAPPED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnShortcutRemapped;
begin
end;

// Notifies plugins that user initiated a WordStyleDlg change.
// hwndFrom = HWND hwndNpp
// idFrom   = int currentBufferID
// *****************************************************************************
// Purpose: Handles NPPN_WORDSTYLESUPDATED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnWordStylesUpdated;
begin
end;

// Notifies plugins that a snapshot dirty file is loaded on startup.
// hwndFrom = NULL
// idFrom   = int bufferID
// *****************************************************************************
// Purpose: Handles NPPN_SNAPSHOTDIRTYFILELOADED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnSnapshotDirtyFileLoaded;
begin
end;

// Notifies plugins that Dark Mode was enabled/disabled. Use NPPM_ISDARKMODEENABLED
// to query Dark Mode status.
// hwndFrom = HWND hwndNpp
// *****************************************************************************
// Purpose: Handles NPPN_DARKMODECHANGED and refreshes the optional toolbar.
// *****************************************************************************
procedure TNppPlugin.DoNppnDarkModeChanged;
begin
  if Assigned(FToolbar) then
    FToolbar.Refresh;
end;

// Notifies plugins that command line contains an argument for plugins (in the
// form -pluginMessage="YOUR_PLUGIN_ARGUMENT")
// hwndFrom = HWND hwndNpp
// idFrom   = wchar_t *pluginMessage
// *****************************************************************************
// Purpose: Handles NPPN_CMDLINEPLUGINMSG and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppnCmdLinePluginMsg;
begin
end;

// Notifies lexer plugins that the buffer (in idFrom) is just applied to an
// external lexer
// scnNotification->nmhdr.code = NPPN_EXTERNALLEXERBUFFER;
// scnNotification->nmhdr.hwndFrom = hwndNpp;
// scnNotification->nmhdr.idFrom = BufferID;
// *****************************************************************************
// Purpose: Handles NPPN_EXTERNALLEXERBUFFER and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppExternalLexerBuffer;
begin
end;

// Notifies plugins that the current document is just modified by Replace All action.
// For solving the performance issue (from v8.6.4), Notepad++ doesn't trigger SCN_MODIFIED during Replace All action anymore.
// As a result, the plugins which monitor SCN_MODIFIED should also monitor NPPN_GLOBALMODIFIED.
// scnNotification->nmhdr.code = NPPN_GLOBALMODIFIED;
// scnNotification->nmhdr.hwndFrom = BufferID;
// scnNotification->nmhdr.idFrom = 0; // preserved for future use, must be zero
// *****************************************************************************
// Purpose: Handles NPPN_GLOBALMODIFIED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppGlobalModified;
begin
end;

// To notify plugins that the current native language is just changed to another one.
// Use NPPM_GETNATIVELANGFILENAME to get current native language file name.
// Use NPPM_GETMENUHANDLE(NPPPLUGINMENU, 0) to get submenu "Plugins" handle (HMENU)
//scnNotification->nmhdr.code = NPPN_NATIVELANGCHANGED;
//scnNotification->nmhdr.hwndFrom = hwndNpp
//scnNotification->nmhdr.idFrom = 0; // preserved for the future use, must be zero
// *****************************************************************************
// Purpose: Handles NPPN_NATIVELANGCHANGED and provides an override point.
// *****************************************************************************
procedure TNppPlugin.DoNppNativeLangChanged;
begin
end;

// To notify plugins that toolbar icon set selection has changed
//scnNotification->nmhdr.code = NPPN_TOOLBARICONSETCHANGED;
//scnNotification->nmhdr.hwndFrom = hwndNpp;
//scnNotification->nmhdr.idFrom = iconSetChoice;
// where iconSetChoice could be 1 of 5 possible values:
// 0 (Fluent UI: small), 1 (Fluent UI: large), 2 (Filled Fluent UI: small), 3 (Filled Fluent UI: large) and 4 (Standard icons: small).
// *****************************************************************************
// Purpose: Handles NPPN_TOOLBARICONSETCHANGED after native image-list replacement.
// *****************************************************************************
procedure TNppPlugin.DoNppToolbarIconsetChanged;
var
  RefreshState: IToolbarRefreshState;
begin
  if not Assigned(FToolbar) or FShutdownStarted then
    Exit;
  if not Supports(FToolbarRefreshState, IToolbarRefreshState,
    RefreshState) then
    Exit;

  // Notepad++ is still replacing its image lists while delivering this
  // notification. Refresh once that host update has completed.
  TThread.ForceQueue(nil,
    procedure
    var
      CurrentPlugin: TNppPlugin;
    begin
      CurrentPlugin := RefreshState.Plugin;
      if Assigned(CurrentPlugin) and not CurrentPlugin.IsShuttingDown and
        Assigned(CurrentPlugin.FToolbar) then
        CurrentPlugin.FToolbar.Refresh;
    end);
end;

end.
