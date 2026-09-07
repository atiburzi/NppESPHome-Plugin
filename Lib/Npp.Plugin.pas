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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils, System.IOUtils, System.Types, Npp.Scintilla.Api, Npp.Api,
  Npp.MenuCmdID, Npp.Host;


type
  // Plugin metaclass
  // Eleminates the need to edit the file NppPluginInclude.pas for every new plugin
  TNppPluginClass = class of TNppPlugin;

  // Plugin base class
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
    FFuncItemArray: array of TFuncItem;
    FShutdownStarted: Boolean;
    FShutdownComplete: Boolean;
    FHost: TNppHost;

    function GetVarSizeStringValue(DirType: cardinal; MaxSize: cardinal = $0000FFFF): string;

  protected
    // Internal utils
    procedure GetVersionInfo;
    function AddFuncItem(ItemName: nppString; Func: FuncItemCmdProc; ShortcutKey: PShortcutKey = nil; Checked: Boolean = False): Integer; overload;
    function AddFuncItem(ItemIndex: Integer; ItemName: nppString; Func: FuncItemCmdProc; ShortcutKey: PShortcutKey = nil; Checked: Boolean = False): Integer; overload;
    procedure AddToolbarIcon(CmdID: cardinal; var ToolbarIcon: TToolbarIcons); overload;
    procedure AddToolbarIcon(CmdID: cardinal; var ToolbarIcon: TToolbarIconsWithDarkMode); overload;

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
    // Typed SendMessage facade. Replace Transport in hostless tests.
    property Host: TNppHost read FHost;
    property PluginName: nppString read FPluginName write FPluginName;
    property PluginMajorVersion: Integer read FPluginMajorVersion write FPluginMajorVersion;
    property PluginMinorVersion: Integer read FPluginMinorVersion write FPluginMinorVersion;
    property SCNotification: PSCNotification read FSCNotification;
    property IsShuttingDown: Boolean read FShutdownStarted;
    property IsShutdownComplete: Boolean read FShutdownComplete;

    // Plugin interface methods
    procedure MessageProc(var Msg: TMessage); virtual;
    procedure BeNotified(SN: PSCNotification);
    procedure Shutdown;
    procedure SetInfo(NppData: TNppData); virtual;
    function GetFuncsArray(out FuncsCount: Integer): PFuncItem;
    function GetFuncByIndex(const Index: Integer): PFuncItem;
    function GetFuncByCmdID(const CmdID: Integer): PFuncItem;
    function GetName: nppPChar;
    function GetCurrentScintilla: HWND;

    // Utils and Npp message wrappers
    function CmdIdFromMenuItemIdx(MenuItemIdx: Integer): Integer;

    procedure CheckMenuItem(MenuItemIdx: Integer; State: Boolean; Delayed: Boolean = true);
    procedure EnableMenuItem(MenuItemIdx: Integer; State: Boolean);
    procedure EnableToolbarItem(MenuItemIdx: Integer; State: Boolean); virtual;
    procedure RegisterToolbarIcon(CmdID: Cardinal; var ToolbarIcon: TToolbarIcons); overload;
    procedure RegisterToolbarIcon(CmdID: Cardinal; var ToolbarIcon: TToolbarIconsWithDarkMode); overload;
    function RegisterFuncItem(ItemName: nppString; Func: FuncItemCmdProc;
      ShortcutKey: PShortcutKey = nil; Checked: Boolean = False): Integer;

    procedure PerformMenuCommand(MenuCmdId: Integer; Param: Integer = 0; Delayed: Boolean = true);

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

    function GetToolbarHandle: HWND; virtual;
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
  FileVersionInfo, System.Math, Winapi.CommCtrl;

// =============================================================================
// Class TNppPlugin
// =============================================================================

// -----------------------------------------------------------------------------
// Create / Destroy
// -----------------------------------------------------------------------------

constructor TNppPlugin.Create;
var
  EmptyData: TNppData;
begin
  inherited;
  FillChar(EmptyData, SizeOf(EmptyData), 0);
  FHost := TNppHost.Create(EmptyData);
  FShutdownStarted := False;
  FShutdownComplete := False;
end;

destructor TNppPlugin.Destroy;
var
  Index: Integer;
begin
  for Index := 0 to Length(FFuncItemArray) - 1 do
  begin
    if Assigned(FFuncItemArray[Index].ShortcutKey) then
      Dispose(FFuncItemArray[Index].ShortcutKey);
  end;
  FHost.Free;
  inherited;
end;

procedure TNppPlugin.BeforeDestruction;
begin
  inherited;
end;

// -----------------------------------------------------------------------------
// Plugin interface
// -----------------------------------------------------------------------------

procedure TNppPlugin.MessageProc(var Msg: TMessage);
var
  Menu: HMENU;
  Index: Integer;
begin
  if (Msg.Msg = WM_CREATE) then
  begin
    Menu := GetMenu(NppData.NppHandle);
    for Index := 0 to Length(FFuncItemArray) - 1 do
      if (FFuncItemArray[Index].ItemName[0] = '-') then
        ModifyMenu(Menu, FFuncItemArray[Index].CmdID, MF_BYCOMMAND or MF_SEPARATOR, 0, nil);
  end;
  Dispatch(Msg);
end;

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

procedure TNppPlugin.Shutdown;
begin
  if FShutdownStarted then
    Exit;

  FShutdownStarted := True;
  try
    DoNppnShutdown;
  finally
    FShutdownComplete := True;
  end;
end;

procedure TNppPlugin.SetInfo(NppData: TNppData);
begin
  Self.FNppData := NppData;
  FHost.Data := NppData;
end;

function TNppPlugin.GetFuncsArray(out FuncsCount: Integer): PFuncItem;
begin
  FuncsCount := Length(FFuncItemArray);
  if FuncsCount = 0 then
    Result := nil
  else
    Result := @FFuncItemArray[0];
end;

function TNppPlugin.GetFuncByIndex(const Index: Integer): PFuncItem;
begin
  Result := nil;
  if (Index >= 0) and (Index < Length(FFuncItemArray)) then
    Result := @FFuncItemArray[Index];
end;

function TNppPlugin.GetFuncByCmdID(const CmdID: Integer): PFuncItem;
var
  Idx: Integer;
begin
  Result := nil;
  for Idx := 0 to High(FFuncItemArray) do
    if FFuncItemArray[Idx].CmdID = CmdID then
    begin
      Result := @FFuncItemArray[Idx];
      Exit;
    end;
end;

function TNppPlugin.GetName: nppPChar;
begin
  Result := nppPChar(PluginName);
end;

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

// -----------------------------------------------------------------------------
// Internal utils
// -----------------------------------------------------------------------------

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

function TNppPlugin.AddFuncItem(ItemName: nppString; Func: FuncItemCmdProc; ShortcutKey: PShortcutKey = nil; Checked: Boolean = False): Integer;
begin
  Result := Length(FFuncItemArray);
  SetLength(FFuncItemArray, Result + 1);
  StringToWideChar(ItemName, FFuncItemArray[Result].ItemName, Length(FFuncItemArray[Result].ItemName));
  FFuncItemArray[Result].Func := Func;
  FFuncItemArray[Result].ShortcutKey := ShortcutKey;
  FFuncItemArray[Result].Checked := Checked;
end;

function TNppPlugin.AddFuncItem(ItemIndex: Integer; ItemName: nppString; Func: FuncItemCmdProc; ShortcutKey: PShortcutKey = nil; Checked: Boolean = False): Integer;
begin
  if ItemIndex < 0 then
    raise EArgumentOutOfRangeException.Create('ItemIndex must not be negative');
  if Length(FFuncItemArray) <= ItemIndex then
    SetLength(FFuncItemArray, ItemIndex + 1);
  if Assigned(FFuncItemArray[ItemIndex].ShortcutKey) and
     (FFuncItemArray[ItemIndex].ShortcutKey <> ShortcutKey) then
    Dispose(FFuncItemArray[ItemIndex].ShortcutKey);
  StringToWideChar(ItemName, FFuncItemArray[ItemIndex].ItemName, Length(FFuncItemArray[ItemIndex].ItemName));
  FFuncItemArray[ItemIndex].Func := Func;
  FFuncItemArray[ItemIndex].ShortcutKey := ShortcutKey;
  FFuncItemArray[ItemIndex].Checked := Checked;
  Result := ItemIndex;
end;

procedure TNppPlugin.AddToolbarIcon(CmdID: cardinal; var ToolbarIcon: TToolbarIcons);
begin
  Host.SendNpp(NPPM_ADDTOOLBARICON_DEPRECATED, WPARAM(CmdID), LPARAM(@ToolbarIcon));
end;

procedure TNppPlugin.AddToolbarIcon(CmdID: cardinal; var ToolbarIcon: TToolbarIconsWithDarkMode);
begin
  Host.SendNpp(NPPM_ADDTOOLBARICON_FORDARKMODE, WPARAM(CmdID), LPARAM(@ToolbarIcon));
end;

procedure TNppPlugin.RegisterToolbarIcon(CmdID: Cardinal;
  var ToolbarIcon: TToolbarIcons);
begin
  AddToolbarIcon(CmdID, ToolbarIcon);
end;

procedure TNppPlugin.RegisterToolbarIcon(CmdID: Cardinal;
  var ToolbarIcon: TToolbarIconsWithDarkMode);
begin
  AddToolbarIcon(CmdID, ToolbarIcon);
end;

function TNppPlugin.RegisterFuncItem(ItemName: nppString;
  Func: FuncItemCmdProc; ShortcutKey: PShortcutKey; Checked: Boolean): Integer;
begin
  Result := AddFuncItem(ItemName, Func, ShortcutKey, Checked);
end;

// -----------------------------------------------------------------------------
// Utils and message wrapper methods
// -----------------------------------------------------------------------------

function TNppPlugin.CmdIdFromMenuItemIdx(MenuItemIdx: Integer): Integer;
begin
  Result := -1;
  if (Length(FFuncItemArray) > MenuItemIdx) and (MenuItemIdx >= 0) then
    Result := FFuncItemArray[MenuItemIdx].CmdID;
end;

function EnumChildProc(Wnd: HWND; LParam: LPARAM): BOOL; stdcall;
var
  ClassName: array[0..255] of Char;
  ToolbarHandle: ^HWND;
begin
  // The Win32 API expects a character count, not a byte size. Passing
  // SizeOf(ClassName) doubled the limit for Unicode builds and could overrun
  // the fixed buffer for unusually long class names.
  GetClassName(Wnd, ClassName, Length(ClassName));
  if StrComp(ClassName, TOOLBARCLASSNAME) = 0 then
  begin
    ToolbarHandle := Pointer(LParam);
    ToolbarHandle^ := Wnd;
    Result := False;
  end
  else
    Result := True;
end;

function TNppPlugin.GetToolbarHandle: HWND;
begin
  Result := 0;
  EnumChildWindows(NppData.NppHandle, @EnumChildProc, LPARAM(@Result));
end;

procedure TNppPlugin.EnableMenuItem(MenuItemIdx: Integer; State: Boolean);
var
  PluginMenu: HMENU;
begin
  PluginMenu := HMENU(Host.SendNpp(NPPM_GETMENUHANDLE, NPPPLUGINMENU, 0));
  if PluginMenu <> 0 then
  begin
    Winapi.Windows.EnableMenuItem(PluginMenu, CmdIdFromMenuItemIdx(MenuItemIdx), MF_BYCOMMAND or IfThen(State, MF_ENABLED, MF_GRAYED));
    DrawMenuBar(NppData.NppHandle);
  end;
end;

procedure TNppPlugin.EnableToolbarItem(MenuItemIdx: Integer; State: Boolean);
var
  Toolbar: HWND;
begin
  Toolbar := GetToolbarHandle;
  if Toolbar <> 0 then
    Host.Send(Toolbar, TB_ENABLEBUTTON, WPARAM(CmdIdFromMenuItemIdx(MenuItemIdx)), LPARAM(State));
end;

procedure TNppPlugin.CheckMenuItem(MenuItemIdx: Integer; State: Boolean; Delayed: Boolean = true);
begin
  if Delayed then
    Host.PostNpp(NPPM_SETMENUITEMCHECK, WPARAM(CmdIdFromMenuItemIdx(MenuItemIdx)), LPARAM(State))
  else
    Host.SendNpp(NPPM_SETMENUITEMCHECK, WPARAM(CmdIdFromMenuItemIdx(MenuItemIdx)), LPARAM(State));
end;

procedure TNppPlugin.PerformMenuCommand(MenuCmdId: Integer; Param: Integer = 0; Delayed: Boolean = true);
begin
  if Delayed then
    Host.PostNpp(NPPM_MENUCOMMAND, WPARAM(Param), LPARAM(MenuCmdId))
  else
    Host.SendNpp(NPPM_MENUCOMMAND, WPARAM(Param), LPARAM(MenuCmdId))
end;

function TNppPlugin.GetMajorVersion: Integer;
begin
  Result := FPluginMajorVersion;
end;

function TNppPlugin.GetMinorVersion: Integer;
begin
  Result := FPluginMinorVersion;
end;

function TNppPlugin.GetReleaseNumber: Integer;
begin
  Result := FPluginReleaseNumber;
end;

function TNppPlugin.GetBuildNumber: Integer;
begin
  Result := FPluginBuildNumber;
end;

function TNppPlugin.GetCopyright: string;
begin
  Result := FPluginCopyright;
end;

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

function TNppPlugin.GetNppVersion(var MajorVersion, MinorVersion: Integer): Integer;
var
  Version: LRESULT;
begin
  Version := Host.SendNpp(NPPM_GETNPPVERSION, WPARAM(0), LPARAM(0));
  MajorVersion := HiWord(Version);
  MinorVersion := LoWord(Version);
  if MinorVersion < 10 then
    MinorVersion := MinorVersion * 100
  else if MinorVersion < 100 then
    MinorVersion := MinorVersion * 10;
  Result := MajorVersion;
end;

function TNppPlugin.IsNppMinVersion(AMajorVersion, AMinorVersion: Integer): Boolean;
var
  MajorVersion: Integer;
  MinorVersion: Integer;
begin
  GetNppVersion(MajorVersion, MinorVersion);
  if MajorVersion > AMajorVersion then
    Result := true
  else if (MajorVersion = AMajorVersion) and (MinorVersion >= AMinorVersion) then
    Result := true
  else
    Result := false;
end;

function TNppPlugin.IsDarkModeEnabled: Boolean;
begin
  Result := false;
  if IsNppMinVersion(8, 410) then
    Result := Host.SendNpp(NPPM_ISDARKMODEENABLED, 0, LPARAM(0)) > 0;
end;

function TNppPlugin.GetNppDir: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETNPPDIRECTORY);
end;

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

function TNppPlugin.GetPluginConfigDir: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETPLUGINSCONFIGDIR);
end;

function TNppPlugin.GetPluginDocDir: string;
begin
  Result := TPath.Combine(GetPluginDir(), 'doc');
end;

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

function TNppPlugin.GetNppWindowTitle: string;
var
  Len: Integer;
begin
  Len := GetWindowTextLength(NppData.NppHandle);
  SetLength(Result, Len);
  GetWindowText(NppData.NppHandle, PChar(Result), Len + 1);
end;

function TNppPlugin.GetFullCurrentPath: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETFULLCURRENTPATH);
end;

function TNppPlugin.GetCurrentDirectory: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETCURRENTDIRECTORY);
end;

function TNppPlugin.GetFullFileName: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETFILENAME);
end;

function TNppPlugin.GetFileNameWithoutExt: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETNAMEPART);
end;

function TNppPlugin.GetFileNameExt: string;
begin
  Result := GetVarSizeStringValue(NPPM_GETEXTPART);
end;

function TNppPlugin.GetEncoding: Integer;
begin
  Result := Host.SendNpp(NPPM_GETBUFFERENCODING, WPARAM(GetCurrentBufferId), LPARAM(0));
end;

function TNppPlugin.GetEOLFormat: Integer;
begin
  Result := Host.SendNpp(NPPM_GETBUFFERFORMAT, WPARAM(GetCurrentBufferId), LPARAM(0));
end;

function TNppPlugin.GetLanguageType: Integer;
begin
  Result := Host.SendNpp(NPPM_GETBUFFERLANGTYPE, WPARAM(GetCurrentBufferId), LPARAM(0));
  if Result = -1 then
    Result := C_NO_LANGUAGE;
end;

function TNppPlugin.GetLanguageName(ALangType: TNppLang): string;
var
  BufLen: LRESULT;

begin
  BufLen := Host.SendNpp(NPPM_GETLANGUAGENAME, WPARAM(ALangType), LPARAM(0));
  SetLength(Result, BufLen);

  BufLen := Host.SendNpp(NPPM_GETLANGUAGENAME, WPARAM(ALangType), LPARAM(nppPChar(Result)));
  SetLength(Result, BufLen);
end;

function TNppPlugin.GetLanguageDesc(ALangType: TNppLang): string;
var
  BufLen: LRESULT;

begin
  BufLen := Host.SendNpp(NPPM_GETLANGUAGEDESC, WPARAM(ALangType), LPARAM(0));
  SetLength(Result, BufLen);

  BufLen := Host.SendNpp(NPPM_GETLANGUAGEDESC, WPARAM(ALangType), LPARAM(nppPChar(Result)));
  SetLength(Result, BufLen);
end;

function TNppPlugin.GetCurrentViewIdx: Integer;
begin
  Result := Host.SendNpp(NPPM_GETCURRENTVIEW, WPARAM(0), LPARAM(0));
end;

function TNppPlugin.GetCurrentViewIdx(ScHandle: HWND): Integer;
begin
  if ScHandle = NppData.ScintillaMainHandle then
    Result := MAIN_VIEW

  else if ScHandle = NppData.ScintillaSecondHandle then
    Result := SUB_VIEW

  else
    Result := -1;
end;

function TNppPlugin.GetCurrentDocIndex(AViewIdx: Integer): Integer;
begin
  Result := Host.SendNpp(NPPM_GETCURRENTDOCINDEX, WPARAM(0), LPARAM(AViewIdx));
end;

function TNppPlugin.GetCurrentLine: NativeInt;
begin
  Result := Host.SendNpp(NPPM_GETCURRENTLINE, WPARAM(0), LPARAM(0));
end;

function TNppPlugin.GetCurrentColumn: LongInt;
begin
  Result := Host.SendNpp(NPPM_GETCURRENTCOLUMN, WPARAM(0), LPARAM(0));
end;

function TNppPlugin.GetCurrentBufferId: NativeInt;
begin
  Result := Host.SendNpp(NPPM_GETCURRENTBUFFERID, WPARAM(0), LPARAM(0));
end;

function TNppPlugin.GetBufferIdFromPos(AViewIdx, ADocIdx: Integer): NativeInt;
begin
  Result := Host.SendNpp(NPPM_GETBUFFERIDFROMPOS, WPARAM(ADocIdx), LPARAM(AViewIdx));
end;

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

function TNppPlugin.GetDarkModeColors(PColors: PNppDarkModeColors): Boolean;
begin
  Result := false;
  if IsDarkModeEnabled then
    Result := Host.SendNpp(NPPM_GETDARKMODECOLORS, SizeOf(TNppDarkModeColors), LParam(PColors)) > 0;
end;

function TNppPlugin.GetToolbarIconSetChoice: Integer;
begin
  Result := Host.SendNpp(NPPM_GETTOOLBARICONSETCHOICE, 0, 0);
end;

function TNppPlugin.GetOpenFilesCnt(CntType: Integer): Integer;
begin
  Result := Host.SendNpp(NPPM_GETNBOPENFILES, WPARAM(0), LParam(CntType));
end;

function TNppPlugin.GetOpenFiles(CntType: Integer): TStringDynArray;
  procedure AppendView(const ViewType: Integer);
  var
    FileCount: Integer;
    ViewIndex: Integer;
    BufferId: NativeInt;
    FileName: string;
  begin
    FileCount := GetOpenFilesCnt(ViewType);
    for ViewIndex := 0 to FileCount - 1 do
    begin
      BufferId := GetBufferIdFromPos(ViewType, ViewIndex);
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
  case CntType of
    ALL_OPEN_FILES:
      begin
        AppendView(PRIMARY_VIEW);
        AppendView(SECOND_VIEW);
      end;
    PRIMARY_VIEW, SECOND_VIEW:
      AppendView(CntType);
  end;
end;

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

procedure TNppPlugin.GetFilePos(out FileName: string; out Line: NativeInt; out Column: LongInt);
begin
  FileName := GetFullCurrentPath();
  Line := GetCurrentLine();
  Column := GetCurrentColumn();
end;

function TNppPlugin.GetCurrentWord: string;
begin
  // A corrupt/non-host transport must not make a word query grow toward a
  // multi-gigabyte allocation. One million UTF-16 code units is already well
  // beyond practical editor-token sizes.
  Result := GetVarSizeStringValue(NPPM_GETCURRENTWORD, $00100000);
end;

function TNppPlugin.OpenFile(FileName: string; ReadOnly: Boolean = false): Boolean;
var
  Cnt: Integer;
  Ret: Integer;
  FileNames: TStringDynArray;

begin
  // Ask if we are not already opened
  FileNames := GetOpenFiles(ALL_OPEN_FILES);

  for Cnt := Low(FileNames) to High(FileNames) do
  begin
    if SameFileName(FileNames[Cnt], FileName) then
    begin
      // Activate document tab and exit
      SwitchToFile(FileName);
      Exit(true);
    end;
  end;

  // Open the file
  Ret := Host.SendNpp(NPPM_DOOPEN, WPARAM(0), LPARAM(nppPChar(FileName)));
  Result := (Ret <> 0);

  // If requested set read-only state
  if Result and ReadOnly then
    PerformMenuCommand(IDM_EDIT_SETREADONLY, 1);
end;

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

function TNppPlugin.SaveFile(FileName: string): Boolean;
begin
  Result := Host.SendNpp(NPPM_SAVEFILE, WPARAM(0), LPARAM(nppPChar(FileName))) <> 0;
end;

function TNppPlugin.SaveCurrentFile: Boolean;
begin
  Result := Host.SendNpp(NPPM_SAVECURRENTFILE, WPARAM(0), LPARAM(0)) <> 0;
end;

function TNppPlugin.SaveAllFiles: Boolean;
begin
  Result := Host.SendNpp(NPPM_SAVEALLFILES, WPARAM(0), LPARAM(0)) <> 0;
end;

function TNppPlugin.SwitchToFile(FileName: string): Boolean;
begin
  Result := Host.SendNpp(NPPM_SWITCHTOFILE, 0, LPARAM(nppPChar(FileName))) <> 0;
end;

procedure TNppPlugin.ReloadFile(FileName: string; Alert: Boolean);
begin
  Host.SendNpp(NPPM_RELOADFILE, WPARAM(Alert), LPARAM(nppPChar(FileName)));
end;

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
procedure TNppPlugin.DoNppnReady;
begin
  // When overriding this ensure to call "inherited"

  // Retrieve version infos from plugin's DLL file
  // and write them to internal variables
  GetVersionInfo();
end;

// Notifies plugins that toolbar icons can be registered.
// hwndFrom = HWND hwndNpp
procedure TNppPlugin.DoNppnToolbarModification;
begin
  // override this
end;

// Notifies plugins that Npp shutdown has been triggered,
// files have not been closed yet
// hwndFrom = HWND hwndNpp
procedure TNppPlugin.DoNppnBeforeShutDown;
begin
  // override this
end;

// Notifies plugins that Notepad++ shut down has been cancelled
// hwndFrom = HWND hwndNpp
procedure TNppPlugin.DoNppnCancelShutDown;
begin
  // override this
end;

// Notifies plugins that Notepad++ is about to shut down
// hwndFrom = HWND hwndNpp
procedure TNppPlugin.DoNppnShutdown;
begin
  // override this
end;

// Notifies plugins that a file is about to be loaded
// hwndFrom = HWND hwndNpp
// idFrom   = NULL
procedure TNppPlugin.DoNppnFileBeforeLoad;
begin
  // override this
end;

// Notifies plugins that the file load operation failed
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnFileLoadFailed;
begin
  // override this
end;

// Notifies plugins that a file is about to be opened
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnFileBeforeOpen;
begin
  // override this
end;

// Notifies plugins that the current file just opened
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnFileOpened;
begin
  // override this
end;

// Notifies plugins that the current file is about to be closed
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnFileBeforeClose;
begin
  // override this
end;

// Notifies plugins that the current file is just closed
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnFileClosed;
begin
  // override this
end;

// Notifies plugins that the current file is about to be saved
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnFileBeforeSave;
begin
  // override this
end;

// Notifies plugins that the current file was just saved
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnFileSaved;
begin
  // override this
end;

// Notifies plugins that the current file is about to be renamed
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnFileBeforeRename;
begin
  // override this
end;

// Notifies plugins that user cancelled the file rename operation
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnFileRenameCancel;
begin
  // override this
end;

// Notifies plugins that the current file was just renamed
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnFileRenamed;
begin
  // override this
end;

// Notifies plugins that the current file is about to be deleted
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnFileBeforeDelete;
begin
  // override this
end;

// Notifies plugins that the file delete operation failed
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnFileDeleteFailed;
begin
  // override this
end;

// Notifies plugins that the current file was just deleted
// hwndFrom = HWND hwndNpp
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnFileDeleted;
begin
  // override this
end;

// Notifies plugins that a buffer was activated (put to foreground).
// hwndFrom = HWND hwndNpp
// idFrom   = int activatedBufferID
procedure TNppPlugin.DoNppnBufferActivated;
begin
  // override this
end;

// Notifies plugins that the language in the current doc just changed.
// hwndFrom = HWND hwndNpp
// idFrom   = int currentBufferID
procedure TNppPlugin.DoNppnLangChanged;
begin
  // override this
end;

// Notifies plugins that the read-only state of the current buffer was changed
// hwndFrom = int bufferID
// idFrom   = int docStatus   can be combined by
// DOCSTATUS_READONLY = 1
// DOCSTATUS_BUFFERDIRTY = 2
procedure TNppPlugin.DoNppnReadOnlyChanged;
begin
  // override this
end;

// Notifies plugins that document order is changed,
// Tab dragged by mouse: buffer bufferID previously had index oldIndex.
// hwndFrom = int oldIndex
// idFrom   = int bufferID
// Tab moved by menu command: buffer bufferID having index newIndex.
// hwndFrom = int newIndex
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnDocOrderChanged;
begin
  // override this
end;

// Notifies plugins that a plugin command shortcut is remapped.
// hwndFrom = PShortcutKey ShortcutKeyStructure
// idFrom   = int cmdID
procedure TNppPlugin.DoNppnShortcutRemapped;
begin
  // override this
end;

// Notifies plugins that user initiated a WordStyleDlg change.
// hwndFrom = HWND hwndNpp
// idFrom   = int currentBufferID
procedure TNppPlugin.DoNppnWordStylesUpdated;
begin
  // override this
end;

// Notifies plugins that a snapshot dirty file is loaded on startup.
// hwndFrom = NULL
// idFrom   = int bufferID
procedure TNppPlugin.DoNppnSnapshotDirtyFileLoaded;
begin
  // override this
end;

// Notifies plugins that Dark Mode was enabled/disabled. Use NPPM_ISDARKMODEENABLED
// to query Dark Mode status.
// hwndFrom = HWND hwndNpp
procedure TNppPlugin.DoNppnDarkModeChanged;
begin
  // override this
end;

// Notifies plugins that command line contains an argument for plugins (in the
// form -pluginMessage="YOUR_PLUGIN_ARGUMENT")
// hwndFrom = HWND hwndNpp
// idFrom   = wchar_t *pluginMessage
procedure TNppPlugin.DoNppnCmdLinePluginMsg;
begin
  // override this
end;

// Notifies lexer plugins that the buffer (in idFrom) is just applied to an
// external lexer
// scnNotification->nmhdr.code = NPPN_EXTERNALLEXERBUFFER;
// scnNotification->nmhdr.hwndFrom = hwndNpp;
// scnNotification->nmhdr.idFrom = BufferID;
procedure TNppPlugin.DoNppExternalLexerBuffer;
begin
  // override this
end;

// Notifies plugins that the current document is just modified by Replace All action.
// For solving the performance issue (from v8.6.4), Notepad++ doesn't trigger SCN_MODIFIED during Replace All action anymore.
// As a result, the plugins which monitor SCN_MODIFIED should also monitor NPPN_GLOBALMODIFIED.
// scnNotification->nmhdr.code = NPPN_GLOBALMODIFIED;
// scnNotification->nmhdr.hwndFrom = BufferID;
// scnNotification->nmhdr.idFrom = 0; // preserved for future use, must be zero
procedure TNppPlugin.DoNppGlobalModified;
begin
  // override this
end;

// To notify plugins that the current native language is just changed to another one.
// Use NPPM_GETNATIVELANGFILENAME to get current native language file name.
// Use NPPM_GETMENUHANDLE(NPPPLUGINMENU, 0) to get submenu "Plugins" handle (HMENU)
//scnNotification->nmhdr.code = NPPN_NATIVELANGCHANGED;
//scnNotification->nmhdr.hwndFrom = hwndNpp
//scnNotification->nmhdr.idFrom = 0; // preserved for the future use, must be zero
procedure TNppPlugin.DoNppNativeLangChanged;
begin
  // override this
end;

// To notify plugins that toolbar icon set selection has changed
//scnNotification->nmhdr.code = NPPN_TOOLBARICONSETCHANGED;
//scnNotification->nmhdr.hwndFrom = hwndNpp;
//scnNotification->nmhdr.idFrom = iconSetChoice;
// where iconSetChoice could be 1 of 5 possible values:
// 0 (Fluent UI: small), 1 (Fluent UI: large), 2 (Filled Fluent UI: small), 3 (Filled Fluent UI: large) and 4 (Standard icons: small).
procedure TNppPlugin.DoNppToolbarIconsetChanged;
begin
  // override this
end;

end.
