unit ESPHomePlugin;

interface

uses
  Winapi.Windows, Winapi.CommCtrl, System.SysUtils, System.Classes, Vcl.Graphics, NppSupport, NppPlugin, NppPluginForms, NppPluginDockingForms, ESPHomeShared,
  Vcl.ImageCollection, Vcl.BaseImageCollection;

const
  csPluginName = 'NppESPHome';
  csMenuEmptyLine = '-';

const
  fiProjectAdd = 'addprj';
  fiProjectSelect = 'select';
  fiProjectRemove = 'removeprj';
  fiProjectConfigure = 'configure';
  fiProjectOpenFiles = 'open';

  fiCommandRun = 'run';
  fiCommandCompile = 'compile';
  fiCommandUpload = 'upload';
  fiCommandLogs = 'logs';
  fiCommandClean = 'clean';
  fiCommandCleanAll = 'cleanall';

  fiStartHelp = 'help';
  fiStartUpgrade = 'upgrade';
  fiStartTerminal = 'terminal';
  fiStartExplorer = 'explorer';

  fiShowHidePrjWin = 'showhide';
  fiConfigToolbar = 'toolbar';
  fiAboutWindow = 'about';


resourcestring
  miProjectAdd = 'Add a new existing ESPHome project';
  miProjectSelect = 'Select current ESPHome project...';
  miProjectRemove = 'Remove current selected project';
  miProjectConfigure = 'Configure Project...';
  miProjectConfigureEx = 'Configure "%s" project...';
  miProjectOpenFiles = 'Open Project file and dependencies';

  miCommandRun = 'Run';
  miCommandCompile = 'Compile';
  miCommandUpload = 'Upload';
  miCommandLogs = 'Show Logs';
  miCommandClean = 'Clean';
  miCommandCleanAll = 'Clean All';

  miStartHelp = 'Show ESPHome online documentation';
  miStartUpgrade = 'Check and upgrade ESPHome version';
  miStartTerminal = 'Open a command shell from the current project folder';
  miStartExplorer = 'Open an Explorer window from the current project folder';
  miShowHidePrjWin = 'Hide/Show ESPHome plugin window';
  miConfigToolbar = 'Configure Plugin Toolbar...';
  miAboutWindow = 'About...';

type
  TResources = class(TDataModule)
    StandardImages: TImageCollection;
    LightModeImages: TImageCollection;
    LowResImages: TImageCollection;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  PToolbarButton = ^TToolbarButton;
  TToolbarButton = record
    Index: Integer;
    CmdID: Integer;
    FuncItemID: string;
    Sequence: Integer;
    Visible: Boolean;
    Enabled: Boolean;
    Button: TTBButton;
    IconData: TToolbarIconsWithDarkMode;
  end;

  TToolbarButtons = TArray<TToolbarButton>;

type
  TFuncItemsNames = TArray<string>;

type
  TESPHomePlugin = class(TNppPlugin)
    OperationsOngoing: Boolean;
    FFuncItemsNames: TFuncItemsNames;
    FToolbarButtons: TToolbarButtons;

  public

    procedure ProjectAdd;
    procedure ProjectSelect;
    procedure ProjectRemove;
    procedure ProjectConfigure;
    procedure ProjectOpenFiles;

    procedure CommandRun;
    procedure CommandCompile;
    procedure CommandUpload;
    procedure CommandLogs;
    procedure CommandClean;
    procedure CommandCleanAll;

    procedure StartHelp;
    procedure StartUpgrade;
    procedure StartTerminal;
    procedure StartExplorer;
    procedure ShowHidePrjWin;
    procedure ConfigToolbar;
    procedure AboutWindow;


  protected

    function AddPluginFunction(FuncItemName: string; FuncItemDescription: nppString; FuncCmdProc: FuncItemCmdProc; ShortcutKey: PShortcutKey = nil; MenuChecked: Boolean = False): Integer;
    function AddPluginMenuSeparator: Integer;

    procedure DoNppnReady; override;
    procedure DoNppnShutdown; override;
    procedure DoNppnShortcutRemapped; override;
    procedure DoNppnToolbarModification; override;
    procedure DoNppnDarkModeChanged; override;
    procedure DoNppnBufferActivated; override;
    procedure DoNppnFileOpened; override;
    procedure DoNppnFileSaved; override;
    procedure DoNppToolbarIconsetChanged; override;

    procedure SaveProject;
    procedure SaveProjectAndDependencies;

    function GetToolbarButton(Index: Integer): PToolbarButton;
    function GetToolbarButtonCount: Integer;

  public
    constructor Create; override;
    procedure SetInfo(NppData: TNppData); override;

    function GetFuncItemIdFromIndex(const Index: Integer): string;
    function GetIndexFromFuncItemName(const FuncItemName: string): Integer;
    function GetCmdIdFromFuncItemName(const FuncItemName: string): Integer;

    function GetToolbarConfiguration(const ADefault: Boolean = False): string;

    procedure DependencyAdd;
    procedure DependencyRemove(const DepFile: string);

    procedure InitializeToolbarConfiguration;
    procedure RegisterToolbarConfiguration;
    procedure RefreshToolbarConfiguration;
    procedure FreeToolbarResources;

    procedure EnableToolbarItem(MenuItemIdx: Integer; State: Boolean); override;

    property ToolbarButton[Index: Integer]: PToolbarButton read GetToolbarButton;
    property ToolbarButtonCount: Integer read GetToolbarButtonCount;

    procedure RefreshCurrentProject;
    procedure RefreshProjectList;

    procedure RefreshNppTitle;
    procedure RefreshPluginMenu;

    function CheckESPHome: Boolean;
    function CheckCurrentProject: Boolean;

  end;

var
  // Plugin instance variable, this is the reference to use in plugin's code
  Plugin: TESPHomePlugin;
  // Class type to create in startup code
  PluginClass: TNppPluginClass = TESPHomePlugin;

  LastConsolePID: DWORD;


var
  Resources: TResources;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{$B-}

uses
  JvCreateProcess, Winapi.ShellAPI, UnitFormSelection, UnitFormConfig, System.StrUtils,
  UnitFormToolbar, UnitFormAbout, UnitFormProjects, IniFiles, System.RegularExpressions, TDMB, Vcl.Forms, Vcl.Dialogs,
  System.Math,
  System.UITypes,
  System.IOUtils;

resourcestring
  rsInvalidESPHomeInstallation = 'No valid installation of ESPHome has been found on your system.';
  rsInvalidESPHomeInstallation2 = 'Please (re)install ESPHome following the instructions available on the following web page:';
  rsInvalidESPHomeInstallation3 = '<a href="https://www.esphome.io/guides/installing_esphome/">Installing ESPHome Manually</a>';

  rsNoProjectSelected = 'No ESPHome project is currently selected.';
  rsNoProjectSelected2 = 'To use this command, please select the current project and try again.'#13#13#10'You can select it through the menù command:'#13#10'"Plugins" -> "NppESPHome" -> "Select Project..."';

{$REGION 'Virtual Procedures'}

procedure _ProjectAdd; cdecl;
begin
	Plugin.ProjectAdd;
end;

procedure _ProjectSelect; cdecl;
begin
	Plugin.ProjectSelect;
end;

procedure _ProjectRemove; cdecl;
begin
	Plugin.ProjectRemove;
end;

procedure _ProjectConfigure; cdecl;
begin
	Plugin.ProjectConfigure;
end;

procedure _ProjectOpenFiles; cdecl;
begin
	Plugin.ProjectOpenFiles;
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

procedure _CommandLogs; cdecl;
begin
	Plugin.CommandLogs;
end;

procedure _CommandClean; cdecl;
begin
	Plugin.CommandClean;
end;

procedure _CommandCleanAll; cdecl;
begin
	Plugin.CommandCleanAll;
end;

procedure _StartHelp; cdecl;
begin
	Plugin.StartHelp;
end;

procedure _StartUpgrade; cdecl;
begin
	Plugin.StartUpgrade;
end;

procedure _StartTerminal; cdecl;
begin
	Plugin.StartTerminal;
end;

procedure _StartExplorer; cdecl;
begin
	Plugin.StartExplorer;
end;

procedure _ShowHidePrjWin; cdecl;
begin
	Plugin.ShowHidePrjWin;
end;

procedure _ConfigToolbar; cdecl;
begin
	Plugin.ConfigToolbar;
end;

procedure _AboutWindow; cdecl;
begin
	Plugin.AboutWindow;
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

procedure PositionWindow(Wnd: HWND; Position: Integer; Monitor: Integer = 0; Margin: Integer = -1);
var
  R: TRect;
  WorkArea: TRect;
  W, H: Integer;
  X, Y: Integer;
begin
  if Wnd <> 0 then
  begin

    if Monitor < Screen.MonitorCount  then
      WorkArea := Screen.Monitors[Monitor].WorkareaRect
    else
      WorkArea := Screen.PrimaryMonitor.WorkareaRect;

    GetWindowRect(Wnd, R);
    W := R.Right - R.Left;
    H := R.Bottom - R.Top;

    if Margin < 0 then
      Margin := (WorkArea.Right - WorkArea.Left) div 50;
    case Position of
      ciConsolePosDecidedByWindows:
      begin
        X := R.Left + WorkArea.Left;
        Y := R.Top + WorkArea.Top;
      end;
      ciConsolePosScreenCenter:
      begin
        X := WorkArea.Left + ((WorkArea.Right - WorkArea.Left - W) div 2);
        Y := WorkArea.Top + ((WorkArea.Bottom - WorkArea.Top - H) div 2);
      end;
      ciConsolePosTopLeftSide:
      begin
        X := WorkArea.Left + Margin;
        Y := WorkArea.Top + Margin;
      end;
      ciConsolePosBottomLeftSide:
      begin
        X := WorkArea.Left + Margin;
        Y := WorkArea.Bottom - H - Margin;
      end;
      ciConsolePosTopRightSide:
      begin
        X := WorkArea.Right - W - Margin;
        Y := WorkArea.Top + Margin;
      end;
      ciConsolePosBottomRightSide:
      begin
        X := WorkArea.Right - W - Margin;
        Y := WorkArea.Bottom - H - Margin;
      end;
      else
        Exit;
    end;
    SetWindowPos(Wnd, HWND_TOP, X, Y, 0, 0, SWP_NOZORDER or SWP_NOSIZE or SWP_NOACTIVATE);
  end;
end;

procedure ExecuteESPHomeCommand(const Command: Integer);
const
  CommandStr: array [scRun .. scCleanAll] of string = ('run', 'compile', 'upload', 'logs', 'clean', 'clean-all');
var
  ConsoleHandle: HWND;
  CommandLine, Switch, Device: string;
  ESPHomeProcess: TJvCreateProcess;
begin
  if not Assigned(ProjectList.Current) or not FileExists(ESPHomeFile) then
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

    CommandLine := Format('"%s"', [ExpandFileName(ESPHomeFile)]);

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

    if SameText(Device, rsDefaultWiFi) then
      Device := '--device OTA'
    else if StartsText('COM', Device) then
      Device := '--device ' + Device
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
      scCleanAll:
        begin
          Switch := csDefaultEmpty;
        end;
    end;

    CommandLine := Trim(Format('%s %s %s "%s"', [CommandLine, CommandStr[Command], Switch, ExpandFileName(FileName)]));

    if GetOption(csKeyConsoleAutoClose, True) then
      CommandLine := Format('/c "%s" || pause', [CommandLine])
    else
      CommandLine := Format('/k "%s"', [CommandLine]);

    if GetOption(csKeyConsoleSoloMode, False) then
      if IsPIDRunning(LastConsolePID) then
        KillProcessTree(LastConsolePID);

    ESPHomeProcess := TJvCreateProcess.Create(nil);
    ESPHomeProcess.ApplicationName := GetEnvironmentVariable('ComSpec');
    ESPHomeProcess.CommandLine := CommandLine;
    ESPHomeProcess.CurrentDirectory := ExtractFilePath(ProjectList.Current.FileName);
    ESPHomeProcess.CreationFlags := ESPHomeProcess.CreationFlags + [cfNewConsole];

    with ESPHomeProcess.StartupInfo do
    begin
      ShowWindow := swHide;
      DefaultWindowState := False;
      case Command of
        scRun: Title := rsConsoleCommandRun;
        scCompile: Title := rsConsoleCommandCompile;
        scUpload: Title := rsConsoleCommandUpload;
        scLogs: Title := rsConsoleCommandLogs;
        scClean: Title := rsConsoleCommandClean;
        scCleanAll: Title := rsConsoleCommandCleanAll;
      end;
      Title := Format('%s - [%s]', [Title, ProjectList.Current.FriendlyName]);
    end;

    ESPHomeProcess.Run;

    LastConsolePID := ESPHomeProcess.ProcessInfo.dwProcessId;
    ConsoleHandle := GetMainWindowHandleByPID(LastConsolePID, 3000);

    if ConsoleHandle <> 0 then
    begin
      PositionWindow(ConsoleHandle, GetOption(csKeyConsoleStartingPosition, ciConsolePosDecidedByWindows), GetOption(csKeyConsoleStartingMonitor, 0));
      if GetOption(csKeyConsoleAlwaysOnTop, False) then
        SetWindowPos(ConsoleHandle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
      ShowWindow(ConsoleHandle, SW_SHOW);
    end
    else
      ESPHomeProcess.TerminateTree;

    ESPHomeProcess.Free;
  end;
end;

resourcestring
  rsProjectAddFileTypeItem = 'ESPHome project file';
  rsProjectAddFileOpenTitle = 'Add an existing ESPHome project to the known ones';

procedure TESPHomePlugin.ProjectAdd;
var
  Project: TProject;
  FileOpen: TFileOpenDialog;
  FileTypeItem: TFileTypeItem;
begin
  FileOpen := TFileOpenDialog.Create(nil);
  FileOpen.DefaultExtension := '.yaml';
  FileOpen.Title := rsProjectAddFileOpenTitle;
  FileOpen.Options := [fdoStrictFileTypes, fdoForceFileSystem, fdoFileMustExist];
  FileTypeItem := FileOpen.FileTypes.Add;
  FileTypeItem.DisplayName := rsProjectAddFileTypeItem;
  FileTypeItem.FileMask := '*.yaml';
  FileTypeItem := FileOpen.FileTypes.Add;
  FileTypeItem.DisplayName := rsProjectAddFileTypeItem;
  FileTypeItem.FileMask := '*.yal';
  if FileOpen.Execute(NppData.NppHandle) then
  begin
    if Assigned(ProjectList.GetProjectFromFileName(FileOpen.FileName)) then
      TD(Format(rsProjectAlreadyExists, [ExtractFileName(FileOpen.FileName)])).WindowCaption(rsMessageBoxError).
        Text(rsProjectAlreadyExists2).SetFlags([tfAllowDialogCancellation]).Error.OK.Execute(nil)
    else
    begin
      Project := TProject.Create(FileOpen.FileName);
      if Project.IsValid then
      begin
        ProjectList.Add(Project);
        ProjectList.Current := Project;
        ProjectList.SaveConfig;
        RefreshProjectList;
      end
      else
      begin
        Project.Free;
        TD(Format(rsInvalidProjectFile, [ExtractFileName(FileOpen.FileName)])).Text(rsInvalidProjectFile2).WindowCaption(rsMessageBoxError).
          Error.OK.SetFlags([tfAllowDialogCancellation]).Execute(nil);
      end;
    end;
  end;
  FileOpen.Free;
end;

procedure TESPHomePlugin.ProjectSelect;
var
  FormSelection: TFormSelection;
begin
  FormSelection := TFormSelection.Create(Self);
  try
    FormSelection.ShowModal;
  finally
    FreeAndNil(FormSelection);
  end;
  RefreshNppTitle;
  RefreshPluginMenu;
end;

procedure TESPHomePlugin.ProjectRemove;
var
  I: Integer;
begin
  inherited;
  if Assigned(ProjectList.Current) then
  begin
    if TD(Format(rsKnownProjectRemoval, [ProjectList.Current.FriendlyName])).Text(rsKnownProjectRemoval2).WindowCaption(rsMessageBoxWarning).
      SetFlags([tfAllowDialogCancellation]).Warning.YesNo.Execute(nil) = mrYes then
    begin
      I := ProjectList.IndexOf(ProjectList.Current);
      ProjectList.Delete(I);
      if ProjectList.Count > 0 then
        ProjectList.Current := ProjectList.Items[Max(0, I - 1)]
      else
        ProjectList.Current := nil;
      ProjectList.SaveConfig;
      RefreshProjectList;
    end;
  end;
end;

procedure TESPHomePlugin.ProjectConfigure;
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

procedure TESPHomePlugin.ProjectOpenFiles;
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
  SwitchToFile(ProjectList.Current.FileName);
  RefreshNppTitle;
  RefreshPluginMenu;
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

procedure TESPHomePlugin.CommandLogs;
begin
  if CheckESPHome and CheckCurrentProject then
    ExecuteESPHomeCommand(scLogs);
end;

procedure TESPHomePlugin.CommandClean;
begin
  if CheckESPHome and CheckCurrentProject then
    ExecuteESPHomeCommand(scClean);
end;

procedure TESPHomePlugin.CommandCleanAll;
begin
  if CheckESPHome and CheckCurrentProject then
  begin
    if TD.ClearFlag(tfPositionRelativeToWindow).
          WindowCaption(rsMessageBoxWarning).
          Text(rsConfirmExecuteCleanAll).
          Text(Format(rsConfirmExecuteCleanAll2, [ProjectList.Current.FriendlyName])).
          Warning.YesNo.Execute = mrYes then
      ExecuteESPHomeCommand(scCleanAll);
  end;
end;

procedure TESPHomePlugin.StartHelp;
begin
  ShellExecute(0, 'open', PChar(rsESPHomeDocURL), nil, nil, SW_SHOWNORMAL);
end;

procedure TESPHomePlugin.StartUpgrade;
var
  JvCreateProcess: TJvCreateProcess;
begin
  if not CheckESPHome then
    Exit;

  JvCreateProcess := TJvCreateProcess.Create(nil);
  JvCreateProcess.ApplicationName := GetEnvironmentVariable('ComSpec');
  JvCreateProcess.CommandLine := Format('/c pip.exe install --upgrade esphome & "%s" --version & pause', [ExpandFileName(ESPHomeFile)]);
  JvCreateProcess.StartupInfo.Title := miStartUpgrade;
  JvCreateProcess.Run;
  JvCreateProcess.Free;
end;

procedure TESPHomePlugin.StartTerminal;
var
  JvCreateProcess: TJvCreateProcess;
begin
  if not CheckCurrentProject then
    Exit;
  JvCreateProcess := TJvCreateProcess.Create(nil);
  JvCreateProcess.ApplicationName := GetEnvironmentVariable('ComSpec');
  JvCreateProcess.CurrentDirectory := ExtractFilePath(ProjectList.Current.FileName);
  JvCreateProcess.CommandLine := '';
  JvCreateProcess.StartupInfo.Title := Format('[%s]', [ProjectList.Current.FriendlyName]);
  GetEnvironmentVars(JvCreateProcess.Environment);
  JvCreateProcess.Environment.Add(Format('ESPHome=%s', [ExpandFileName(ESPHomeFile)]));
  JvCreateProcess.Environment.Add(Format('ESPProject=%s', [ExpandFileName(ProjectList.Current.FileName)]));
  JvCreateProcess.Run;
  JvCreateProcess.Free;
end;

procedure TESPHomePlugin.StartExplorer;
begin
  if not CheckCurrentProject then
    Exit;
  if ProjectList.Current.FileName <> '' then
    ShellExecute(0, 'open', PChar(ExtractFilePath(ProjectList.Current.FileName)), nil, nil, SW_SHOWNORMAL);
end;

procedure TESPHomePlugin.ShowHidePrjWin;
begin
  if Assigned(FormProjects) then
  begin
    if FormProjects.Visible then
      FormProjects.Hide
    else
      FormProjects.Show;
    CheckMenuItem(GetIndexFromFuncItemName(fiShowHidePrjWin), FormProjects.Visible);
    ConfigIniFile.WriteBool(csSectionGeneral, csKeyProjectWindow, FormProjects.Visible);
  end;
end;



//          if (Count = 0) and (Parts[1] = '1') and (PluginDataModule.ImageCollection.GetIndexByName(FuncItemIdFromMenuItemIdx(Index)) >= 0) then
//          begin
//            Bitmap := PluginDataModule.ImageCollection.GetBitmap(FuncItemIdFromMenuItemIdx(Index), 20, 20);
//            if not IsDarkModeEnabled then
//              ConvertBitmapToBlack(Bitmap);
//            FToolbarButtonArray[Index].IconData.ToolbarBmp := HBITMAP(CopyImage(Bitmap.Handle, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION));
//            Bitmap.Free;
//            Bitmap := PluginDataModule.ImageCollection.GetBitmap(FuncItemIdFromMenuItemIdx(Index), 64, 64);
//            //ReplaceBitmapHue(Bitmap, TAlphaColor($FF4CC2FF), TAlphaColor($FFFF0000), 25 / 360, 0.12);
//            FToolbarButtonArray[Index].IconData.ToolbarIconDarkMode := CreateIconFromBitmap(Bitmap);
//            ConvertBitmapToBlack(Bitmap);
//            FToolbarButtonArray[Index].IconData.ToolbarIcon := CreateIconFromBitmap(Bitmap);
//            Bitmap.Free;
//          end;

procedure TESPHomePlugin.ConfigToolbar;
begin
  FormToolbar := TFormToolbar.Create(Self);
  FormToolbar.ShowModal;
  FreeAndNil(FormToolbar);
end;

procedure TESPHomePlugin.AboutWindow;
begin
  FormAbout := TFormAbout.Create(Self);
  FormAbout.ShowModal;
  FreeAndNil(FormAbout);
end;

function TESPHomePlugin.AddPluginFunction(FuncItemName: string; FuncItemDescription: nppString; FuncCmdProc: FuncItemCmdProc; ShortcutKey: PShortcutKey = nil; MenuChecked: Boolean = False): Integer;
begin
  Result := AddFuncItem(FuncItemDescription, FuncCmdProc, ShortcutKey, MenuChecked);
  SetLength(FFuncItemsNames, Result + 1);
  FFuncItemsNames[Result] := FuncItemName;
end;

function TESPHomePlugin.AddPluginMenuSeparator: Integer;
begin
  Result := AddFuncItem(csMenuEmptyLine, nil, nil);
  SetLength(FFuncItemsNames, Result + 1);
  FFuncItemsNames[Result] := Format('Sep$%2d', [Result]);
end;

procedure TESPHomePlugin.DoNppnReady;
begin
  inherited;
  OperationsOngoing := False;

  RegisterToolbarConfiguration;

  RefreshToolbarConfiguration;
//  RefreshToolbarDisabledImages;

//  The initial dock position is saved in %AppData%\Notepad++\config.xml as a GUIConfig element with the DockingManager attribute; e.g.,
//   {
//       <GUIConfig name="DockingManager" leftWidth="200" rightWidth="582" topHeight="200" bottomHeight="200">
//           <PluginDlg pluginName="HelloWorld.dll" id="2" curr="1" prev="-1" isVisible="yes" />
//           <ActiveTabs cont="0" activeTab="-1" />
//           <!-- ... -->
//       </GUIConfig>
//   }
//  You should delete this between launches when testing different dlgID.

  FormProjects := TFormProjects.Create(Plugin, GetIndexFromFuncItemName(fiShowHidePrjWin));

  if ConfigIniFile.ReadBool(csSectionGeneral, csKeyProjectWindow, True) then
    FormProjects.Show
  else
    FormProjects.Hide;

  CheckMenuItem(GetIndexFromFuncItemName(fiShowHidePrjWin), FormProjects.Visible);
  EnableMenuItem(GetIndexFromFuncItemName(fiConfigToolbar), Plugin.IsNppMinVersion(8, 0));

  RefreshNppTitle;
  RefreshPluginMenu;
end;

procedure TESPHomePlugin.DoNppnShutdown;
begin
  if IsPIDRunning(LastConsolePID) then
    KillProcessTree(LastConsolePID);
  if Assigned(TemplateList) then
    TemplateList.Free;
  if Assigned(ProjectList) then
    ProjectList.Free;
  if Assigned(ConfigIniFile) then
    ConfigIniFile.Free;
  if Assigned(FormProjects) then
    FormProjects.Free;
  FreeToolbarResources;
  if Assigned(Resources) then
    Resources.Free;
  inherited;
end;

procedure TESPHomePlugin.DoNppnShortcutRemapped;
begin
  RefreshNppTitle;
  RefreshPluginMenu;
end;

procedure TESPHomePlugin.DoNppnToolbarModification;
begin
  inherited;
  InitializeToolbarConfiguration;
end;

procedure TESPHomePlugin.DoNppnDarkModeChanged;
begin
  if Assigned(FormProjects) then
    FormProjects.ToggleDarkMode;

  RefreshToolbarConfiguration;
  RefreshPluginMenu;
end;

procedure TESPHomePlugin.DoNppnBufferActivated;
begin
  if not OperationsOngoing then
  begin
    if Assigned(FormProjects) then
      FormProjects.CurrentDocumentChanged;
    RefreshNppTitle;
    RefreshPluginMenu;
  end;
end;

procedure TESPHomePlugin.DoNppnFileOpened;
begin
  if not OperationsOngoing then
  begin
    RefreshNppTitle;
    RefreshPluginMenu;
  end;
end;

procedure TESPHomePlugin.DoNppnFileSaved;

begin
  if not OperationsOngoing then
  begin
    RefreshNppTitle;
    RefreshPluginMenu;
  end;
  if GetFullPathFromBufferId(SCNotification.nmhdr.idFrom) = TemplateFile then
    if Assigned(FormProjects) then
      FormProjects.ReloadAndRefreshTemplates;
end;

procedure TESPHomePlugin.DoNppToolbarIconsetChanged;
begin
  TThread.CreateAnonymousThread(RefreshToolbarConfiguration).Start;
end;

resourcestring
  rsDependencyAddFileTypeItem1 = 'ESPHome file';
  rsDependencyAddFileTypeItem2 = 'ESPHome file';
  rsDependencyAddFileTypeItem3 = 'Partitions file';
  rsDependencyAddFileTypeItem4 = 'C++ header file';
  rsDependencyAddFileTypeItem5 = 'C++ source file';
  rsDependencyAddFileTypeItem6 = 'Include file';
  rsDependencyAddFileTypeItem7 = 'Text file';
  rsDependencyAddFileTypeItem8 = 'Any file';
  rsDependencyAddFileOpenTitle = 'Select and add a dependency to %s';

procedure TESPHomePlugin.DependencyAdd;
var
  Index: Integer;
  FileOpen: TFileOpenDialog;
  FileTypeItem: TFileTypeItem;
begin

  if not Assigned(ProjectList.Current) then
    Exit;

  FileOpen := TFileOpenDialog.Create(nil);
  FileOpen.DefaultExtension := '.yaml';
  FileOpen.Title := Format(rsDependencyAddFileOpenTitle, [ProjectList.Current.FriendlyName]);
  FileOpen.Options := [fdoForceFileSystem, fdoAllowMultiSelect, fdoFileMustExist, fdoNoDereferenceLinks, fdoForceShowHidden];
  FileOpen.DefaultFolder := ExtractFileDir(ProjectList.Current.FileName);

  FileTypeItem := FileOpen.FileTypes.Add;
  FileTypeItem.DisplayName := rsDependencyAddFileTypeItem1;
  FileTypeItem.FileMask := '*.yaml';
  FileTypeItem := FileOpen.FileTypes.Add;
  FileTypeItem.DisplayName := rsDependencyAddFileTypeItem2;
  FileTypeItem.FileMask := '*.yal';
  FileTypeItem := FileOpen.FileTypes.Add;
  FileTypeItem.DisplayName := rsDependencyAddFileTypeItem3;
  FileTypeItem.FileMask := '*.csv';
  FileTypeItem := FileOpen.FileTypes.Add;
  FileTypeItem.DisplayName := rsDependencyAddFileTypeItem4;
  FileTypeItem.FileMask := '*.h';
  FileTypeItem := FileOpen.FileTypes.Add;
  FileTypeItem.DisplayName := rsDependencyAddFileTypeItem5;
  FileTypeItem.FileMask := '*.cpp';
  FileTypeItem := FileOpen.FileTypes.Add;
  FileTypeItem.DisplayName := rsDependencyAddFileTypeItem6;
  FileTypeItem.FileMask := '*.inc';
  FileTypeItem := FileOpen.FileTypes.Add;
  FileTypeItem.DisplayName := rsDependencyAddFileTypeItem7;
  FileTypeItem.FileMask := '*.txt';
  FileTypeItem := FileOpen.FileTypes.Add;
  FileTypeItem.DisplayName := rsDependencyAddFileTypeItem8;
  FileTypeItem.FileMask := '*.*';

  if FileOpen.Execute(NppData.NppHandle) then
  begin
    ProjectList.Current.OptionDependencies.AddStrings(FileOpen.Files);
    Index := ProjectList.Current.OptionDependencies.IndexOf(ProjectList.Current.FileName);
    if Index >= 0 then
      ProjectList.Current.OptionDependencies.Delete(Index);
    ProjectList.Current.SaveOptionDependencies;
    RefreshProjectList;
    if Assigned(FormProjects) then
      FormProjects.CurrentDocumentChanged;
  end;

  FileOpen.Free;
end;

resourcestring
  rsKnownDependencyRemoval = 'Dependency file "%s" is going to be removed from the "%s" project.';
  rsKnownDependencyRemoval2 = 'Are you sure?';

procedure TESPHomePlugin.DependencyRemove(const DepFile: string);
var
  I: Integer;
begin
  inherited;
  if Assigned(ProjectList.Current) then
  begin
    if TD(Format(rsKnownDependencyRemoval, [ExtractFileName(DepFile), ProjectList.Current.FriendlyName])).Text(rsKnownDependencyRemoval2).WindowCaption(rsMessageBoxWarning).
      SetFlags([tfAllowDialogCancellation]).Warning.YesNo.Execute(nil) = mrYes then
    begin
      I := ProjectList.Current.OptionDependencies.IndexOf(DepFile);
      if I > 0 then
      begin
        ProjectList.Current.OptionDependencies.Delete(I);
        ProjectList.Current.SaveOptionDependencies;
        RefreshProjectList;
        if Assigned(FormProjects) then
          FormProjects.CurrentDocumentChanged;
      end;
    end;
  end;
end;

procedure TESPHomePlugin.SaveProject;
begin
  if Assigned(ProjectList.Current) then
    SaveFile(ProjectList.Current.FileName);
end;

procedure TESPHomePlugin.SaveProjectAndDependencies;
var
  S: string;
begin
  if Assigned(ProjectList.Current) then
  begin
    SaveFile(ProjectList.Current.FileName);
    for S in ProjectList.Current.OptionDependencies do
      SaveFile(S);
  end;
end;

function TESPHomePlugin.GetToolbarButton(Index: Integer): PToolbarButton;
begin
  Result := nil;
  if (Index >= 0) and (Index < Length(FToolbarButtons)) then
    Result := @FToolbarButtons[Index];
end;

function TESPHomePlugin.GetToolbarButtonCount: Integer;
begin
  Result := Length(FToolbarButtons);
end;

constructor TESPHomePlugin.Create;
begin
  inherited Create;

  Resources := TResources.Create(nil);
  PopulateBlackImageCollection(Resources.StandardImages, Resources.LightModeImages);

  OperationsOngoing := True;
  Plugin := Self;
  PluginName := csPluginName;

  AddPluginFunction(fiProjectAdd, miProjectAdd, _ProjectAdd);
  AddPluginFunction(fiProjectRemove, miProjectRemove, _ProjectRemove);
  AddPluginFunction(fiProjectSelect, miProjectSelect, _ProjectSelect, MakeShortcutKey(True, True, False, $79));
  AddPluginMenuSeparator;
  AddPluginFunction(fiProjectConfigure, miProjectConfigure, _ProjectConfigure, MakeShortcutKey(True, False, False, $79));
  AddPluginMenuSeparator;
  AddPluginFunction(fiProjectOpenFiles, miProjectOpenFiles, _ProjectOpenFiles, nil);
  AddPluginMenuSeparator;
  AddPluginFunction(fiCommandRun, miCommandRun, _CommandRun, MakeShortcutKey(False, False, False, $78));
  AddPluginFunction(fiCommandCompile, miCommandCompile, _CommandCompile, MakeShortcutKey(True, False, False, $78));
  AddPluginFunction(fiCommandUpload, miCommandUpload, _CommandUpload, MakeShortcutKey(False, False, True, $78));
  AddPluginFunction(fiCommandLogs, miCommandLogs, _CommandLogs, nil);
  AddPluginFunction(fiCommandClean, miCommandClean, _CommandClean, nil);
  AddPluginFunction(fiCommandCleanAll, miCommandCleanAll, _CommandCleanAll, nil);
  AddPluginMenuSeparator;
  AddPluginFunction(fiStartHelp, miStartHelp, _StartHelp, MakeShortcutKey(True, False, False, $70));
  AddPluginFunction(fiStartUpgrade, miStartUpgrade, _StartUpgrade, nil);
  AddPluginMenuSeparator;
  AddPluginFunction(fiStartTerminal, miStartTerminal, _StartTerminal, nil);
  AddPluginFunction(fiStartExplorer, miStartExplorer, _StartExplorer, nil);
  AddPluginMenuSeparator;
  AddPluginFunction(fiShowHidePrjWin, miShowHidePrjWin, _ShowHidePrjWin, nil);
  AddPluginMenuSeparator;
  AddPluginFunction(fiConfigToolbar, miConfigToolbar, _ConfigToolbar, nil);
  AddPluginFunction(fiAboutWindow, miAboutWindow, _AboutWindow, nil);

end;

procedure TESPHomePlugin.SetInfo(NppData: TNppData);
begin
  inherited SetInfo(NppData);
  ESPHomeFile := ExpandFileName(FindFileInPath('esphome.exe'));
  ConfigIniFile := TIniFile.Create(TPath.Combine(Plugin.GetPluginConfigDir, ChangeFileExt(Plugin.GetName, '.ini')));
  TemplateFile := TPath.Combine(Plugin.GetPluginConfigDir, ChangeFileExt(Plugin.GetName, '.xml'));
  ProjectList := TProjectList.Create;
  TemplateList := TTemplateList.Create(TemplateFile);
end;

function TESPHomePlugin.GetFuncItemIdFromIndex(const Index: Integer): string;
begin
  Result := '';
  if (Length(FFuncItemsNames) > Index) and (Index >= 0) then
    Result := FFuncItemsNames[Index];
end;

function TESPHomePlugin.GetIndexFromFuncItemName(const FuncItemName: string): Integer;
var
  Index: Integer;
begin
  Result := -1;
  for Index := 0 to High(FFuncItemsNames) do
    if CompareText(FFuncItemsNames[Index], FuncItemName) = 0 then
    begin
      Result := Index;
      Exit;
    end;
end;

function TESPHomePlugin.GetCmdIdFromFuncItemName(const FuncItemName: string): Integer;
begin
  Result := CmdIdFromMenuItemIdx(GetIndexFromFuncItemName(FuncItemName));
end;

function TESPHomePlugin.GetToolbarConfiguration(const ADefault: Boolean = False): string;
var
  Regex: TRegEx;
  I, Index, Count: Integer;
  DefaultConfig: string;
begin
  Index := 0;
  DefaultConfig := '';
  GetFuncsArray(Count);
  for I := 0 to Count - 1 do
    if Resources.StandardImages.GetIndexByName(GetFuncItemIdFromIndex(I)) >= 0 then
    begin
      DefaultConfig := Concat(DefaultConfig, IntToStr(Index), ':1;');
      Inc(Index);
    end;
  Result := DefaultConfig;

  if not ADefault then
  begin
    Result := ConfigIniFile.ReadString(csSectionGeneral, csKeyToolbarConfig, DefaultConfig);
    Regex := TRegEx.Create(Format('^(?:\d+:[01];){%d}$', [DefaultConfig.CountChar(':')]));
    if not Regex.IsMatch(Result) then
      Result := DefaultConfig;
  end;
end;

procedure TESPHomePlugin.InitializeToolbarConfiguration;
var
  Bitmap: TBitmap;
  FuncItemID: string;
  Index, Count, Sequence: Integer;
begin
  if not IsNppMinVersion(8, 0) then
    Exit;

  Sequence := 0;
  GetFuncsArray(Count);
  for Index := 0 to Count - 1 do
  begin
    FuncItemId := GetFuncItemIdFromIndex(Index);
    if Resources.StandardImages.GetIndexByName(FuncItemID) >= 0 then
    begin
      SetLength(FToolbarButtons, Sequence + 1);
      FillChar(FToolbarButtons[Sequence], SizeOf(FToolbarButtons[Sequence]), 0);
      FToolbarButtons[Sequence].Sequence := Sequence;
      FToolbarButtons[Sequence].CmdID := CmdIdFromMenuItemIdx(Index);
      FToolbarButtons[Sequence].Visible := False;
      FToolbarButtons[Sequence].Enabled := True;
      FToolbarButtons[Sequence].FuncItemID := FuncItemID;
      FToolbarButtons[Sequence].Index := Index;
      Bitmap := Resources.LowResImages.GetBitmap(FuncItemID, 20, 20);
      FToolbarButtons[Sequence].IconData.ToolbarBmp := HBITMAP(CopyImage(Bitmap.Handle, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION));
      Bitmap.Free;
      Bitmap := Resources.StandardImages.GetBitmap(FuncItemID, 40, 40);
      FToolbarButtons[Sequence].IconData.ToolbarIconDarkMode := CreateIconFromBitmap(Bitmap);
      ConvertBitmapToBlack(Bitmap);
      FToolbarButtons[Sequence].IconData.ToolbarIcon := CreateIconFromBitmap(Bitmap);
      Bitmap.Free;
      AddToolbarIcon(FToolbarButtons[Sequence].CmdID, FToolbarButtons[Sequence].IconData);
      Inc(Sequence);
    end;
  end;
end;

procedure TESPHomePlugin.RegisterToolbarConfiguration;
var
  Index: Integer;
  ToolbarHandle: HWND;
  ButtonIndex: LRESULT;
begin
  if not IsNppMinVersion(8, 0) then
    Exit;

  ToolbarHandle := GetToolbarHandle;

  if ToolbarHandle = 0 then
    Exit;

  for Index := 0 to High(FToolbarButtons) do
  begin
    FillChar(FToolbarButtons[Index].Button, SizeOf(TTBButton), 0);
    ButtonIndex := SendMessage(ToolbarHandle, TB_COMMANDTOINDEX, FToolbarButtons[Index].CmdID, 0);
    if ButtonIndex >= 0 then
      SendMessage(ToolbarHandle, TB_GETBUTTON, ButtonIndex, LPARAM(@FToolbarButtons[Index].Button));
   end;

end;


// Rebuilds the plugin toolbar according to the saved user configuration.
//
// Notepad++ toolbar buttons are bound to plugin function command IDs, but their
// physical toolbar indexes and image indexes can change whenever buttons are
// hidden, reordered, deleted/reinserted, or when Notepad++ refreshes the toolbar
// during a dark/light mode switch.
//
// This routine therefore does all toolbar work in one pass:
//   1. removes the current plugin buttons from the native Notepad++ toolbar;
//   2. reloads the saved logical order and visibility;
//   3. reinserts only the visible buttons, preserving their command IDs;
//   4. applies the cached enabled/disabled state directly to each TBBUTTON;
//   5. rebuilds the disabled image list using the current physical iBitmap
//      values read back from the toolbar.
//
// The important rule is that cached TBBUTTON data is used only as a template.
// Runtime-sensitive values such as the physical toolbar index and iBitmap are
// always resolved again from the current toolbar instance.
procedure TESPHomePlugin.RefreshToolbarConfiguration;
var
  Items: TArray<string>;
  Parts: TArray<string>;
  ToolbarHandle: HWND;
  ButtonIndex: LRESULT;
  FuncIndex, ConfigIndex: Integer;
  ToolbarConfig: string;
  Visible: Boolean;

  TempBmp: TBitmap;
  TempIcon: TIcon;
  IconSize: TPoint;
  NormalListHandle: HIMAGELIST;
  DisabledListHandle: HIMAGELIST;
  NewIcon: HICON;
  Button: TTBButton;
  ImgIdx: Integer;

  procedure PrepareButton(var AToolbarButton: TToolbarButton);
  begin
    // Keep the button bound to the original Notepad++ function command.
    // This is important after deleting/re-adding buttons, because toolbar
    // position and function item index are not the same thing.
    AToolbarButton.Button.idCommand := AToolbarButton.CmdID;

    // Apply the cached logical enabled state directly to the TBBUTTON.
    // This makes the button enter the toolbar already enabled/disabled,
    // instead of relying only on a later TB_ENABLEBUTTON call.
    if AToolbarButton.Enabled then
      AToolbarButton.Button.fsState := AToolbarButton.Button.fsState or TBSTATE_ENABLED
    else
      AToolbarButton.Button.fsState := AToolbarButton.Button.fsState and not TBSTATE_ENABLED;
  end;

  procedure RefreshDisabledImage(const ACmdID: Integer);
  begin
    // Resolve the current physical toolbar button from its command id.
    // This avoids using stale iBitmap values cached before buttons were
    // hidden, reordered, or recreated by Notepad++.
    ButtonIndex := SendMessage(ToolbarHandle, TB_COMMANDTOINDEX, WPARAM(ACmdID), 0);
    if ButtonIndex < 0 then
      Exit;

    FillChar(Button, SizeOf(Button), 0);
    if SendMessage(ToolbarHandle, TB_GETBUTTON, ButtonIndex, LPARAM(@Button)) = 0 then
      Exit;

    ImgIdx := Button.iBitmap;
    if ImgIdx < 0 then
      Exit;

    // Extract the current normal image for this button from Notepad++'s
    // toolbar image list, then render it to a bitmap so it can be converted
    // to the plugin's custom disabled appearance.
    TempIcon.Handle := ImageList_GetIcon(NormalListHandle, ImgIdx, ILD_NORMAL);
    if TempIcon.Handle = 0 then
      Exit;

    try
      TempBmp.Canvas.Brush.Color := clBtnFace;
      TempBmp.Canvas.FillRect(Rect(0, 0, IconSize.X, IconSize.Y));
      TempBmp.Canvas.Draw(0, 0, TempIcon);
    finally
      DestroyIcon(TempIcon.Handle);
      TempIcon.Handle := 0;
    end;

    // Replace only the disabled image for the current physical image index.
    // The normal/dark icon remains managed by Notepad++.
    ConvertBitmapToDisabled(TempBmp);

    NewIcon := CreateIconFromBitmap(TempBmp);
    if NewIcon <> 0 then
    try
      ImageList_ReplaceIcon(DisabledListHandle, ImgIdx, NewIcon);
    finally
      DestroyIcon(NewIcon);
    end;
  end;

begin
  if not IsNppMinVersion(8, 0) then
    Exit;

  ToolbarHandle := GetToolbarHandle;
  if ToolbarHandle = 0 then
    Exit;

  // Remove every plugin toolbar button currently present.
  // Buttons may have been reordered or partially hidden, so each command is
  // looked up repeatedly until no toolbar button with that command remains.
  for FuncIndex := 0 to High(FToolbarButtons) do
  begin
    repeat
      ButtonIndex := SendMessage(ToolbarHandle, TB_COMMANDTOINDEX, WPARAM(FToolbarButtons[FuncIndex].CmdID), 0);
      if ButtonIndex >= 0 then
        SendMessage(ToolbarHandle, TB_DELETEBUTTON, ButtonIndex, 0);
    until ButtonIndex < 0;

    FToolbarButtons[FuncIndex].Visible := False;
  end;

  // Reload the persisted logical toolbar configuration.
  // Each item is stored as "toolbarButtonIndex:visible", and the item order
  // in the string is the desired toolbar order.
  ToolbarConfig := GetToolbarConfiguration;
  Items := ToolbarConfig.Split([';'], TStringSplitOptions.ExcludeEmpty);

  for ConfigIndex := 0 to High(Items) do
  begin
    Parts := Items[ConfigIndex].Split([':']);
    if Length(Parts) <> 2 then
      Continue;

    if not TryStrToInt(Parts[0], FuncIndex) then
      Continue;

    if (FuncIndex < 0) or (FuncIndex > High(FToolbarButtons)) then
      Continue;

    Visible := Parts[1] = '1';

    // Store the logical order and visibility back into the in-memory model.
    FToolbarButtons[FuncIndex].Sequence := ConfigIndex;
    FToolbarButtons[FuncIndex].Visible := Visible;

    if not Visible then
      Continue;

    // Insert only visible buttons, already carrying the correct command id
    // and enabled/disabled state.
    PrepareButton(FToolbarButtons[FuncIndex]);

    SendMessage(ToolbarHandle, TB_ADDBUTTONS, 1, LPARAM(@FToolbarButtons[FuncIndex].Button));

    // Force the state once more after insertion. This helps after dark/light
    // mode changes, where the toolbar can refresh its internal state.
    SendMessage(ToolbarHandle, TB_SETSTATE, WPARAM(FToolbarButtons[FuncIndex].CmdID), LPARAM(FToolbarButtons[FuncIndex].Button.fsState));
  end;

  SendMessage(ToolbarHandle, TB_AUTOSIZE, 0, 0);
  SendMessage(ToolbarHandle, TB_SETMAXTEXTROWS, 0, 0);

  // Rebuild the disabled image list after the toolbar has been recreated.
  // At this point the physical iBitmap values are the current valid ones.
  NormalListHandle := SendMessage(ToolbarHandle, TB_GETIMAGELIST, 0, 0);
  DisabledListHandle := SendMessage(ToolbarHandle, TB_GETDISABLEDIMAGELIST, 0, 0);

  if (NormalListHandle <> 0) and (DisabledListHandle <> 0) then
  begin
    ImageList_GetIconSize(NormalListHandle, IconSize.X, IconSize.Y);

    TempBmp := TBitmap.Create;
    TempIcon := TIcon.Create;
    try
      TempBmp.PixelFormat := pf32bit;
      TempBmp.SetSize(IconSize.X, IconSize.Y);

      for FuncIndex := 0 to High(FToolbarButtons) do
        if FToolbarButtons[FuncIndex].Visible then
          RefreshDisabledImage(FToolbarButtons[FuncIndex].CmdID);
    finally
      TempIcon.Free;
      TempBmp.Free;
    end;
  end;

  // Ask the native toolbar to repaint with the new order, visibility,
  // enabled state, and disabled images.
  InvalidateRect(ToolbarHandle, nil, True);
  ShowWindow(ToolbarHandle, SW_SHOW);
  UpdateWindow(ToolbarHandle);

  if Assigned(FormProjects) then
    CheckMenuItem(GetIndexFromFuncItemName(fiShowHidePrjWin), FormProjects.Visible);
end;

procedure TESPHomePlugin.FreeToolbarResources;
var
  Index: Integer;
begin
  if not IsNppMinVersion(8, 0) then
    Exit;
  for Index := 0 to High(FToolbarButtons) do
  begin
    with FToolbarButtons[Index].IconData do
    begin
      if ToolbarBmp <> 0 then
        DeleteObject(ToolbarBmp);
      if ToolbarIcon <> 0 then
        DestroyIcon(ToolbarIcon);
      if ToolbarIconDarkMode <> 0 then
        DestroyIcon(ToolbarIconDarkMode);
    end;
    with FToolbarButtons[Index] do
      FillChar(IconData, SizeOf(IconData), 0);
  end;
end;

procedure TESPHomePlugin.EnableToolbarItem(MenuItemIdx: Integer; State: Boolean);
var
  CmdID: Integer;
  ButtonIndex: LRESULT;
  ButtonState: LRESULT;
  ToolbarHandle: HWND;

function GetIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(Plugin.FToolbarButtons) do
    if Plugin.FToolbarButtons[I].CmdID = CmdID then
    begin
      Result := I;
      Exit
    end;
end;

begin
  ToolbarHandle := Plugin.GetToolbarHandle;
  CmdID := CmdIdFromMenuItemIdx(MenuItemIdx);

  if (ToolbarHandle = 0) or (CmdID < 0) then
    Exit;

  ButtonIndex := SendMessage(ToolbarHandle, TB_COMMANDTOINDEX, WPARAM(CmdID), 0);
  if ButtonIndex < 0 then
    Exit;

  ButtonState := SendMessage(ToolbarHandle, TB_GETSTATE, WPARAM(CmdID), 0);
  if ButtonState < 0 then
    Exit;

  if State then
    ButtonState := ButtonState or TBSTATE_ENABLED
  else
    ButtonState := ButtonState and not TBSTATE_ENABLED;

  if SendMessage(ToolbarHandle, TB_SETSTATE, WPARAM(CmdID), LPARAM(ButtonState)) >= 0 then
  begin
    ButtonIndex := GetIndex;
    if ButtonIndex >= 0 then
      Plugin.FToolbarButtons[ButtonIndex].Enabled := State;
  end;
end;

procedure TESPHomePlugin.RefreshCurrentProject;
begin
end;

procedure TESPHomePlugin.RefreshProjectList;
begin
  if Assigned(FormProjects) then
    FormProjects.RefreshProjectsList;
  RefreshNppTitle;
  RefreshPluginMenu;
end;

procedure TESPHomePlugin.RefreshNppTitle;
const
  SepChar = '|';
var
  Index: Integer;
  Title: string;
begin
  Title := GetNppWindowTitle;
  Index := Pos(SepChar, Title);
  if Index > 0 then
    Title := Trim(Copy(Title, 1, Index - 1));
  if Assigned(ProjectList.Current) then
    Title := Format('%s %s ESPHome Project: %s', [Title, SepChar, ProjectList.Current.FriendlyName]);
  SetWindowText(NppData.NppHandle, PChar(Title));
end;

procedure TESPHomePlugin.RefreshPluginMenu;
var
  Text: string;
  PluginMenu: HMENU;
  ShortcutKey: TShortcutKey;
  PFunc: PFuncItem;
  ProjectAssigned: Boolean;

procedure EnableItem(FuncItemID: string; Status: Boolean);
var
  Index: Integer;
begin
  Index := GetIndexFromFuncItemName(FuncItemID);
  if Index >= 0 then
  begin
    EnableMenuItem(Index, Status);
    EnableToolbarItem(Index, Status);
    //SetToolbarItemEnabled(CmdIdFromMenuItemIdx(Index), Status);
  end;
end;

begin
  ProjectAssigned := Assigned(ProjectList.Current);

  PluginMenu := HMENU(SendMessage(NppData.NppHandle, NPPM_GETMENUHANDLE, NPPPLUGINMENU, 0));
  if PluginMenu <> 0 then
  begin
    if ProjectAssigned then
      Text := Format(miProjectConfigureEx, [ProjectList.Current.FriendlyName])
    else
      Text := miProjectConfigure;
    PFunc := GetFuncByIndex(GetIndexFromFuncItemName(fiProjectConfigure));
    if Assigned(PFunc) then
    begin
      if SendMessage(NppData.NppHandle, NPPM_GETSHORTCUTBYCMDID, PFunc^.CmdID, LPARAM(@ShortcutKey)) <> 0 then
        Text := Text + #09 + ShortcutToString(@ShortcutKey);
      if ModifyMenu(PluginMenu, PFunc^.CmdID, MF_BYCOMMAND or MF_STRING, PFunc^.CmdID, PChar(Text)) then
        DrawMenuBar(NppData.NppHandle);
    end;
  end;

  EnableItem(fiProjectConfigure, ProjectAssigned);
  EnableItem(fiProjectOpenFiles, ProjectAssigned);
  EnableItem(fiProjectRemove, ProjectAssigned);
  EnableItem(fiCommandRun, ProjectAssigned);
  EnableItem(fiCommandCompile, ProjectAssigned);
  EnableItem(fiCommandUpload, ProjectAssigned);
  EnableItem(fiCommandLogs, ProjectAssigned);
  EnableItem(fiCommandClean, ProjectAssigned);
  EnableItem(fiCommandCleanAll, ProjectAssigned);
  EnableItem(fiStartTerminal, ProjectAssigned);
  EnableItem(fiStartExplorer, ProjectAssigned);

end;

function TESPHomePlugin.CheckESPHome: Boolean;
begin
  Result := False;
  if not FileExists(ESPHomeFile) then
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

