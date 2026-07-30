// Main Notepad++ plugin unit for NppESPHome.
// Registers the plugin commands, manages Notepad++ events, toolbar integration,
// project commands, and the project docking window lifecycle.
unit NppESPHome.Plugin;

interface

uses
  Winapi.Windows, Winapi.CommCtrl, System.SysUtils, System.Classes, Vcl.Graphics, NppMessages, NppPlugin, NppPluginForm, NppPluginDockingForm, NppESPHome.Shared,
  Vcl.ImageCollection, Vcl.BaseImageCollection;

const
  csPluginName = 'NppESPHome';
  csMenuEmptyLine = '-';

// Internal identifiers used to map Notepad++ function items to plugin actions,
// toolbar images, persisted toolbar configuration, and menu refresh logic.
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


// Localized menu labels and command captions used when registering plugin actions.
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
  // Data module that contains the image collections used by menus, toolbars,
  // windows, and light/dark mode icon generation.
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
  // Stores the full runtime state of a plugin toolbar button.
  // It keeps the stable plugin function mapping together with the current
  // native Notepad++ toolbar button data and icon handles.
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
  // Maps Notepad++ function item indexes back to the plugin's stable IDs.
  TFuncItemsNames = TArray<string>;

type
  // Main plugin class. Handles Notepad++ lifecycle notifications, ESPHome
  // project commands, toolbar customization, menu state, and project window
  // synchronization.

  TESPHomePlugin = class(TNppPlugin)

    OperationsOngoing: Boolean; // True while plugin-driven file operations should not trigger UI refresh loops
    FFuncItemsNames: TFuncItemsNames; // Stable function IDs indexed by Notepad++ function item index
    FToolbarButtons: TToolbarButtons; // Runtime toolbar button model used to rebuild the native Notepad++ toolbar

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

  LastConsolePID: DWORD; // PID of the last ESPHome console process started by the plugin


var
  Resources: TResources; // Shared image resource data module

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{$B-}

uses
  JvCreateProcess, Winapi.ShellAPI, NppESPHome.FormSelectProject, NppESPHome.FormConfiguration, System.StrUtils,
  NppESPHome.FormToolbar, NppESPHome.FormAbout, NppESPHome.FormProjects, IniFiles, System.RegularExpressions, TDMB, Vcl.Forms, Vcl.Dialogs,
  System.Math,
  System.UITypes,
  System.IOUtils;

resourcestring
  rsInvalidESPHomeInstallation = 'No valid installation of ESPHome has been found on your system.';
  rsInvalidESPHomeInstallation2 = 'Please (re)install ESPHome following the instructions available on the following web page:';
  rsInvalidESPHomeInstallation3 = '<a href="https://www.esphome.io/guides/installing_esphome/">Installing ESPHome Manually</a>';

  rsNoProjectSelected = 'No ESPHome project is currently selected.';
  rsNoProjectSelected2 = 'To use this command, please select the current project and try again.'#13#13#10'You can select it through the menu command:'#13#10'"Plugins" -> "NppESPHome" -> "Select Project..."';

{$REGION 'Callback Wrappers'}

// C-style callback wrappers registered with Notepad++.
// Notepad++ invokes these plain procedures, and each wrapper forwards the call
// to the current plugin instance where the real implementation lives.

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.ProjectAdd.
// *****************************************************************************
procedure _ProjectAdd; cdecl;
begin
	Plugin.ProjectAdd;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.ProjectSelect.
// *****************************************************************************
procedure _ProjectSelect; cdecl;
begin
	Plugin.ProjectSelect;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.ProjectRemove.
// *****************************************************************************
procedure _ProjectRemove; cdecl;
begin
	Plugin.ProjectRemove;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.ProjectConfigure.
// *****************************************************************************
procedure _ProjectConfigure; cdecl;
begin
	Plugin.ProjectConfigure;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.ProjectOpenFiles.
// *****************************************************************************
procedure _ProjectOpenFiles; cdecl;
begin
	Plugin.ProjectOpenFiles;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.CommandRun.
// *****************************************************************************
procedure _CommandRun; cdecl;
begin
	Plugin.CommandRun;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.CommandCompile.
// *****************************************************************************
procedure _CommandCompile; cdecl;
begin
	Plugin.CommandCompile;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.CommandUpload.
// *****************************************************************************
procedure _CommandUpload; cdecl;
begin
	Plugin.CommandUpload;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.CommandLogs.
// *****************************************************************************
procedure _CommandLogs; cdecl;
begin
	Plugin.CommandLogs;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.CommandClean.
// *****************************************************************************
procedure _CommandClean; cdecl;
begin
	Plugin.CommandClean;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.CommandCleanAll.
// *****************************************************************************
procedure _CommandCleanAll; cdecl;
begin
	Plugin.CommandCleanAll;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to TESPHomePlugin.StartHelp.
// *****************************************************************************
procedure _StartHelp; cdecl;
begin
	Plugin.StartHelp;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.StartUpgrade.
// *****************************************************************************
procedure _StartUpgrade; cdecl;
begin
	Plugin.StartUpgrade;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.StartTerminal.
// *****************************************************************************
procedure _StartTerminal; cdecl;
begin
	Plugin.StartTerminal;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.StartExplorer.
// *****************************************************************************
procedure _StartExplorer; cdecl;
begin
	Plugin.StartExplorer;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.ShowHidePrjWin.
// *****************************************************************************
procedure _ShowHidePrjWin; cdecl;
begin
	Plugin.ShowHidePrjWin;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.ConfigToolbar.
// *****************************************************************************
procedure _ConfigToolbar; cdecl;
begin
	Plugin.ConfigToolbar;
end;

// *****************************************************************************
// Purpose: Forwards the Notepad++ command callback to
// TESPHomePlugin.AboutWindow.
// *****************************************************************************
procedure _AboutWindow; cdecl;
begin
	Plugin.AboutWindow;
end;

{$ENDREGION}

// ============================================================================
// Local Helper Functions
// ============================================================================

// *****************************************************************************
// Purpose: Moves an external console window to the configured monitor position.
// It preserves the current window size and only adjusts the top-left corner.
// *****************************************************************************
procedure PositionWindow(Wnd: HWND; Position: Integer; Monitor: Integer = 0; Margin: Integer = -1);
var
  R: TRect;
  WorkArea: TRect;
  W, H: Integer;
  X, Y: Integer;
begin
  if Wnd <> 0 then
  begin

    // Resolve the requested monitor, falling back to the primary monitor when needed.
    if Monitor < Screen.MonitorCount  then
      WorkArea := Screen.Monitors[Monitor].WorkareaRect
    else
      WorkArea := Screen.PrimaryMonitor.WorkareaRect;

    GetWindowRect(Wnd, R);
    W := R.Right - R.Left;
    H := R.Bottom - R.Top;

    // Default margin is relative to the monitor work area so it scales with the screen.
    if Margin < 0 then
      Margin := (WorkArea.Right - WorkArea.Left) div 50;
    // Translate the saved position setting into absolute screen coordinates.
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

// *****************************************************************************
// Purpose: Builds and launches an ESPHome command for the current project. It
// applies project options, auto-save behavior, log level, target device,
// console positioning, and optional single-console mode before showing the
// command window.
// *****************************************************************************
procedure ExecuteESPHomeCommand(const Command: Integer);
const
  CommandStr: array [scRun .. scCleanAll] of string = ('run', 'compile', 'upload', 'logs', 'clean', 'clean-all');
var
  ConsoleHandle: HWND;
  CommandLine, Switch, Device: string;
  ESPHomeProcess: TJvCreateProcess;
begin
  // A command can only run when both the current project and esphome.exe are available.
  if not Assigned(ProjectList.Current) or not FileExists(ESPHomeFile) then
    Exit;

  with ProjectList.Current do
  begin
    // Apply the project's auto-save policy before invoking the external process.
    case GetOption(csKeyNppAutosave, ciAutoSaveAllFiles) of
      ciAutoSaveProject:
        Plugin.SaveProject;
      ciAutoSaveProjectAndDeps:
        Plugin.SaveProjectAndDependencies;
      ciAutoSaveAllFiles:
        Plugin.SaveAllFiles;
    end;

    CommandLine := Format('"%s"', [ExpandFileName(ESPHomeFile)]);

    // Convert the stored log level index into the CLI switch expected by ESPHome.
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

    // Append any global extra parameters configured for every ESPHome command.
    Switch := Trim(GetOption(csKeyESPHomeExtraParameters, csDefaultEmpty));
    if Switch <> csDefaultEmpty then
      CommandLine := Format('%s %s', [CommandLine, Switch]);

    // Convert the stored device choice into an ESPHome --device argument when needed.
    Device := GetOption(csKeyESPHomeTargetDevice, rsDefaultNone);

    if SameText(Device, rsDefaultWiFi) then
      Device := '--device OTA'
    else if StartsText('COM', Device) then
      Device := '--device ' + Device
    else
      Device := csDefaultEmpty;

    // Add command-specific options such as reset, no-logs, or only-generate.
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

    // Wrap the command for cmd.exe, choosing whether the console closes automatically.
    if GetOption(csKeyConsoleAutoClose, True) then
      CommandLine := Format('/c "%s" || pause', [CommandLine])
    else
      CommandLine := Format('/k "%s"', [CommandLine]);

    // Optional solo mode keeps only one ESPHome console alive at a time.
    if GetOption(csKeyConsoleSoloMode, False) then
      if IsPIDRunning(LastConsolePID) then
        KillProcessTree(LastConsolePID);

    // Configure the external console process but keep it hidden until it is positioned.
    ESPHomeProcess := TJvCreateProcess.Create(nil);
    try
      ESPHomeProcess.ApplicationName := GetEnvironmentVariable('ComSpec');
      ESPHomeProcess.CommandLine := CommandLine;
      ESPHomeProcess.CurrentDirectory := ExtractFilePath(ProjectList.Current.FileName);
      ESPHomeProcess.CreationFlags := ESPHomeProcess.CreationFlags + [cfNewConsole];

      // Set a user-friendly console title based on the command and project name.
      with ESPHomeProcess.StartupInfo do
      begin
        ShowWindow := swHide;
        DefaultWindowState := False;
        // Add command-specific options such as reset, no-logs, or only-generate.
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

      // Start the process, then locate the console window created for it.
      ESPHomeProcess.Run;

      LastConsolePID := ESPHomeProcess.ProcessInfo.dwProcessId;
      ConsoleHandle := GetMainWindowHandleByPID(LastConsolePID, 3000);

      // Once the window exists, move it to the requested screen position and show it.
      if ConsoleHandle <> 0 then
      begin
        PositionWindow(ConsoleHandle, GetOption(csKeyConsoleStartingPosition, ciConsolePosDecidedByWindows), GetOption(csKeyConsoleStartingMonitor, 0));
        if GetOption(csKeyConsoleAlwaysOnTop, False) then
          SetWindowPos(ConsoleHandle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
        ShowWindow(ConsoleHandle, SW_SHOW);
      end
      else
        ESPHomeProcess.TerminateTree;
    except
      ESPHomeProcess.Free;
    end;

  end;
end;

resourcestring
  rsProjectAddFileTypeItem = 'ESPHome project file';
  rsProjectAddFileOpenTitle = 'Add an existing ESPHome project to the known ones';

// ============================================================================
// Project Menu Commands
// ============================================================================

// *****************************************************************************
// Purpose: Lets the user select an existing ESPHome YAML file and adds it to
// the known project list after validating it as a project.
// *****************************************************************************
procedure TESPHomePlugin.ProjectAdd;
var
  Project: TProject;
  FileOpen: TFileOpenDialog;
  FileTypeItem: TFileTypeItem;
begin
  // Configure a strict file dialog so only existing ESPHome YAML files are selectable.
  FileOpen := TFileOpenDialog.Create(nil);
  try
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
      // Prevent duplicate project registrations for the same YAML file.
      if Assigned(ProjectList.GetProjectFromFileName(FileOpen.FileName)) then
        TD(Format(rsProjectAlreadyExists, [ExtractFileName(FileOpen.FileName)])).WindowCaption(rsMessageBoxError).
          Text(rsProjectAlreadyExists2).SetFlags([tfAllowDialogCancellation]).Error.OK.Execute(nil)
      else
      begin
        // Parse the selected YAML immediately; invalid ESPHome files are rejected.
        Project := TProject.Create(FileOpen.FileName);
        if Project.IsValid then
        begin
          // Make the newly added project current and persist the updated project list.
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
  finally
    FileOpen.Free;
  end;
end;

// *****************************************************************************
// Purpose: Opens the project selection dialog and refreshes the Notepad++ title
// and plugin menu state after the selection changes.
// *****************************************************************************
procedure TESPHomePlugin.ProjectSelect;
var
  FormSelection: TFormSelection;
begin
  // The selection form updates ProjectList.Current while it is open.
  FormSelection := TFormSelection.Create(Self);
  try
    FormSelection.ShowModal;
  finally
    FreeAndNil(FormSelection);
  end;
  RefreshNppTitle;
  RefreshPluginMenu;
end;

// *****************************************************************************
// Purpose: Removes the current project from the configured project list after
// user confirmation. The project files themselves are left untouched.
// *****************************************************************************
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
      // Remember the old index so the next nearest project can become current.
      I := ProjectList.IndexOf(ProjectList.Current);
      // Remove only the stored project entry; the YAML file remains on disk.
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

// *****************************************************************************
// Purpose: Opens the configuration dialog for the currently selected project.
// *****************************************************************************
procedure TESPHomePlugin.ProjectConfigure;
var
  FormConfiguration: TFormConfig;
begin
  if CheckCurrentProject then
  begin
    // The configuration form reads and writes options for ProjectList.Current.
    FormConfiguration := TFormConfig.Create(Self);
    try
      FormConfiguration.ShowModal;
    finally
      FreeAndNil(FormConfiguration);
    end;
  end;
end;

// *****************************************************************************
// Purpose: Opens the current project file and all configured dependency files
// in Notepad++, then returns focus to the main project file.
// *****************************************************************************
procedure TESPHomePlugin.ProjectOpenFiles;
var
  FileName: string;
begin
  if not CheckCurrentProject then
    Exit;
  // Suppress document-change refresh handlers while opening a batch of files.
  OperationsOngoing := True;
  OpenFile(ProjectList.Current.FileName);
  // Reload dependencies from the INI before opening them in Notepad++.
  ProjectList.Current.LoadOptionDependencies;
  for FileName in ProjectList.Current.OptionDependencies do
    if FileExists(FileName) then
      OpenFile(FileName);
  // Re-enable normal notification handling after plugin-driven file opens finish.
  // From this point on, Notepad++ document notifications can update the UI.
  OperationsOngoing := False;
  SwitchToFile(ProjectList.Current.FileName);
  RefreshNppTitle;
  RefreshPluginMenu;
end;

// ============================================================================
// ESPHome Command Menu Handlers
// ============================================================================

// *****************************************************************************
// Purpose: Runs the configured ESPHome 'run' command for the current project.
// *****************************************************************************
procedure TESPHomePlugin.CommandRun;
begin
  if CheckESPHome and CheckCurrentProject then
    ExecuteESPHomeCommand(scRun);
end;

// *****************************************************************************
// Purpose: Runs the ESPHome compile command for the current project.
// *****************************************************************************
procedure TESPHomePlugin.CommandCompile;
begin
  if CheckESPHome and CheckCurrentProject then
    ExecuteESPHomeCommand(scCompile);
end;

// *****************************************************************************
// Purpose: Uploads the current project using the configured ESPHome target
// device.
// *****************************************************************************
procedure TESPHomePlugin.CommandUpload;
begin
  if CheckESPHome and CheckCurrentProject then
    ExecuteESPHomeCommand(scUpload);
end;

// *****************************************************************************
// Purpose: Opens ESPHome logs for the current project.
// *****************************************************************************
procedure TESPHomePlugin.CommandLogs;
begin
  if CheckESPHome and CheckCurrentProject then
    ExecuteESPHomeCommand(scLogs);
end;

// *****************************************************************************
// Purpose: Runs ESPHome clean for the current project build files.
// *****************************************************************************
procedure TESPHomePlugin.CommandClean;
begin
  if CheckESPHome and CheckCurrentProject then
    ExecuteESPHomeCommand(scClean);
end;

// *****************************************************************************
// Purpose: Confirms and runs ESPHome clean-all for the current project. This is
// intentionally guarded because it can remove large PlatformIO caches.
// *****************************************************************************
procedure TESPHomePlugin.CommandCleanAll;
begin
  if CheckESPHome and CheckCurrentProject then
  begin
    // clean-all is destructive enough to require an explicit confirmation dialog.
    if TD.ClearFlag(tfPositionRelativeToWindow).
          WindowCaption(rsMessageBoxWarning).
          Text(rsConfirmExecuteCleanAll).
          Text(Format(rsConfirmExecuteCleanAll2, [ProjectList.Current.FriendlyName])).
          Warning.YesNo.Execute = mrYes then
      ExecuteESPHomeCommand(scCleanAll);
  end;
end;

// ============================================================================
// Utility Menu Commands
// ============================================================================

// *****************************************************************************
// Purpose: Opens the ESPHome online documentation in the user's browser.
// *****************************************************************************
procedure TESPHomePlugin.StartHelp;
begin
  // Let Windows choose the default browser for the ESPHome documentation URL.
  ShellExecute(0, 'open', PChar(rsESPHomeDocURL), nil, nil, SW_SHOWNORMAL);
end;

// *****************************************************************************
// Purpose: Starts a console command that upgrades ESPHome through pip and
// prints the installed ESPHome version afterward.
// *****************************************************************************
procedure TESPHomePlugin.StartUpgrade;
var
  JvCreateProcess: TJvCreateProcess;
begin
  if not CheckESPHome then
    Exit;

  // Launch the upgrade in a visible console so pip output and errors stay readable.
  JvCreateProcess := TJvCreateProcess.Create(nil);
  JvCreateProcess.ApplicationName := GetEnvironmentVariable('ComSpec');
  JvCreateProcess.CommandLine := Format('/c pip.exe install --upgrade esphome & "%s" --version & pause', [ExpandFileName(ESPHomeFile)]);
  JvCreateProcess.StartupInfo.Title := miStartUpgrade;
  JvCreateProcess.Run;
  JvCreateProcess.Free;
end;

// *****************************************************************************
// Purpose: Opens a command shell in the current project folder and injects
// useful ESPHome and project path environment variables.
// *****************************************************************************
procedure TESPHomePlugin.StartTerminal;
var
  JvCreateProcess: TJvCreateProcess;
begin
  if not CheckCurrentProject then
    Exit;
  // Launch the upgrade in a visible console so pip output and errors stay readable.
  JvCreateProcess := TJvCreateProcess.Create(nil);
  JvCreateProcess.ApplicationName := GetEnvironmentVariable('ComSpec');
  // Start the shell in the project folder so relative ESPHome paths work naturally.
  JvCreateProcess.CurrentDirectory := ExtractFilePath(ProjectList.Current.FileName);
  JvCreateProcess.CommandLine := '';
  JvCreateProcess.StartupInfo.Title := Format('[%s]', [ProjectList.Current.FriendlyName]);
  // Copy the current environment and add plugin-specific convenience variables.
  GetEnvironmentVars(JvCreateProcess.Environment);
  JvCreateProcess.Environment.Add(Format('ESPHome=%s', [ExpandFileName(ESPHomeFile)]));
  JvCreateProcess.Environment.Add(Format('ESPProject=%s', [ExpandFileName(ProjectList.Current.FileName)]));
  JvCreateProcess.Run;
  JvCreateProcess.Free;
end;

// *****************************************************************************
// Purpose: Opens Windows Explorer in the current project folder.
// *****************************************************************************
procedure TESPHomePlugin.StartExplorer;
begin
  if not CheckCurrentProject then
    Exit;
  if ProjectList.Current.FileName <> '' then
    // Open the folder directly instead of selecting a file inside it.
    ShellExecute(0, 'open', PChar(ExtractFilePath(ProjectList.Current.FileName)), nil, nil, SW_SHOWNORMAL);
end;

// *****************************************************************************
// Purpose: Toggles the docked project window visibility and persists the choice
// in the plugin configuration INI.
// *****************************************************************************
procedure TESPHomePlugin.ShowHidePrjWin;
begin
  if Assigned(FormProjects) then
  begin
    // Keep the menu checkmark and persisted setting aligned with the docked form.
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

// *****************************************************************************
// Purpose: Opens the toolbar customization dialog.
// *****************************************************************************
procedure TESPHomePlugin.ConfigToolbar;
begin
  // The toolbar dialog edits the persisted order and visibility configuration.
  FormToolbar := TFormToolbar.Create(Self);
  try
    FormToolbar.ShowModal;
  finally
    FreeAndNil(FormToolbar);
  end;
end;

// *****************************************************************************
// Purpose: Opens the plugin About dialog.
// *****************************************************************************
procedure TESPHomePlugin.AboutWindow;
begin
  // The About form is modal so ownership and lifetime stay simple.
  FormAbout := TFormAbout.Create(Self);
  try
    FormAbout.ShowModal;
  finally
    FreeAndNil(FormAbout);
  end;
end;

// ============================================================================
// Plugin Registration and Notepad++ Notifications
// ============================================================================

// *****************************************************************************
// Purpose: Registers one Notepad++ function item and stores the plugin's stable
// action identifier at the returned function item index.
// *****************************************************************************
function TESPHomePlugin.AddPluginFunction(FuncItemName: string; FuncItemDescription: nppString; FuncCmdProc: FuncItemCmdProc; ShortcutKey: PShortcutKey = nil; MenuChecked: Boolean = False): Integer;
begin
  // Let the base plugin register the command, then store our stable ID beside it.
  Result := AddFuncItem(FuncItemDescription, FuncCmdProc, ShortcutKey, MenuChecked);
  SetLength(FFuncItemsNames, Result + 1);
  FFuncItemsNames[Result] := FuncItemName;
end;

// *****************************************************************************
// Purpose: Registers a separator line in the Notepad++ plugin menu and stores a
// generated placeholder ID for index alignment.
// *****************************************************************************
function TESPHomePlugin.AddPluginMenuSeparator: Integer;
begin
  // Separators still occupy function indexes, so they need placeholder IDs.
  Result := AddFuncItem(csMenuEmptyLine, nil, nil);
  SetLength(FFuncItemsNames, Result + 1);
  FFuncItemsNames[Result] := Format('Sep$%2d', [Result]);
end;

// *****************************************************************************
// Purpose: Handles the Notepad++ ready notification. Initializes toolbar state,
// creates the project docking form, restores its visibility, and refreshes
// menu/title state.
// *****************************************************************************
procedure TESPHomePlugin.DoNppnReady;
begin
  inherited;
  // Re-enable normal notification handling after plugin-driven file opens finish.
  // From this point on, Notepad++ document notifications can update the UI.
  OperationsOngoing := False;

  // Capture Notepad++ toolbar button templates before rebuilding the toolbar.
  RegisterToolbarConfiguration;

  RefreshToolbarConfiguration;


//  The initial dock position is saved in %AppData%\Notepad++\config.xml as a GUIConfig element with the DockingManager attribute; e.g.,
//   {
//       <GUIConfig name="DockingManager" leftWidth="200" rightWidth="582" topHeight="200" bottomHeight="200">
//           <PluginDlg pluginName="HelloWorld.dll" id="2" curr="1" prev="-1" isVisible="yes" />
//           <ActiveTabs cont="0" activeTab="-1" />
//           <!-- ... -->
//       </GUIConfig>
//   }
//  You should delete this between launches when testing different dlgID.

  // Create the docked project window after Notepad++ is fully initialized.
  FormProjects := TFormProjects.Create(Plugin, GetIndexFromFuncItemName(fiShowHidePrjWin));

  // Restore the last saved visibility of the project window.
  if ConfigIniFile.ReadBool(csSectionGeneral, csKeyProjectWindow, True) then
    FormProjects.Show
  else
    FormProjects.Hide;

  CheckMenuItem(GetIndexFromFuncItemName(fiShowHidePrjWin), FormProjects.Visible);
  EnableMenuItem(GetIndexFromFuncItemName(fiConfigToolbar), Plugin.IsNppMinVersion(8, 0));

  RefreshNppTitle;
  RefreshPluginMenu;
end;

// *****************************************************************************
// Purpose: Handles plugin shutdown by terminating active ESPHome consoles and
// freeing global lists, configuration objects, forms, toolbar icons, and
// resources.
// *****************************************************************************
procedure TESPHomePlugin.DoNppnShutdown;
begin
  // Stop a still-running ESPHome console before unloading the plugin.
  if IsPIDRunning(LastConsolePID) then
    KillProcessTree(LastConsolePID);
  // Release shared objects in reverse startup order.
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

// *****************************************************************************
// Purpose: Refreshes dynamic menu captions after Notepad++ shortcut changes.
// *****************************************************************************
procedure TESPHomePlugin.DoNppnShortcutRemapped;
begin
  RefreshNppTitle;
  RefreshPluginMenu;
end;

// *****************************************************************************
// Purpose: Receives the Notepad++ toolbar creation/modification notification
// and prepares the plugin toolbar button model and icon handles.
// *****************************************************************************
procedure TESPHomePlugin.DoNppnToolbarModification;
begin
  inherited;
  InitializeToolbarConfiguration;
end;

// *****************************************************************************
// Purpose: Reacts to Notepad++ dark mode changes by updating plugin forms,
// toolbar images, and command enabled state.
// *****************************************************************************
procedure TESPHomePlugin.DoNppnDarkModeChanged;
begin
  if Assigned(FormProjects) then
    FormProjects.ToggleDarkMode;

  RefreshToolbarConfiguration;
  RefreshPluginMenu;
end;

// *****************************************************************************
// Purpose: Synchronizes the project window, title, and menu state when the
// active Notepad++ document changes.
// *****************************************************************************
procedure TESPHomePlugin.DoNppnBufferActivated;
begin
  // Ignore notifications caused by plugin-controlled file open/save batches.
  if not OperationsOngoing then
  begin
    if Assigned(FormProjects) then
      FormProjects.CurrentDocumentChanged;
    RefreshNppTitle;
    RefreshPluginMenu;
  end;
end;

// *****************************************************************************
// Purpose: Refreshes title and menu state after Notepad++ opens a file.
// *****************************************************************************
procedure TESPHomePlugin.DoNppnFileOpened;
begin
  // Ignore notifications caused by plugin-controlled file open/save batches.
  if not OperationsOngoing then
  begin
    RefreshNppTitle;
    RefreshPluginMenu;
  end;
end;

// *****************************************************************************
// Purpose: Refreshes UI state after a save and reloads templates when the
// plugin template XML file has been saved.
// *****************************************************************************
procedure TESPHomePlugin.DoNppnFileSaved;

begin
  // Ignore notifications caused by plugin-controlled file open/save batches.
  if not OperationsOngoing then
  begin
    RefreshNppTitle;
    RefreshPluginMenu;
  end;
  // Saving the template XML should immediately refresh the template browser.
  if GetFullPathFromBufferId(SCNotification.nmhdr.idFrom) = TemplateFile then
    if Assigned(FormProjects) then
      FormProjects.ReloadAndRefreshTemplates;
end;

// *****************************************************************************
// Purpose: Rebuilds toolbar configuration after Notepad++ changes its toolbar
// icon set. The refresh runs asynchronously to let Notepad++ finish its update.
// *****************************************************************************
procedure TESPHomePlugin.DoNppToolbarIconsetChanged;
begin
  // Rebuild shortly after Notepad++ swaps its internal image lists.
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

// ============================================================================
// Project Dependencies and File Saving
// ============================================================================

// *****************************************************************************
// Purpose: Lets the user add one or more dependency files to the current
// project and persists the updated dependency list.
// *****************************************************************************
procedure TESPHomePlugin.DependencyAdd;
var
  Index: Integer;
  FileOpen: TFileOpenDialog;
  FileTypeItem: TFileTypeItem;
begin

  // Dependency changes always belong to the current project.
  // Commands that need project context use one shared warning path.
  if not Assigned(ProjectList.Current) then
    Exit;

  // Configure a strict file dialog so only existing ESPHome YAML files are selectable.
  FileOpen := TFileOpenDialog.Create(nil);
  try
    FileOpen.DefaultExtension := '.yaml';
    FileOpen.Title := Format(rsDependencyAddFileOpenTitle, [ProjectList.Current.FriendlyName]);
    // Allow multi-select because ESPHome projects often use several companion files.
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
      // Add selected files to the de-duplicating dependency list.
      ProjectList.Current.OptionDependencies.AddStrings(FileOpen.Files);
      // The main project YAML is implicit and should not be stored as a dependency.
      Index := ProjectList.Current.OptionDependencies.IndexOf(ProjectList.Current.FileName);
      if Index >= 0 then
        ProjectList.Current.OptionDependencies.Delete(Index);
      ProjectList.Current.SaveOptionDependencies;
      RefreshProjectList;
      if Assigned(FormProjects) then
        FormProjects.CurrentDocumentChanged;
    end;
  except
    FileOpen.Free;
  end;
end;

resourcestring
  rsKnownDependencyRemoval = 'Dependency file "%s" is going to be removed from the "%s" project.';
  rsKnownDependencyRemoval2 = 'Are you sure?';

// *****************************************************************************
// Purpose: Removes a dependency file from the current project after user
// confirmation, then refreshes the project window.
// *****************************************************************************
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
      // Find the dependency by full path so duplicate display names are not ambiguous.
      I := ProjectList.Current.OptionDependencies.IndexOf(DepFile);
      if I >= 0 then
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

// *****************************************************************************
// Purpose: Saves the current project's main YAML file in Notepad++.
// *****************************************************************************
procedure TESPHomePlugin.SaveProject;
begin
  if Assigned(ProjectList.Current) then
    // Delegate saving to Notepad++ so buffer state and UI indicators stay consistent.
    SaveFile(ProjectList.Current.FileName);
end;

// *****************************************************************************
// Purpose: Saves the current project file and every configured dependency file
// in Notepad++.
// *****************************************************************************
procedure TESPHomePlugin.SaveProjectAndDependencies;
var
  S: string;
begin
  if Assigned(ProjectList.Current) then
  begin
    // Delegate saving to Notepad++ so buffer state and UI indicators stay consistent.
    SaveFile(ProjectList.Current.FileName);
    // Dependencies are saved only when the selected auto-save policy asks for them.
    for S in ProjectList.Current.OptionDependencies do
      SaveFile(S);
  end;
end;

// ============================================================================
// Construction, Lookup, and Toolbar Configuration
// ============================================================================

// *****************************************************************************
// Purpose: Returns a pointer to a toolbar button record by array index, or nil
// when the requested index is outside the current toolbar model.
// *****************************************************************************
function TESPHomePlugin.GetToolbarButton(Index: Integer): PToolbarButton;
begin
  Result := nil;
  if (Index >= 0) and (Index < Length(FToolbarButtons)) then
    Result := @FToolbarButtons[Index];
end;

// *****************************************************************************
// Purpose: Returns the number of toolbar buttons managed by the plugin.
// *****************************************************************************
function TESPHomePlugin.GetToolbarButtonCount: Integer;
begin
  Result := Length(FToolbarButtons);
end;

// *****************************************************************************
// Purpose: Creates the plugin instance, prepares image resources, sets the
// plugin name, and registers all Notepad++ menu commands and shortcuts.
// *****************************************************************************
constructor TESPHomePlugin.Create;
begin
  inherited Create;

  // Load the design-time image collections used by toolbar and window icons.
  Resources := TResources.Create(nil);
  // Generate the alternate icon collection used by the current theme logic.
  PopulateBlackImageCollection(Resources.StandardImages, Resources.LightModeImages);

  // Suppress document-change refresh handlers while opening a batch of files.
  OperationsOngoing := True;
  Plugin := Self;
  PluginName := csPluginName;

  // Register menu entries in the exact order they should appear in Notepad++.
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

// *****************************************************************************
// Purpose: Receives Notepad++ host data and initializes plugin-wide file paths,
// configuration storage, project list, and template list.
// *****************************************************************************
procedure TESPHomePlugin.SetInfo(NppData: TNppData);
begin
  inherited SetInfo(NppData);
  // Resolve ESPHome once during startup; validation happens when commands run.
  ESPHomeFile := ExpandFileName(FindFileInPath('esphome.exe'));
  // Keep plugin settings beside the Notepad++ plugin configuration directory.
  ConfigIniFile := TIniFile.Create(TPath.Combine(Plugin.GetPluginConfigDir, ChangeFileExt(Plugin.GetName, '.ini')));
  TemplateFile := TPath.Combine(Plugin.GetPluginConfigDir, ChangeFileExt(Plugin.GetName, '.xml'));
  // Shared project/template lists are initialized after host paths are known.
  ProjectList := TProjectList.Create;
  TemplateList := TTemplateList.Create(TemplateFile);
end;

// *****************************************************************************
// Purpose: Resolves the plugin's stable function ID from a Notepad++ function
// item index.
// *****************************************************************************
function TESPHomePlugin.GetFuncItemIdFromIndex(const Index: Integer): string;
begin
  Result := '';
  // Guard against stale or invalid Notepad++ indexes.
  if (Length(FFuncItemsNames) > Index) and (Index >= 0) then
    Result := FFuncItemsNames[Index];
end;

// *****************************************************************************
// Purpose: Finds the Notepad++ function item index associated with a stable
// plugin function ID.
// *****************************************************************************
function TESPHomePlugin.GetIndexFromFuncItemName(const FuncItemName: string): Integer;
var
  Index: Integer;
begin
  Result := -1;
  // Stable IDs are compared case-insensitively because they are internal tokens.
  for Index := 0 to High(FFuncItemsNames) do
    if CompareText(FFuncItemsNames[Index], FuncItemName) = 0 then
    begin
      Result := Index;
      Exit;
    end;
end;

// *****************************************************************************
// Purpose: Resolves the Notepad++ command ID for a stable plugin function ID.
// *****************************************************************************
function TESPHomePlugin.GetCmdIdFromFuncItemName(const FuncItemName: string): Integer;
begin
  Result := CmdIdFromMenuItemIdx(GetIndexFromFuncItemName(FuncItemName));
end;

// *****************************************************************************
// Purpose: Builds the default toolbar configuration and, unless requested
// otherwise, reads and validates the persisted user toolbar configuration.
// *****************************************************************************
function TESPHomePlugin.GetToolbarConfiguration(const ADefault: Boolean = False): string;
var
  Regex: TRegEx;
  I, Index, Count: Integer;
  DefaultConfig: string;
begin
  Index := 0;
  DefaultConfig := '';
  // Only functions with matching image names participate in toolbar configuration.
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
    // Reject malformed saved strings and fall back to a complete default toolbar.
    Result := ConfigIniFile.ReadString(csSectionGeneral, csKeyToolbarConfig, DefaultConfig);
    Regex := TRegEx.Create(Format('^(?:\d+:[01];){%d}$', [DefaultConfig.CountChar(':')]));
    if not Regex.IsMatch(Result) then
      Result := DefaultConfig;
  end;
end;

// *****************************************************************************
// Purpose: Creates the in-memory toolbar button model and registers the light,
// dark, and low-resolution toolbar icons with Notepad++.
// *****************************************************************************
procedure TESPHomePlugin.InitializeToolbarConfiguration;
var
  Bitmap: TBitmap;
  FuncItemID: string;
  Index, Count, Sequence: Integer;
begin
  // Custom toolbar APIs are only available in Notepad++ 8 and newer.
  if not IsNppMinVersion(8, 0) then
    Exit;

  // Sequence is compacted to toolbar-capable functions only.
  Sequence := 0;
  // Only functions with matching image names participate in toolbar configuration.
  GetFuncsArray(Count);
  for Index := 0 to Count - 1 do
  begin
    FuncItemId := GetFuncItemIdFromIndex(Index);
    if Resources.StandardImages.GetIndexByName(FuncItemID) >= 0 then
    begin
      // Create one toolbar model entry for each command that has an image resource.
      SetLength(FToolbarButtons, Sequence + 1);
      FillChar(FToolbarButtons[Sequence], SizeOf(FToolbarButtons[Sequence]), 0);
      FToolbarButtons[Sequence].Sequence := Sequence;
      FToolbarButtons[Sequence].CmdID := CmdIdFromMenuItemIdx(Index);
      FToolbarButtons[Sequence].Visible := False;
      FToolbarButtons[Sequence].Enabled := True;
      FToolbarButtons[Sequence].FuncItemID := FuncItemID;
      FToolbarButtons[Sequence].Index := Index;
      // Legacy toolbar bitmap used by older Notepad++ toolbar paths.
      Bitmap := Resources.LowResImages.GetBitmap(FuncItemID, 20, 20);
      FToolbarButtons[Sequence].IconData.ToolbarBmp := HBITMAP(CopyImage(Bitmap.Handle, IMAGE_BITMAP, 0, 0, LR_CREATEDIBSECTION));
      Bitmap.Free;
      // High-resolution icons are registered for normal and dark-mode toolbar use.
      Bitmap := Resources.StandardImages.GetBitmap(FuncItemID, 40, 40);
      FToolbarButtons[Sequence].IconData.ToolbarIconDarkMode := CreateIconFromBitmap(Bitmap);
      ConvertBitmapToBlack(Bitmap);
      FToolbarButtons[Sequence].IconData.ToolbarIcon := CreateIconFromBitmap(Bitmap);
      Bitmap.Free;
      // Hand the icon handles to Notepad++ for the command ID just registered.
      AddToolbarIcon(FToolbarButtons[Sequence].CmdID, FToolbarButtons[Sequence].IconData);
      Inc(Sequence);
    end;
  end;
end;

// *****************************************************************************
// Purpose: Reads the native Notepad++ TBBUTTON records for plugin commands so
// they can later be deleted, reinserted, reordered, or restyled safely.
// *****************************************************************************
procedure TESPHomePlugin.RegisterToolbarConfiguration;
var
  Index: Integer;
  ToolbarHandle: HWND;
  ButtonIndex: LRESULT;
begin
  // Custom toolbar APIs are only available in Notepad++ 8 and newer.
  if not IsNppMinVersion(8, 0) then
    Exit;

  // Work directly with the native Notepad++ toolbar when it is available.
  ToolbarHandle := GetToolbarHandle;

  if ToolbarHandle = 0 then
    Exit;

  // Release each GDI handle exactly once before clearing the stored values.
  for Index := 0 to High(FToolbarButtons) do
  begin
    // Cache the current native button as a template for later reconstruction.
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
// *****************************************************************************
// Purpose: Rebuilds the native Notepad++ toolbar from the saved logical order,
// visibility, enabled state, and current image lists.
// *****************************************************************************
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
  // Custom toolbar APIs are only available in Notepad++ 8 and newer.
  if not IsNppMinVersion(8, 0) then
    Exit;

  // Work directly with the native Notepad++ toolbar when it is available.
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

// *****************************************************************************
// Purpose: Releases all GDI bitmap and icon handles owned by the plugin toolbar
// button model, then clears the stored handle fields.
// *****************************************************************************
procedure TESPHomePlugin.FreeToolbarResources;
var
  Index: Integer;
begin
  // Custom toolbar APIs are only available in Notepad++ 8 and newer.
  if not IsNppMinVersion(8, 0) then
    Exit;
  // Release each GDI handle exactly once before clearing the stored values.
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

// *****************************************************************************
// Purpose: Enables or disables a plugin toolbar button by Notepad++ menu item
// index and mirrors the state into the toolbar button model.
// *****************************************************************************
procedure TESPHomePlugin.EnableToolbarItem(MenuItemIdx: Integer; State: Boolean);
var
  CmdID: Integer;
  ButtonIndex: LRESULT;
  ButtonState: LRESULT;
  ToolbarHandle: HWND;

// *****************************************************************************
// Purpose: Finds the toolbar model entry whose command ID matches the command
// currently being enabled or disabled.
// *****************************************************************************
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
  // Toolbar state changes are applied to the native control and mirrored locally.
  ToolbarHandle := Plugin.GetToolbarHandle;
  CmdID := CmdIdFromMenuItemIdx(MenuItemIdx);

  if (ToolbarHandle = 0) or (CmdID < 0) then
    Exit;

  ButtonIndex := SendMessage(ToolbarHandle, TB_COMMANDTOINDEX, WPARAM(CmdID), 0);
  if ButtonIndex < 0 then
    Exit;

  // Preserve unrelated toolbar state bits while toggling only the enabled flag.
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

// ============================================================================
// UI Refresh and Validation Helpers
// ============================================================================

// *****************************************************************************
// Purpose: Placeholder for future logic that refreshes only the current project
// state without rebuilding the whole project list.
// *****************************************************************************
procedure TESPHomePlugin.RefreshCurrentProject;
begin
end;

// *****************************************************************************
// Purpose: Refreshes the docked project list, Notepad++ window title, and
// plugin menu state after project data changes.
// *****************************************************************************
procedure TESPHomePlugin.RefreshProjectList;
begin
  // The docked window owns the visible project tree/list.
  if Assigned(FormProjects) then
    FormProjects.RefreshProjectsList;
  RefreshNppTitle;
  RefreshPluginMenu;
end;

// *****************************************************************************
// Purpose: Appends the current ESPHome project name to the Notepad++ main
// window title, replacing any previous plugin-added project suffix.
// *****************************************************************************
procedure TESPHomePlugin.RefreshNppTitle;
const
  SepChar = '|';
var
  Index: Integer;
  Title: string;
begin
  // Strip the old plugin suffix before adding the current project name again.
  Title := GetNppWindowTitle;
  Index := Pos(SepChar, Title);
  if Index > 0 then
    Title := Trim(Copy(Title, 1, Index - 1));
  if Assigned(ProjectList.Current) then
    Title := Format('%s %s ESPHome Project: %s', [Title, SepChar, ProjectList.Current.FriendlyName]);
  SetWindowText(NppData.NppHandle, PChar(Title));
end;

// *****************************************************************************
// Purpose: Updates dynamic menu text, shortcut hints, menu enabled state, and
// toolbar enabled state according to whether a project is selected.
// *****************************************************************************
procedure TESPHomePlugin.RefreshPluginMenu;
var
  Text: string;
  PluginMenu: HMENU;
  ShortcutKey: TShortcutKey;
  PFunc: PFuncItem;
  ProjectAssigned: Boolean;

// *****************************************************************************
// Purpose: Resolves a stable function identifier and updates the matching menu
// and toolbar enabled state.
// *****************************************************************************
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
  // Most actions are disabled until a project is selected.
  ProjectAssigned := Assigned(ProjectList.Current);

  PluginMenu := HMENU(SendMessage(NppData.NppHandle, NPPM_GETMENUHANDLE, NPPPLUGINMENU, 0));
  if PluginMenu <> 0 then
  begin
    // The configure command caption includes the active project when available.
    if ProjectAssigned then
      Text := Format(miProjectConfigureEx, [ProjectList.Current.FriendlyName])
    else
      Text := miProjectConfigure;
    PFunc := GetFuncByIndex(GetIndexFromFuncItemName(fiProjectConfigure));
    if Assigned(PFunc) then
    begin
      // Preserve Notepad++'s current shortcut text even after user remapping.
      if SendMessage(NppData.NppHandle, NPPM_GETSHORTCUTBYCMDID, PFunc^.CmdID, LPARAM(@ShortcutKey)) <> 0 then
        Text := Text + #09 + ShortcutToString(@ShortcutKey);
      if ModifyMenu(PluginMenu, PFunc^.CmdID, MF_BYCOMMAND or MF_STRING, PFunc^.CmdID, PChar(Text)) then
        DrawMenuBar(NppData.NppHandle);
    end;
  end;

  // Project-specific commands are enabled or disabled as a group.
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

// *****************************************************************************
// Purpose: Verifies that esphome.exe was found and shows a user-facing error
// dialog when ESPHome is not installed or not available in PATH.
// *****************************************************************************
function TESPHomePlugin.CheckESPHome: Boolean;
begin
  Result := False;
  // Show actionable guidance instead of failing silently when ESPHome is missing.
  if not FileExists(ESPHomeFile) then
    TD(rsInvalidESPHomeInstallation).Text(rsInvalidESPHomeInstallation2).Text(rsInvalidESPHomeInstallation3).WindowCaption(rsMessageBoxError).Hypertext.SetFlags
      ([tfAllowDialogCancellation]).Error.OK.Execute(nil)
  else
    Result := True;
end;

// *****************************************************************************
// Purpose: Verifies that a current project is selected and shows a user-facing
// warning when project-specific commands cannot run.
// *****************************************************************************
function TESPHomePlugin.CheckCurrentProject: Boolean;
begin
  Result := False;
  // Dependency changes always belong to the current project.
  // Commands that need project context use one shared warning path.
  if not Assigned(ProjectList.Current) then
    TD(rsNoProjectSelected).Text(rsNoProjectSelected2).WindowCaption(rsMessageBoxError).SetFlags([tfAllowDialogCancellation]).Warning.OK.Execute(nil)
  else
    Result := True;
end;

end.


