unit ESPHomePlugin;

interface

uses
  Winapi.Windows, System.SysUtils, System.StrUtils,
  System.Classes,
  Vcl.Graphics,
  NppSupport, NppPlugin, NppPluginForms, NppPluginDockingForms,
  ESPHomeShared;

const
  csPluginName = 'NppESPHome';
  csMenuEmptyLine = '-';

type
  TFuncMapRecord = record
    ID: string;
    MenuName: string;
    FuncAddress: PFuncPluginCmd;
    ShortcutKey: PShortcutKey;
    HasToolbar: Boolean;
  end;

type
  TESPHomePlugin = class(TNppPlugin)
  public
    procedure SelectProject;
    procedure ConfigureProject;
    procedure OpenProject;
    procedure OpenProjectAndDependencies;
    procedure SaveProject;
    procedure SaveProjectAndDependencies;

    procedure CommandRun;
    procedure CommandCompile;
    procedure CommandUpload;
    procedure CommandShowLogs;
    procedure CommandClean;
    procedure CommandVisit;
    procedure CommandUpgrade;
    procedure CommandShowHelp;
    procedure CommandShellPrompt;
    procedure CommandExplorer;
    procedure CommandToolbar;
    procedure CommandAbout;
    procedure CommandShowHide;

  protected
    procedure DoNppnReady; override;
    procedure DoNppnShutdown; override;
    procedure DoNppnShortcutRemapped; override;
    procedure DoNppnToolbarModification; override;
    procedure DoNppnDarkModeChanged; override;
    procedure DoNppnBufferActivated; override;

  public
    constructor Create; override;
    procedure UpdateProjectList;
    procedure UpdatePluginMenu;

    function CheckESPHome: Boolean;
    function CheckCurrentProject: Boolean;

  end;

var
  // Plugin instance variable, this is the reference to use in plugin's code
  Plugin: TESPHomePlugin;
  // Class type to create in startup code
  PluginClass: TNppPluginClass = TESPHomePlugin;
  // Mapping of the Functions configuration
  FuncMapping: array of TFuncMapRecord;

implementation

{$B-}

uses
  JvCreateProcess, Winapi.ShellAPI, UnitFormSelection, UnitFormConfig,
  UnitFormToolbar, UnitFormAbout, UnitFormProjects, IniFiles, System.RegularExpressions;

resourcestring
  rsInvalidESPHomeInstallation = 'No valid installation of ESPHome has been found on your system.' +
    #13#10'Please (re)install ESPHome following the instructions available on the following web page:' +
    #13#13#10'https://www.esphome.io/guides/installing_esphome/';

  rsNoProjectSelected = 'No ESPHome project is currently selected.' + #13#13#10'To use this command, please select the current project and try again.' +
    #13#10'You can select it through the menù command:' + #13#10'"Plugins" -> "NppESPHome" -> "Select Project..."';

  rsNoWebserverOnCurrentProject = 'Selected ESPHome project (%s) does not have Webserver component enabled.' +
    #13#13#10'Visit command cannot work and it is ignored.';

{$REGION 'Virtual Procedures'}

procedure _SelectProject; cdecl;
begin
  Plugin.SelectProject;
end;

procedure _ConfigureProject; cdecl;
begin
  Plugin.ConfigureProject;
end;

procedure _CommandRun; cdecl;
begin
  Plugin.CommandRun;
end;

procedure _CommandCompile; cdecl;
begin
  Plugin.CommandCompile;
end;

procedure _CommandUpload; cdecl;
begin
  Plugin.CommandUpload;
end;

procedure _CommandShowLogs; cdecl;
begin
  Plugin.CommandShowLogs;
end;

procedure _CommandClean; cdecl;
begin
  Plugin.CommandClean;
end;

procedure _CommandVisit; cdecl;
begin
  Plugin.CommandVisit;
end;

procedure _CommandUpgrade; cdecl;
begin
  Plugin.CommandUpgrade;
end;

procedure _CommandShowHelp; cdecl;
begin
  Plugin.CommandShowHelp;
end;

procedure _CommandShellPrompt; cdecl;
begin
  Plugin.CommandShellPrompt;
end;

procedure _OpenProject; cdecl;
begin
  Plugin.OpenProject;
end;

procedure _OpenProjectAndDependencies; cdecl;
begin
  Plugin.OpenProjectAndDependencies;
end;

procedure _CommandExplorer; cdecl;
begin
  Plugin.CommandExplorer;
end;

procedure _CommandToolbar; cdecl;
begin
  Plugin.CommandToolbar;
end;

procedure _CommandAbout; cdecl;
begin
  Plugin.CommandAbout;
end;

procedure _CommandShowHide; cdecl;
begin
  Plugin.CommandShowHide;
end;

{$ENDREGION}

function ShortcutToString(const S: PShortcutKey): string;
var
  Parts: TArray<string>;
  KeyName: array [0 .. 255] of Char;
begin
  SetLength(Parts, 0);
  if S.IsCtrl then
    Parts := Parts + ['Ctrl'];
  if S.IsAlt then
    Parts := Parts + ['Alt'];
  if S.IsShift then
    Parts := Parts + ['Shift'];
  if S.Key <> 0 then
  begin
    if GetKeyNameText(MapVirtualKey(S.Key, MAPVK_VK_TO_VSC) shl 16, KeyName, Length(KeyName)) > 0 then
      Parts := Parts + [KeyName]
    else
      Parts := Parts + [Format('VK_%d', [S.Key])];
  end;
  Result := Trim(string.Join('+', Parts));
end;

function MakeShortcutKey(const Ctrl, Alt, Shift: Boolean; const AKey: UCHAR): PShortcutKey;
begin
  Result := New(PShortcutKey);
  with Result^ do
  begin
    IsCtrl := Ctrl;
    IsAlt := Alt;
    IsShift := Shift;
    Key := AKey;
  end;
end;

constructor TESPHomePlugin.Create;
var
  Index: Integer;
begin
  inherited Create;
  Plugin := Self;
  PluginName := csPluginName;

  for Index := 0 to Length(FuncMapping) - 1 do
    with FuncMapping[Index] do
      AddFuncItem(MenuName, FuncAddress, ShortcutKey);

end;

procedure TESPHomePlugin.DoNppnReady;
begin
  inherited;
  ModuleInitialize;
  FormProjects := TFormProjects.Create(Plugin, 19);
  if ConfigFile.ReadBool(csSectionGeneral, csKeyProjectWindow, False) then
    FormProjects.Show
  else
    FormProjects.Hide;
  UpdatePluginMenu;
end;

procedure TESPHomePlugin.DoNppnShutdown;
begin
  ModuleFinalize;
  if Assigned(FormProjects) then
    FormProjects.Free;
  inherited;
end;

procedure TESPHomePlugin.DoNppnShortcutRemapped;
begin
  UpdatePluginMenu;
end;

procedure TESPHomePlugin.DoNppnToolbarModification;
var
  IniFile: TIniFile;
  Index, Count: Integer;
  ToolbarConfig, DefaultConfig: string;
  Item, Pattern: string;
  Parts: TArray<string>;
  Regex: TRegEx;
  Bitmap: TBitmap;
  IconLight, IconDark: TIcon;
  IconData: TToolbarIconsWithDarkMode;
begin
  inherited;
  if IsNppMinVersion(8, 0) then
  begin
    Count := 0;
    DefaultConfig := '';
    for Index := 0 to Length(FuncMapping) - 1 do
      if FuncMapping[Index].HasToolbar then
      begin
        DefaultConfig := Concat(DefaultConfig, IntToStr(Index), ':1;');
        Inc(Count);
      end;

    IniFile := TIniFile.Create(IncludeTrailingPathDelimiter(Plugin.GetPluginConfigDir) + ChangeFileExt(Plugin.GetName, '.ini'));
    ToolbarConfig := IniFile.ReadString(csSectionGeneral, csKeyToolbarConfig, DefaultConfig);
    IniFile.Free;

    Pattern := Format('^(?:\d+:[01];){%d}$', [Count]);
    Regex := TRegEx.Create(Pattern);
    if not Regex.IsMatch(ToolbarConfig) then
      ToolbarConfig := DefaultConfig;

    for Item in ToolbarConfig.Split([';'], TStringSplitOptions.ExcludeEmpty) do
    begin
      if Item <> '' then
      begin
        Parts := Item.Split([':']);
        if Length(Parts) = 2 then
        begin
          Val(Parts[0], Index, Count);
          if (Count = 0) and (Index < Length(FuncMapping)) and (Parts[1] = '1') then
          begin
            Bitmap := TBitmap.Create;
            IconLight := TIcon.Create;
            IconDark := TIcon.Create;
            Bitmap.LoadFromResourceName(HInstance, FuncMapping[Index].ID);
            Bitmap.PixelFormat := pf8Bit;
            IconLight.LoadFromResourceName(HInstance, Concat(FuncMapping[Index].ID, DarkModeSuffix[False]));
            IconDark.LoadFromResourceName(HInstance, Concat(FuncMapping[Index].ID, DarkModeSuffix[True]));
            IconData.ToolbarBmp := Bitmap.Handle;
            IconData.ToolbarIcon := IconDark.Handle;
            IconData.ToolbarIconDarkMode := IconLight.Handle;
            Bitmap.TransparentMode := tmAuto;
            Bitmap.TransparentColor := TColor($FFFFFF);
            Bitmap.Transparent := True;
            AddToolbarIconEx(CmdIdFromMenuItemIdx(Index), IconData);
          end;
        end;
      end;
    end;

  end;
end;

procedure TESPHomePlugin.DoNppnDarkModeChanged;
begin
  if Assigned(FormProjects) then
    FormProjects.ToggleDarkMode;
end;

procedure TESPHomePlugin.DoNppnBufferActivated;
begin
  if Assigned(FormProjects) then
    FormProjects.CurrentDocumentChanged;
end;

procedure ExecuteESPHomeCommand(const Command: Integer);
const
  CommandStr: array [scRun .. scClean] of string = ('run', 'compile', 'upload', 'logs', 'clean');
var
  CommandLine, Switch, Device: string;
  ESPHomeProcess: TJvCreateProcess;
begin
  if not Assigned(ProjectList.Current) or not FileExists(ESPHomeExeFile) then
    Exit;

  with ProjectList.Current do
  begin
    case GetOption(csKeyNppAutosave, ciAutoSaveAllFiles) of
      ciAutoSaveProject:
        Plugin.SaveProject;
      ciAutoSaveProjectAndDeps:
        Plugin.SaveProjectAndDependencies;
      ciAutoSaveAllFiles:
        Plugin.SaveAllFiles;
    end;

    if GetOption(csKeyESPHomeAutoClose, True) then
      CommandLine := '/c'
    else
      CommandLine := '/k';

    CommandLine := Format('%s %s', [CommandLine, ShortFileName(ESPHomeExeFile)]);

    case GetOption(csKeyESPHomeLogLevel, ciLogLevelDefault) of
      ciLogLevelCritical:
        Switch := 'CRITICAL';
      ciLogLevelError:
        Switch := 'ERROR';
      ciLogLevelWarning:
        Switch := 'WARNING';
      ciLogLevelInfo:
        Switch := 'INFO';
      ciLogLevelDebug:
        Switch := 'DEBUG';
    else
      Switch := csDefaultEmpty;
    end;

    if Switch <> csDefaultEmpty then
      CommandLine := Format('%s -l %s', [CommandLine, Switch]);

    Switch := Trim(GetOption(csKeyESPHomeExtraParameters, csDefaultEmpty));
    if Switch <> csDefaultEmpty then
      CommandLine := Format('%s %s', [CommandLine, Switch]);

    Device := GetOption(csKeyESPHomeTargetDevice, rsDefaultNone);
    if Device <> rsDefaultNone then
    begin
      if Device = rsDefaultWiFi then
        Device := HostName;
      Device := Concat('--device ', Device);
    end
    else
      Device := csDefaultEmpty;

    case Command of
      scRun:
        begin
          Switch := Trim(GetOption(csKeyRunExtraParameters, csDefaultEmpty));
          if GetOption(csKeyRunReset, False) then
            Switch := Concat('--reset ', Switch);
          if GetOption(csKeyRunNoLogs, False) then
            Switch := Concat('--no-logs ', Switch);
          if Device <> csDefaultEmpty then
            Switch := Concat(Device, ' ', Switch);
        end;
      scCompile:
        begin
          Switch := csDefaultEmpty;
          if GetOption(csKeyCompileGenerateOnly, False) then
            Switch := Concat('--only-generate ', Switch);
        end;
      scUpload:
        begin
          Switch := Trim(GetOption(csKeyUploadExtraParameters, csDefaultEmpty));
          if Device <> csDefaultEmpty then
            Switch := Concat(Device, ' ', Switch);
        end;
      scLogs:
        begin
          Switch := Trim(GetOption(csKeyLogsExtraParameters, csDefaultEmpty));
          if GetOption(csKeyLogsReset, False) then
            Switch := Concat('--reset ', Switch);
          if Device <> csDefaultEmpty then
            Switch := Concat(Device, ' ', Switch);
        end;
      scClean:
        begin
          Switch := csDefaultEmpty;
        end;
    end;

    CommandLine := Trim(Format('%s %s %s', [CommandLine, CommandStr[Command], Switch]));
    CommandLine := Trim(Format('%s %s', [CommandLine, ShortFileName(ExpandFileName(FileName))]));

    if GetOption(csKeyESPHomeAutoClose, True) then
      CommandLine := Concat(CommandLine, ' || pause');

    ESPHomeProcess := TJvCreateProcess.Create(nil);
    ESPHomeProcess.ApplicationName := GetEnvironmentVariable('ComSpec');
    ESPHomeProcess.CommandLine := CommandLine;
    ESPHomeProcess.CurrentDirectory := ExtractFilePath(ProjectList.Current.FileName);
    ESPHomeProcess.Run;
    ESPHomeProcess.Free;

  end;
end;

procedure TESPHomePlugin.SelectProject;
begin
  FormSelection := TFormSelection.Create(Self);
  FormSelection.ShowModal;
  FreeAndNil(FormSelection);
  UpdatePluginMenu;
end;

procedure TESPHomePlugin.ConfigureProject;
begin
  if CheckCurrentProject then
  begin
    FormConfiguration := TFormConfig.Create(Self);
    FormConfiguration.ShowModal;
    FreeAndNil(FormConfiguration);
  end;
end;

procedure TESPHomePlugin.CommandRun;
begin
  if CheckESPHome and CheckCurrentProject then
    ExecuteESPHomeCommand(scRun);
end;

procedure TESPHomePlugin.CommandCompile;
begin
  if CheckESPHome and CheckCurrentProject then
    ExecuteESPHomeCommand(scCompile);
end;

procedure TESPHomePlugin.CommandUpload;
begin
  if CheckESPHome and CheckCurrentProject then
    ExecuteESPHomeCommand(scUpload);
end;

procedure TESPHomePlugin.CommandShowLogs;
begin
  if CheckESPHome and CheckCurrentProject then
    ExecuteESPHomeCommand(scLogs);
end;

procedure TESPHomePlugin.CommandClean;
begin
  if CheckESPHome and CheckCurrentProject then
    ExecuteESPHomeCommand(scClean);
end;

procedure TESPHomePlugin.CommandVisit;
var
  URL: string;
begin
  if not CheckCurrentProject then
    Exit;

  if not ProjectList.Current.HasWebServer then
  begin
    MessageBox(0, PWideChar(Format(rsNoWebserverOnCurrentProject, [ProjectList.Current.FriendlyName])), PWideChar(rsMessageBoxWarning),
      MB_ICONWARNING or MB_OK);
    Exit;
  end;

  if ProjectList.Current.HostName <> '' then
  begin
    URL := 'http://' + ProjectList.Current.HostName;
    ShellExecute(0, 'open', PChar(URL), nil, nil, SW_SHOWNORMAL);
  end;
end;

procedure TESPHomePlugin.CommandUpgrade;
var
  JvCreateProcess: TJvCreateProcess;
begin
  if not CheckESPHome then
    Exit;

  JvCreateProcess := TJvCreateProcess.Create(nil);
  JvCreateProcess.ApplicationName := GetEnvironmentVariable('ComSpec');
  JvCreateProcess.CommandLine := Format('/c pip.exe install --upgrade esphome & %s --version & pause', [ShortFileName(ESPHomeExeFile)]);
  JvCreateProcess.Run;
  JvCreateProcess.Free;
end;

procedure TESPHomePlugin.CommandShowHelp;
begin
  ShellExecute(0, 'open', PChar(rsESPHomeDocURL), nil, nil, SW_SHOWNORMAL);
end;

procedure TESPHomePlugin.CommandShellPrompt;
var
  JvCreateProcess: TJvCreateProcess;
begin
  if not CheckCurrentProject then
    Exit;

  JvCreateProcess := TJvCreateProcess.Create(nil);
  JvCreateProcess.ApplicationName := GetEnvironmentVariable('ComSpec');
  JvCreateProcess.CurrentDirectory := ExtractFilePath(ProjectList.Current.FileName);
  JvCreateProcess.CommandLine := '';
  JvCreateProcess.Run;
  JvCreateProcess.Free;
end;

procedure TESPHomePlugin.OpenProject;
begin
  if not CheckCurrentProject then
    Exit;
  OpenFile(ProjectList.Current.FileName);
end;

procedure TESPHomePlugin.OpenProjectAndDependencies;
var
  FileName: string;
begin
  if not CheckCurrentProject then
    Exit;

  OpenFile(ProjectList.Current.FileName);
  ProjectList.Current.LoadOptionDependencies;
  for FileName in ProjectList.Current.OptionDependencies do
    if FileExists(FileName) then
      OpenFile(FileName);
  SwitchToFile(ProjectList.Current.FileName);
end;

procedure TESPHomePlugin.SaveProject;
begin
  if Assigned(ProjectList.Current) then
    SaveFile(ProjectList.Current.FileName);
end;

procedure TESPHomePlugin.SaveProjectAndDependencies;
var
  S: string;
  CurrentFile: string;
begin
  if Assigned(ProjectList.Current) then
  begin
    CurrentFile := GetFullCurrentPath;
    if SwitchToFile(ProjectList.Current.FileName) then
      SaveCurrentFile;
    for S in ProjectList.Current.OptionDependencies do
      if SwitchToFile(S) then
        SaveCurrentFile;
    SwitchToFile(CurrentFile);
  end;
end;

procedure TESPHomePlugin.CommandExplorer;
begin
  if not CheckCurrentProject then
    Exit;
  if ProjectList.Current.FileName <> '' then
    ShellExecute(0, 'open', PChar(ExtractFilePath(ProjectList.Current.FileName)), nil, nil, SW_SHOWNORMAL);
end;

procedure TESPHomePlugin.CommandToolbar;
begin
  FormToolbar := TFormToolbar.Create(Self);
  FormToolbar.ShowModal;
  FreeAndNil(FormToolbar);
end;

procedure TESPHomePlugin.CommandAbout;
begin
  FormAbout := TFormAbout.Create(Self);
  FormAbout.ShowModal;
  FreeAndNil(FormAbout);
end;

procedure TESPHomePlugin.CommandShowHide;
begin
  if not Assigned(FormProjects) then
    Exit;
  if FormProjects.Visible then
    FormProjects.Hide
  else
    FormProjects.Show;
  ConfigFile.WriteBool(csSectionGeneral, csKeyProjectWindow, FormProjects.Visible);
end;

procedure TESPHomePlugin.UpdateProjectList;
begin
  if Assigned(FormProjects) then
    FormProjects.RefreshProjectsList;
  UpdatePluginMenu;
end;

(* ************ Explanation ***************
  This procedure is part of a Delphi plugin (likely for Notepad++ since it uses NPP handles and messages) that
  updates the plugin’s menu. Here’s a step‐by‐step explanation of what it does:

  1. It begins by obtaining the handle to the plugin menu. This is done by
  sending a Windows message (NPPM_GETMENUHANDLE) to the main Notepad++ window (using NppData.NppHandle). If the menu handle returned is valid (not 0), it
  proceeds.

  2. The procedure then loops through all the top‑level menu items (using GetMenuItemCount on the plugin menu). For each menu item, it retrieves the
  text (using GetMenuString) into a character buffer.

  3. The retrieved menu text is processed by removing any ampersand characters (used for mnemonic
  definitions) and trimming spaces. It then extracts the left part of the string with a length equal to the plugin’s name. This is done so it can check if the
  current menu item belongs to this plugin (by comparing it case‑insensitively with the Plugin.PluginName).

  4. Once it finds the matching menu item, it gets
  that item’s submenu with GetSubMenu. This submenu is where the plugin’s commands (or submenu items) are registered.

  5. Inside the submenu, it prepares new
  text for the first menu item (the item at index 0). The new menu text depends on whether a current project is assigned. If there is a current project
  (ProjectList.Current is assigned), it uses a formatted string (rsMenuSelectProjectCurrent) that includes the project’s friendly name. Otherwise, it resorts to a
  default text (rsMenuSelectProject).

  6. The code then retrieves the function item (using GetFuncByIndex(0)) associated with this menu command, and if found,
  it attempts to get the shortcut key (by sending the message NPPM_GETSHORTCUTBYCMDID with the command ID). If a shortcut is found, it appends the shortcut key
  (converted to a string via ShortcutToString) to the menu text. A tab character (#09) is used to separate the main text from the shortcut text.

  7. The
  procedure uses ModifyMenu to update the first menu item in the submenu with the new text. The update is based on parameters that specify the position
  (MF_BYPOSITION) and string update (MF_STRING), and it reuses the original menu item ID.

  8. Finally, the menu bar is redrawn (using DrawMenuBar) so that the
  changes become visible immediately in the Notepad++ interface.

  In summary, this code scans through the plugin’s menu to locate the correct submenu, then
  dynamically updates its first item—changing its label to either indicate the currently selected project (including its friendly name) or a default “select
  project” message, and appending any associated shortcut key.
*)
procedure TESPHomePlugin.UpdatePluginMenu;
var
  Index: Integer;
  MenuText: string;
  FuncItem: Pointer;
  PluginMenu: HMENU;
  SK: TShortcutKey;
  Buffer: array [0 .. 255] of Char;
begin
  PluginMenu := HMENU(SendMessage(NppData.NppHandle, NPPM_GETMENUHANDLE, NPPPLUGINMENU, 0));
  if PluginMenu <> 0 then
  begin
    for Index := 0 to GetMenuItemCount(PluginMenu) - 1 do
    begin
      GetMenuString(PluginMenu, Index, Buffer, SizeOf(Buffer), MF_BYPOSITION);
      MenuText := LeftStr(Trim(StringReplace(Buffer, '&', '', [rfReplaceAll])), Length(Plugin.PluginName));
      if SameText(MenuText, Plugin.PluginName) then
      begin
        PluginMenu := GetSubMenu(PluginMenu, Index);
        if PluginMenu <> 0 then
        begin
          if Assigned(ProjectList.Current) then
            MenuText := Format(rsMenuSelectProjectCurrent, [ProjectList.Current.FriendlyName])
          else
            MenuText := rsMenuSelectProject;
          FuncItem := GetFuncByIndex(0);
          if Assigned(FuncItem) and (SendMessage(NppData.NppHandle, NPPM_GETSHORTCUTBYCMDID, TFuncItem(FuncItem^).CmdID, LPARAM(@SK)) <> 0) then
            MenuText := MenuText + #09 + ShortcutToString(@SK);
          ModifyMenu(PluginMenu, 0, MF_BYPOSITION or MF_STRING, GetMenuItemID(PluginMenu, 0), PChar(MenuText));
          DrawMenuBar(NppData.NppHandle);
        end;
        Break;
      end;
    end;
  end;
end;

function TESPHomePlugin.CheckESPHome: Boolean;
begin
  Result := False;
  if not FileExists(ESPHomeExeFile) then
    MessageBox(0, PWideChar(rsInvalidESPHomeInstallation), PWideChar(rsMessageBoxError), MB_ICONERROR or MB_OK)
  else
    Result := True;
end;

function TESPHomePlugin.CheckCurrentProject: Boolean;
begin
  Result := False;
  if not Assigned(ProjectList.Current) then
    MessageBox(0, PWideChar(rsNoProjectSelected), PWideChar(rsMessageBoxError), MB_ICONSTOP or MB_OK)
  else
    Result := True;
end;

procedure SetFuncMapRecord(const Index: Integer; const ID, MenuName: string; const FuncAddress: PFuncPluginCmd; const ShortcutKey: PShortcutKey;
  const HasToolbar: Boolean = False);
begin
  FuncMapping[Index].ID := ID;
  FuncMapping[Index].MenuName := MenuName;
  FuncMapping[Index].FuncAddress := FuncAddress;
  FuncMapping[Index].ShortcutKey := ShortcutKey;
  FuncMapping[Index].HasToolbar := HasToolbar;
end;

initialization

SetLength(FuncMapping, 23);

SetFuncMapRecord(0, 'select', rsMenuSelectProject, _SelectProject, MakeShortcutKey(True, True, False, $79), True);
SetFuncMapRecord(1, 'configure', rsMenuConfigProject, _ConfigureProject, MakeShortcutKey(True, False, False, $79), True);
SetFuncMapRecord(2, '', csMenuEmptyLine, nil, nil);
SetFuncMapRecord(3, 'open', rsMenuOpenProjectFile, _OpenProject, nil, True);
SetFuncMapRecord(4, 'opendeps', rsMenuOpenProjectFileAndDeps, _OpenProjectAndDependencies, nil, True);
SetFuncMapRecord(5, '', csMenuEmptyLine, nil, nil);
SetFuncMapRecord(6, 'run', rsMenuCommandRun, _CommandRun, MakeShortcutKey(False, False, False, $78), True);
SetFuncMapRecord(7, 'compile', rsMenuCommandCompile, _CommandCompile, MakeShortcutKey(False, False, False, $77), True);
SetFuncMapRecord(8, 'upload', rsMenuCommandUpload, _CommandUpload, MakeShortcutKey(True, False, False, $77), True);
SetFuncMapRecord(9, 'showlogs', rsMenuCommandShowLogs, _CommandShowLogs, nil, True);
SetFuncMapRecord(10, 'clean', rsMenuCommandClean, _CommandClean, nil, True);
SetFuncMapRecord(11, 'visit', rsMenuCommandVisit, _CommandVisit, nil, True);
SetFuncMapRecord(12, '', csMenuEmptyLine, nil, nil);
SetFuncMapRecord(13, 'help', rsMenuOpenESPHomeDocs, _CommandShowHelp, MakeShortcutKey(True, False, False, $70), True);
SetFuncMapRecord(14, 'upgrade', rsMenuUpgradeESPHome, _CommandUpgrade, nil, True);
SetFuncMapRecord(15, '', csMenuEmptyLine, nil, nil);
SetFuncMapRecord(16, 'cmdshell', rsMenuOpenCmdShell, _CommandShellPrompt, nil);
SetFuncMapRecord(17, 'explorer', rsMenuOpenExplorer, _CommandExplorer, nil);
SetFuncMapRecord(18, '', csMenuEmptyLine, nil, nil);
SetFuncMapRecord(19, 'showhide', rsMenuShowHide, _CommandShowHide, nil, True);
SetFuncMapRecord(20, '', csMenuEmptyLine, nil, nil);
SetFuncMapRecord(21, 'toolbar', rsMenuToolbar, _CommandToolbar, nil);
SetFuncMapRecord(22, 'about', rsMenuAbout, _CommandAbout, nil);

end.
