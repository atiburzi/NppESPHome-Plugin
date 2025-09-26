unit ESPHomePlugin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.StrUtils, System.DateUtils,
  System.IOUtils, System.Math, System.Types, System.Classes, System.Generics.Defaults,
  System.Generics.Collections, Vcl.Graphics,
  SciSupport, NppSupport, NppMenuCmdID, NppPlugin, NppPluginForms, NppPluginDockingForms,
  ESPHomeShared;

{$R NppESPHomeToolbar.res}

type
  // Plugin class
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

  protected
    procedure DoNppnReady; override;
    procedure DoNppnShutdown; override;
    procedure DoNppnShortcutRemapped; override;
    procedure DoNppnToolbarModification; override;

  public
    constructor Create; override;

  public
    procedure UpdatePluginMenu;

  end;

var
  // Plugin instance variable, this is the reference to use in plugin's code
  Plugin: TESPHomePlugin;
  // Class type to create in startup code
  PluginClass: TNppPluginClass = TESPHomePlugin;


implementation

uses
  JvCreateProcess, Winapi.ShellAPI, UnitFormProjectSelection, UnitFormProjectConfiguration,
  UnitFormTemplates, UnitFormToolbar, UnitFormAbout, Vcl.Controls, IniFiles;

const
  csMenuEmptyLine = '-';

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

resourcestring
  rsPluginName = 'NppESPHome';
  rsMenuSelectProject = 'Select Project...';
  rsMenuSelectProjectCurrent = 'Change "%s" project...';
  rsMenuConfigProject = 'Configure Project...';
  rsMenuOpenProjectFile = 'Open Project file';
  rsMenuOpenProjectFileAndDeps = 'Open Project file and dependencies';
  rsMenuCommandRun = 'Run';
  rsMenuCommandCompile = 'Compile';
  rsMenuCommandUpload = 'Upload';
  rsMenuCommandLogs = 'Show Logs';
  rsMenuCommandClean = 'Clean';
  rsMenuCommandVisit = 'Visit Device Web Server';
  rsMenuOpenESPHomeDocs = 'Show ESPHome online documentation';
  rsMenuUpgradeESPHome = 'Check and upgrade ESPHome version';
  rsMenuOpenCmdShell = 'Open a CMD shell in the project folder';
  rsMenuOpenExplorer = 'Open an Explorer window from the project folder';
  rsMenuToolbar = 'Toolbar configuration...';
  rsMenuAbout = 'About...';

constructor TESPHomePlugin.Create;
begin
  inherited Create;
  Plugin := Self;
  PluginName := rsPluginName;

  if not FileExists(ExpandFileName(FindFileInPath('esphome.exe'))) then
  begin
    MessageBox(0, PWideChar(rsInvalidESPHomeInstallation), PWideChar(rsMessageBoxError), MB_ICONERROR or MB_OK);
    Exit;
  end;

  AddFuncItem(rsMenuSelectProject, _SelectProject, MakeShortcutKey(True, True, False, $79));
  AddFuncItem(rsMenuConfigProject, _ConfigureProject, MakeShortcutKey(True, False, False, $79));
  AddFuncItem(csMenuEmptyLine, nil);
  AddFuncItem(rsMenuOpenProjectFile, _OpenProject);
  AddFuncItem(rsMenuOpenProjectFileAndDeps, _OpenProjectAndDependencies);
  AddFuncItem(csMenuEmptyLine, nil);
  AddFuncItem(rsMenuCommandRun, _CommandRun, MakeShortcutKey(false, false, false, $78));
  AddFuncItem(rsMenuCommandCompile, _CommandCompile, MakeShortcutKey(false, false, false, $77));
  AddFuncItem(rsMenuCommandUpload, _CommandUpload, MakeShortcutKey(true, false, false, $77));
  AddFuncItem(rsMenuCommandLogs, _CommandShowLogs, nil);
  AddFuncItem(rsMenuCommandClean, _CommandClean, nil);
  AddFuncItem(rsMenuCommandVisit, _CommandVisit, nil);
  AddFuncItem(csMenuEmptyLine, nil);
  AddFuncItem(rsMenuOpenESPHomeDocs, _CommandShowHelp, MakeShortcutKey(true, false, false, $70));
  AddFuncItem(rsMenuUpgradeESPHome, _CommandUpgrade, nil);
  AddFuncItem(csMenuEmptyLine, nil);
  AddFuncItem(rsMenuOpenCmdShell, _CommandShellPrompt, nil);
  AddFuncItem(rsMenuOpenExplorer, _CommandExplorer, nil);
  AddFuncItem(csMenuEmptyLine, nil);
  AddFuncItem(rsMenuToolbar, _CommandToolbar, nil);
  AddFuncItem(rsMenuAbout, _CommandAbout, nil);
end;

procedure TESPHomePlugin.DoNppnReady;
begin
  inherited;
  ModuleInitialize;
  UpdatePluginMenu;
end;

procedure TESPHomePlugin.DoNppnShutdown;
begin
  ModuleFinalize;
  inherited;
end;

procedure TESPHomePlugin.DoNppnShortcutRemapped;
begin
  UpdatePluginMenu;
end;

procedure TESPHomePlugin.DoNppnToolbarModification;
var
  Bitmap: TBitmap;
  IconLight, IconDark: TIcon;
  IconData: TToolbarIconsWithDarkMode;
  IniFile: TIniFile;
  ToolBarBitmap: Int64;

  procedure LoadResource(const MenuIdx: Integer; const BaseResourceName: string);
  begin
    Bitmap := TBitmap.Create;
    IconLight := TIcon.Create;
    IconDark := TIcon.Create;
    Bitmap.LoadFromResourceName(HInstance, BaseResourceName);
    Bitmap.PixelFormat := pf8Bit;
    IconLight.LoadFromResourceName(HInstance, Concat(BaseResourceName, '_Light'));
    IconDark.LoadFromResourceName(HInstance, Concat(BaseResourceName, '_Dark'));
    IconData.ToolbarBmp := Bitmap.Handle;
    IconData.ToolbarIcon := IconDark.Handle;
    IconData.ToolbarIconDarkMode := IconLight.Handle;
    Bitmap.TransparentMode := tmAuto;
    Bitmap.TransparentColor := TColor($FFFFFF);
    Bitmap.Transparent := True;
    AddToolbarIconEx(CmdIdFromMenuItemIdx(MenuIdx), IconData);
  end;

begin
  inherited;

  if IsNppMinVersion(8, 0) then
  begin

    IniFile := TIniFile.Create(IncludeTrailingPathDelimiter(Plugin.GetPluginConfigDir) + ChangeFileExt(Plugin.GetName, '.ini'));
    ToolBarBitmap := IniFile.ReadInt64(csSectionGeneral, csKeyToolbarBitmap, 65535);
    IniFile.Free;

    if GetBit(ToolBarBitmap, 0) then LoadResource(0, 'Select');
    if GetBit(ToolBarBitmap, 1) then LoadResource(1, 'Configure');
    if GetBit(ToolBarBitmap, 2) then LoadResource(3, 'Open');
    if GetBit(ToolBarBitmap, 3) then LoadResource(4, 'OpenDeps');
    if GetBit(ToolBarBitmap, 4) then LoadResource(6, 'Run');
    if GetBit(ToolBarBitmap, 5) then LoadResource(7, 'Compile');
    if GetBit(ToolBarBitmap, 6) then LoadResource(8, 'Upload');
    if GetBit(ToolBarBitmap, 7) then LoadResource(9, 'ShowLogs');
    if GetBit(ToolBarBitmap, 8) then LoadResource(10, 'Clean');
    if GetBit(ToolBarBitmap, 9) then LoadResource(11, 'Visit');
    if GetBit(ToolBarBitmap, 10) then LoadResource(13, 'Help');
    if GetBit(ToolBarBitmap, 11) then LoadResource(14, 'Upgrade');
  end
end;


procedure ExecuteESPHomeCommand(const Command: Integer);
const
  CommandStr: array [scRun..scClean] of string =
              ('run', 'compile', 'upload', 'logs', 'clean');
var
  CommandLine, Switch, Device: string;
  ESPHomeProcess: TJvCreateProcess;
begin
  if not Assigned(ProjectList.Current) or not FileExists(ESPHomeExecutable) then
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

    CommandLine := Format('%s %s', [CommandLine, ShortFileName(ESPHomeExecutable)]);

    case GetOption(csKeyESPHomeLogLevel, ciLogLevelError) of
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
          Switch := Trim(GetOption(csKeyCompileExtraParameters, csDefaultEmpty));
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
          Switch := Trim(GetOption(csKeyCleanExtraParameters, csDefaultEmpty));
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
  if not Assigned(ProjectList.Current) then
  begin
    MessageBox(0, PWideChar(rsNoProjectSelected), PWideChar(rsMessageBoxError), MB_ICONSTOP or MB_OK);
    Exit;
  end;

  FormProjectConfiguration := TFormProjectConfiguration.Create(Self);
  FormProjectConfiguration.ShowModal;
  FreeAndNil(FormProjectConfiguration);
end;

procedure TESPHomePlugin.CommandRun;
begin
  if not Assigned(ProjectList.Current) then
  begin
    MessageBox(0, PWideChar(rsNoProjectSelected), PWideChar(rsMessageBoxError), MB_ICONSTOP or MB_OK);
    Exit;
  end;

  ExecuteESPHomeCommand(scRun);
end;

procedure TESPHomePlugin.CommandCompile;
begin
  if not Assigned(ProjectList.Current) then
  begin
    MessageBox(0, PWideChar(rsNoProjectSelected), PWideChar(rsMessageBoxError), MB_ICONSTOP or MB_OK);
    Exit;
  end;

  ExecuteESPHomeCommand(scCompile);
end;

procedure TESPHomePlugin.CommandUpload;
begin
  if not Assigned(ProjectList.Current) then
  begin
    MessageBox(0, PWideChar(rsNoProjectSelected), PWideChar(rsMessageBoxError), MB_ICONSTOP or MB_OK);
    Exit;
  end;
  ExecuteESPHomeCommand(scUpload);
end;

procedure TESPHomePlugin.CommandShowLogs;
begin
  if not Assigned(ProjectList.Current) then
  begin
    MessageBox(0, PWideChar(rsNoProjectSelected), PWideChar(rsMessageBoxError), MB_ICONSTOP or MB_OK);
    Exit;
  end;
  ExecuteESPHomeCommand(scLogs);
end;

procedure TESPHomePlugin.CommandClean;
begin
  if not Assigned(ProjectList.Current) then
  begin
    MessageBox(0, PWideChar(rsNoProjectSelected), PWideChar(rsMessageBoxError), MB_ICONSTOP or MB_OK);
    Exit;
  end;

  ExecuteESPHomeCommand(scClean);
end;

procedure TESPHomePlugin.CommandVisit;
var
  URL: string;
begin
  if not Assigned(ProjectList.Current) then
  begin
    MessageBox(0, PWideChar(rsNoProjectSelected), PWideChar(rsMessageBoxError), MB_ICONSTOP or MB_OK);
    Exit;
  end;

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
  JvCreateProcess := TJvCreateProcess.Create(nil);
  JvCreateProcess.ApplicationName := GetEnvironmentVariable('ComSpec');
  JvCreateProcess.CommandLine := Format('/c pip.exe install --upgrade esphome & %s --version & pause', [ShortFileName(ESPHomeExecutable)]);
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
  if not Assigned(ProjectList.Current) then
  begin
    MessageBox(0, PWideChar(rsNoProjectSelected), PWideChar(rsMessageBoxError), MB_ICONSTOP or MB_OK);
    Exit;
  end;

  JvCreateProcess := TJvCreateProcess.Create(nil);
  JvCreateProcess.ApplicationName := GetEnvironmentVariable('ComSpec');
  JvCreateProcess.CurrentDirectory := ExtractFilePath(ProjectList.Current.FileName);
  JvCreateProcess.CommandLine := '';
  JvCreateProcess.Run;
  JvCreateProcess.Free;
end;

procedure TESPHomePlugin.OpenProject;
begin
  if not Assigned(ProjectList.Current) then
  begin
    MessageBox(0, PWideChar(rsNoProjectSelected), PWideChar(rsMessageBoxError), MB_ICONSTOP or MB_OK);
    Exit;
  end;
  OpenFile(ProjectList.Current.FileName);
end;

procedure TESPHomePlugin.OpenProjectAndDependencies;
var
  FileName: string;
begin
  if not Assigned(ProjectList.Current) then
  begin
    MessageBox(0, PWideChar(rsNoProjectSelected), PWideChar(rsMessageBoxError), MB_ICONSTOP or MB_OK);
    Exit;
  end;

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
  if not Assigned(ProjectList.Current) then
  begin
    MessageBox(0, PWideChar(rsNoProjectSelected), PWideChar(rsMessageBoxError), MB_ICONSTOP or MB_OK);
    Exit;
  end;

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


end.
