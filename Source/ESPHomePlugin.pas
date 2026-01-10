unit ESPHomePlugin;

interface

uses
  Winapi.Windows, System.SysUtils, System.StrUtils, System.Classes, Vcl.Graphics, NppSupport, NppPlugin, NppPluginForms, NppPluginDockingForms, ESPHomeShared;


const
  csPluginName = 'NppESPHome';
  csMenuEmptyLine = '-';

const
  ItemID_SelectProject = 0;
  ItemID_ConfigureProject = 1;
  ItemID_MenuSeparator1 = 2;
  ItemID_OpenProject = 3;
  ItemID_OpenProjectAndDependencies = 4;
  ItemID_MenuSeparator2 = 5;
  ItemID_CommandRun = 6;
  ItemID_CommandCompile = 7;
  ItemID_CommandUpload = 8;
  ItemID_CommandShowLogs = 9;
  ItemID_CommandClean = 10;
  ItemID_CommandVisit = 11;
  ItemID_MenuSeparator3 = 12;
  ItemID_Help = 13;
  ItemID_Upgrade = 14;
  ItemID_MenuSeparator4 = 15;
  ItemID_CmdShell = 16;
  ItemID_Explorer = 17;
  ItemID_MenuSeparator5 = 18;
  ItemID_ShowHideWindow = 19;
  ItemID_MenuSeparator6 = 20;
  ItemID_Toolbar = 21;
  ItemID_About = 22;

const
  ToolbarIconItemKey: array[ItemID_SelectProject..ItemID_About] of string = ('select', 'configure', '', 'open', 'opendeps', '',
    'run', 'compile', 'upload', 'showlogs', 'clean', 'visit', '', 'help', 'upgrade', '', 'terminal', 'explorer', '',
    'showhide', '', '', '');

type
  TESPHomePlugin = class(TNppPlugin)
    OperationsOngoing: Boolean;

  public
    procedure SelectProject;
    procedure ConfigureProject;
    procedure OpenProject;
    procedure OpenProjectAndDependencies(CurrentFile: string = '');
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
    procedure DoNppnFileOpened; override;
    procedure DoNppnFileSaved; override;

  public
    constructor Create; override;
    procedure UpdateProjectList;
    procedure UpdatePluginMenuAndTitle;

    function CheckESPHome: Boolean;
    function CheckCurrentProject: Boolean;

  end;

var
  // Plugin instance variable, this is the reference to use in plugin's code
  Plugin: TESPHomePlugin;
  // Class type to create in startup code
  PluginClass: TNppPluginClass = TESPHomePlugin;
  // Mapping of the Functions configuration

implementation

{$B-}

uses
  JvCreateProcess, Winapi.ShellAPI, UnitFormSelection, UnitFormConfig,
  UnitFormToolbar, UnitFormAbout, UnitFormProjects, IniFiles, System.RegularExpressions, TDMB, Vcl.Dialogs;

resourcestring
  rsInvalidESPHomeInstallation = 'No valid installation of ESPHome has been found on your system.';
  rsInvalidESPHomeInstallation2 = 'Please (re)install ESPHome following the instructions available on the following web page:';
  rsInvalidESPHomeInstallation3 = '<a href="https://www.esphome.io/guides/installing_esphome/">Installing ESPHome Manually</a>';

  rsNoProjectSelected = 'No ESPHome project is currently selected.';
  rsNoProjectSelected2 = 'To use this command, please select the current project and try again.'#13#13#10'You can select it through the menù command:'#13#10'"Plugins" -> "NppESPHome" -> "Select Project..."';

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
begin
  inherited Create;
  OperationsOngoing := True;
  Plugin := Self;
  PluginName := csPluginName;

  AddFuncItem(ItemID_SelectProject, rsMenuSelectProject, _SelectProject, MakeShortcutKey(True, True, False, $79));
  AddFuncItem(ItemID_ConfigureProject, rsMenuConfigProject, _ConfigureProject, MakeShortcutKey(True, False, False, $79));

  AddFuncItem(ItemID_MenuSeparator1, csMenuEmptyLine, nil, nil); // Menù separator
  AddFuncItem(ItemID_OpenProject, rsMenuOpenProjectFile, _OpenProject, nil);
  AddFuncItem(ItemID_OpenProjectAndDependencies, rsMenuOpenProjectFileAndDeps, _OpenProjectAndDependencies, nil);

  AddFuncItem(ItemID_MenuSeparator2, csMenuEmptyLine, nil, nil); // Menù separator
  AddFuncItem(ItemID_CommandRun, rsMenuCommandRun, _CommandRun, MakeShortcutKey(False, False, False, $78));
  AddFuncItem(ItemID_CommandCompile, rsMenuCommandCompile, _CommandCompile, MakeShortcutKey(False, False, False, $77));
  AddFuncItem(ItemID_CommandUpload, rsMenuCommandUpload, _CommandUpload, MakeShortcutKey(True, False, False, $77));
  AddFuncItem(ItemID_CommandShowLogs, rsMenuCommandShowLogs, _CommandShowLogs, nil);
  AddFuncItem(ItemID_CommandClean, rsMenuCommandClean, _CommandClean, nil);
  AddFuncItem(ItemID_CommandVisit, rsMenuCommandVisit, _CommandVisit, nil);

  AddFuncItem(ItemID_MenuSeparator3, csMenuEmptyLine, nil, nil); // Menù separator
  AddFuncItem(ItemID_Help, rsMenuOpenESPHomeDocs, _CommandShowHelp, MakeShortcutKey(True, False, False, $70));
  AddFuncItem(ItemID_Upgrade, rsMenuUpgradeESPHome, _CommandUpgrade, nil);

  AddFuncItem(ItemID_MenuSeparator4, csMenuEmptyLine, nil, nil); // Menù separator
  AddFuncItem(ItemID_CmdShell, rsMenuOpenCmdShell, _CommandShellPrompt, nil);
  AddFuncItem(ItemID_Explorer, rsMenuOpenExplorer, _CommandExplorer, nil);

  AddFuncItem(ItemID_MenuSeparator5, csMenuEmptyLine, nil, nil); // Menù separator
  AddFuncItem(ItemID_ShowHideWindow, rsMenuShowHide, _CommandShowHide, nil);

  AddFuncItem(ItemID_MenuSeparator6, csMenuEmptyLine, nil, nil); // Menù separator
  AddFuncItem(ItemID_Toolbar, rsMenuToolbar, _CommandToolbar, nil);
  AddFuncItem(ItemID_About, rsMenuAbout, _CommandAbout, nil);

end;


procedure TESPHomePlugin.DoNppnReady;
begin
  inherited;
  OperationsOngoing := False;
  ModuleInitialize;
  FormProjects := TFormProjects.Create(Plugin, 19);
  if ConfigFile.ReadBool(csSectionGeneral, csKeyProjectWindow, False) then
    FormProjects.Show
  else
    FormProjects.Hide;
  CheckMenuItem(ItemID_ShowHideWindow, FormProjects.Visible);
  UpdatePluginMenuAndTitle;
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
  UpdatePluginMenuAndTitle;
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
    for Index := 0 to Length(ToolbarIconItemKey) - 1 do
      if ToolbarIconItemKey[Index] <> '' then
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
          if (Count = 0) and (Index < Length(ToolbarIconItemKey)) and (Parts[1] = '1') then
          begin
            Bitmap := TBitmap.Create;
            IconLight := TIcon.Create;
            IconDark := TIcon.Create;
            Bitmap.LoadFromResourceName(HInstance, ToolbarIconItemKey[Index]);
            Bitmap.PixelFormat := pf8Bit;
            IconLight.LoadFromResourceName(HInstance, Concat(ToolbarIconItemKey[Index], DarkModeSuffix[False]));
            IconDark.LoadFromResourceName(HInstance, Concat(ToolbarIconItemKey[Index], DarkModeSuffix[True]));
            IconData.ToolbarBmp := Bitmap.Handle;
            IconData.ToolbarIcon := IconDark.Handle;
            IconData.ToolbarIconDarkMode := IconLight.Handle;
            Bitmap.TransparentMode := tmAuto;
            Bitmap.TransparentColor := TColor($FFFFFF);
            Bitmap.Transparent := True;
            AddToolbarIcon(CmdIdFromMenuItemIdx(Index), IconData);
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
  if not OperationsOngoing then
    if Assigned(FormProjects) then
      FormProjects.CurrentDocumentChanged;
end;

procedure TESPHomePlugin.DoNppnFileOpened;
begin
  if not OperationsOngoing then
    UpdatePluginMenuAndTitle;
end;

procedure TESPHomePlugin.DoNppnFileSaved;
begin
  if not OperationsOngoing then
    UpdatePluginMenuAndTitle;
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

    CommandLine :=  ' echo %s && ';

    if GetOption(csKeyESPHomeAutoClose, True) then
      CommandLine := Concat('/c', CommandLine)
    else
      CommandLine := Concat('/k', CommandLine);

    case Command of
      scRun: Switch := rsConsoleCommandRun;
      scCompile: Switch := rsConsoleCommandCompile;
      scUpload: Switch := rsConsoleCommandUpload;
      scLogs: Switch := rsConsoleCommandLogs;
      scClean: Switch := rsConsoleCommandClean;
    end;

    CommandLine := Format(CommandLine, [Switch]);

    CommandLine := Format('%s "%s"', [CommandLine, ExpandFileName(ESPHomeExeFile)]);

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
    CommandLine := Trim(Format('%s "%s"', [CommandLine, ExpandFileName(FileName)]));

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
var
  FormSelection: TFormSelection;
begin
  FormSelection := TFormSelection.Create(Self);
  try
    FormSelection.ShowModal;
  finally
    FreeAndNil(FormSelection);
  end;
  UpdatePluginMenuAndTitle;
end;

procedure TESPHomePlugin.ConfigureProject;
var
  FormConfiguration: TFormConfig;
begin
  if CheckCurrentProject then
  begin
    FormConfiguration := TFormConfig.Create(Self);
    try
      FormConfiguration.ShowModal;
    finally
      FreeAndNil(FormConfiguration);
    end;
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
    TD(Format(rsNoWebserverOnCurrentProject, [ProjectList.Current.FriendlyName])).WindowCaption(rsMessageBoxWarning).
      SetFlags([tfAllowDialogCancellation]).Warning.OK.Execute(nil);
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
  JvCreateProcess.CommandLine := Format('/c pip.exe install --upgrade esphome & "%s" --version & pause', [ExpandFileName(ESPHomeExeFile)]);
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

procedure TESPHomePlugin.OpenProjectAndDependencies(CurrentFile: string = '');
var
  FileName: string;
begin
  if not CheckCurrentProject then
    Exit;

  OperationsOngoing := True;
  OpenFile(ProjectList.Current.FileName);
  ProjectList.Current.LoadOptionDependencies;
  for FileName in ProjectList.Current.OptionDependencies do
    if FileExists(FileName) then
      OpenFile(FileName);

  OperationsOngoing := False;

  if CurrentFile = '' then
    CurrentFile := ProjectList.Current.FileName;

  SwitchToFile(CurrentFile);
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
    OperationsOngoing := True;
    CurrentFile := GetFullCurrentPath;
    if SwitchToFile(ProjectList.Current.FileName) then
      SaveCurrentFile;
    for S in ProjectList.Current.OptionDependencies do
      if SwitchToFile(S) then
        SaveCurrentFile;
    OperationsOngoing := True;
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
  CheckMenuItem(ItemID_ShowHideWindow, FormProjects.Visible);
  ConfigFile.WriteBool(csSectionGeneral, csKeyProjectWindow, FormProjects.Visible);
end;

procedure TESPHomePlugin.UpdateProjectList;
begin
  if Assigned(FormProjects) then
    FormProjects.RefreshProjectsList;
  UpdatePluginMenuAndTitle;
end;

procedure TESPHomePlugin.UpdatePluginMenuAndTitle;
var
  Index: Integer;
  Text: string;
  PluginMenu: HMENU;
  ShortcutKey: TShortcutKey;
  PFunc: PFuncItem;
  ProjectAssigned: Boolean;
begin
  ProjectAssigned := Assigned(ProjectList.Current);

  PluginMenu := HMENU(SendMessage(NppData.NppHandle, NPPM_GETMENUHANDLE, NPPPLUGINMENU, 0));
  if PluginMenu <> 0 then
  begin
    if ProjectAssigned then
      Text := Format(rsMenuSelectProjectCurrent, [ProjectList.Current.FriendlyName])
    else
      Text := rsMenuSelectProject;
    PFunc := GetFuncByIndex(ItemID_ConfigureProject);
    if Assigned(PFunc) then
    begin
      if SendMessage(NppData.NppHandle, NPPM_GETSHORTCUTBYCMDID, PFunc^.CmdID, LPARAM(@ShortcutKey)) <> 0 then
        Text := Text + #09 + ShortcutToString(@ShortcutKey);
      if ModifyMenu(PluginMenu, PFunc^.CmdID, MF_BYCOMMAND or MF_STRING, PFunc^.CmdID, PChar(Text)) then
        DrawMenuBar(NppData.NppHandle);
    end;
  end;

  Text := GetNppWindowTitle;
  Index := Pos('|', Text);
  if Index > 0 then
    Text := Trim(Copy(Text, 1, Index - 1));
  if ProjectAssigned then
    Text := Format('%s | ESPHome Project: %s', [Text, ProjectList.Current.FriendlyName]);
  SetWindowText(NppData.NppHandle, PChar(Text));

  EnableMenuItem(ItemID_ConfigureProject, ProjectAssigned);
  EnableMenuItem(ItemID_OpenProject, ProjectAssigned);
  EnableMenuItem(ItemID_CommandRun, ProjectAssigned);
  EnableMenuItem(ItemID_CommandCompile, ProjectAssigned);
  EnableMenuItem(ItemID_CommandUpload, ProjectAssigned);
  EnableMenuItem(ItemID_CommandShowLogs, ProjectAssigned);
  EnableMenuItem(ItemID_CommandClean, ProjectAssigned);

  EnableMenuItem(ItemID_OpenProjectAndDependencies, ProjectAssigned and (ProjectList.Current.OptionDependencies.Count > 0));
  EnableMenuItem(ItemID_CommandVisit, ProjectAssigned and ProjectList.Current.HasWebServer);

  EnableToolbarItem(ItemID_ConfigureProject, ProjectAssigned);
  EnableToolbarItem(ItemID_OpenProject, ProjectAssigned);
  EnableToolbarItem(ItemID_CommandRun, ProjectAssigned);
  EnableToolbarItem(ItemID_CommandCompile, ProjectAssigned);
  EnableToolbarItem(ItemID_CommandUpload, ProjectAssigned);
  EnableToolbarItem(ItemID_CommandShowLogs, ProjectAssigned);
  EnableToolbarItem(ItemID_CommandClean, ProjectAssigned);

  EnableToolbarItem(ItemID_OpenProjectAndDependencies, ProjectAssigned and (ProjectList.Current.OptionDependencies.Count > 0));
  EnableToolbarItem(ItemID_CommandVisit, ProjectAssigned and ProjectList.Current.HasWebServer);

end;

function TESPHomePlugin.CheckESPHome: Boolean;
begin
  Result := False;
  if not FileExists(ESPHomeExeFile) then
    TD(rsInvalidESPHomeInstallation).Text(rsInvalidESPHomeInstallation2).Text(rsInvalidESPHomeInstallation3).WindowCaption(rsMessageBoxError).Hypertext.SetFlags
      ([tfAllowDialogCancellation]).Error.OK.Execute(nil)
  else
    Result := True;
end;

function TESPHomePlugin.CheckCurrentProject: Boolean;
begin
  Result := False;
  if not Assigned(ProjectList.Current) then
    TD(rsNoProjectSelected).Text(rsNoProjectSelected2).WindowCaption(rsMessageBoxError).SetFlags([tfAllowDialogCancellation]).Warning.OK.Execute(nil)
  else
    Result := True;
end;

end.

