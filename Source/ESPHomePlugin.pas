unit ESPHomePlugin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils, System.DateUtils,
  System.IOUtils, System.Math, System.Types, System.Classes, System.Generics.Defaults,
  System.Generics.Collections, Vcl.Graphics,
  SciSupport, NppSupport, NppMenuCmdID, NppPlugin, NppPluginForms, NppPluginDockingForms,
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
  private
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
    procedure CommandTemplates;

  protected
    procedure DoNppnReady; override;
    procedure DoNppnShutdown; override;
    procedure DoNppnShortcutRemapped; override;
    procedure DoNppnToolbarModification; override;
    procedure DoNppnDarkModeChanged; override;

  public
    constructor Create; override;
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
  JvCreateProcess, Winapi.ShellAPI, UnitFormProjectSelection, UnitFormProjectConfiguration,
  UnitFormTemplates, UnitFormToolbar, UnitFormAbout, Vcl.Controls, IniFiles, System.RegularExpressions;

resourcestring
  rsInvalidESPHomeInstallation = 'No valid installation of ESPHome has been found on your system.' +
                                  #13#10'Please (re)install ESPHome following the instructions available on the following web page:' +
                                  #13#13#10'https://www.esphome.io/guides/installing_esphome/';

  rsNoProjectSelected = 'No ESPHome project is currently selected.' +
                        #13#13#10'To use this command, please select the current project and try again.' +
                        #13#10'You can select it through the menù command:' +
                        #13#10'"Plugins" -> "NppESPHome" -> "Select Project..."';

  rsNoWebserverOnCurrentProject  = 'Selected ESPHome project (%s) does not have Webserver component enabled.' +
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

procedure _CommandTemplates; cdecl;
begin
  Plugin.CommandTemplates;
end;

{$ENDREGION}

function ShortcutToString(const S: PShortcutKey): string;
var
  Parts: TArray<string>;
  KeyName: array[0..255] of Char;
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
  FormTemplates := TFormTemplates.Create(Plugin, 19);
  if ConfigFile.ReadBool(csSectionGeneral, csKeyTemplateWindow, False) then
    FormTemplates.Show
  else
    FormTemplates.Hide;
  UpdatePluginMenu;
end;

procedure TESPHomePlugin.DoNppnShutdown;
begin
  ModuleFinalize;
  if Assigned(FormTemplates) then
    FormTemplates.Free;
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
  if Assigned(FormTemplates) then
    FormTemplates.ToggleDarkMode;
end;

procedure ExecuteESPHomeCommand(const Command: Integer);
const
  CommandStr: array [scRun..scClean] of string =
              ('run', 'compile', 'upload', 'logs', 'clean');
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
  FormProjectSelection := TFormProjectSelection.Create(Self);
  FormProjectSelection.ShowModal;
  FreeAndNil(FormProjectSelection);
  UpdatePluginMenu;
end;

procedure TESPHomePlugin.ConfigureProject;
begin
  if CheckCurrentProject then
  begin
    FormProjectConfiguration := TFormProjectConfiguration.Create(Self);
    FormProjectConfiguration.ShowModal;
    FreeAndNil(FormProjectConfiguration);
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
    MessageBox(0, PWideChar(Format(rsNoWebserverOnCurrentProject, [ProjectList.Current.FriendlyName])), PWideChar(rsMessageBoxWarning), MB_ICONWARNING or MB_OK);
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

procedure TESPHomePlugin.CommandTemplates;
begin
  if not Assigned(FormTemplates) then
    Exit;
  if FormTemplates.Visible then
    FormTemplates.Hide
  else
    FormTemplates.Show;
  ConfigFile.WriteBool(csSectionGeneral, csKeyTemplateWindow, FormTemplates.Visible);
end;

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

  SetFuncMapRecord(0, 'select', rsMenuSelectProject, _SelectProject, MakeShortcutKey(True, True, False, $79), true);
  SetFuncMapRecord(1, 'configure', rsMenuConfigProject, _ConfigureProject, MakeShortcutKey(True, False, False, $79), true);
  SetFuncMapRecord(2, '', csMenuEmptyLine, nil, nil);
  SetFuncMapRecord(3, 'open', rsMenuOpenProjectFile, _OpenProject, nil, true);
  SetFuncMapRecord(4, 'opendeps', rsMenuOpenProjectFileAndDeps, _OpenProjectAndDependencies, nil, true);
  SetFuncMapRecord(5, '', csMenuEmptyLine, nil, nil);
  SetFuncMapRecord(6, 'run', rsMenuCommandRun, _CommandRun, MakeShortcutKey(false, false, false, $78), true);
  SetFuncMapRecord(7, 'compile', rsMenuCommandCompile, _CommandCompile, MakeShortcutKey(false, false, false, $77), true);
  SetFuncMapRecord(8, 'upload', rsMenuCommandUpload, _CommandUpload, MakeShortcutKey(true, false, false, $77), true);
  SetFuncMapRecord(9, 'showlogs', rsMenuCommandShowLogs, _CommandShowLogs, nil, true);
  SetFuncMapRecord(10, 'clean', rsMenuCommandClean, _CommandClean, nil, true);
  SetFuncMapRecord(11, 'visit', rsMenuCommandVisit, _CommandVisit, nil, true);
  SetFuncMapRecord(12, '', csMenuEmptyLine, nil, nil);
  SetFuncMapRecord(13, 'help', rsMenuOpenESPHomeDocs, _CommandShowHelp, MakeShortcutKey(true, false, false, $70), true);
  SetFuncMapRecord(14, 'upgrade', rsMenuUpgradeESPHome, _CommandUpgrade, nil, true);
  SetFuncMapRecord(15, '', csMenuEmptyLine, nil, nil);
  SetFuncMapRecord(16, 'cmdshell', rsMenuOpenCmdShell, _CommandShellPrompt, nil);
  SetFuncMapRecord(17, 'explorer', rsMenuOpenExplorer, _CommandExplorer, nil);
  SetFuncMapRecord(18, '', csMenuEmptyLine, nil, nil);
  SetFuncMapRecord(19, 'templates', rsMenuTemplates, _CommandTemplates, nil, true);
  SetFuncMapRecord(20, '', csMenuEmptyLine, nil, nil);
  SetFuncMapRecord(21, 'toolbar', rsMenuToolbar, _CommandToolbar, nil);
  SetFuncMapRecord(22, 'about', rsMenuAbout, _CommandAbout, nil);

end.
