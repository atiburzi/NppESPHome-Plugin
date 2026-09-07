// Main Notepad++ plugin unit for NppESPHome.
// Registers the plugin commands, manages Notepad++ events, toolbar integration,
// project commands, and the project docking window lifecycle.
unit NppESPHome.Plugin;

interface

uses
  Winapi.Windows, Winapi.CommCtrl, System.SysUtils, System.Classes, Vcl.Graphics, Npp.Api, Npp.Plugin, Npp.Commands, Npp.Toolbar, Npp.Vcl.Forms, Npp.Vcl.Docking, NppESPHome.Shared,
  Vcl.ImageCollection, Vcl.BaseImageCollection;

const
  csPluginName = 'NppESPHome';

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
  fiShowHideConsole = 'console';
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
  miShowHideConsole = 'Hide/Show ESPHome console window';
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
  // Main plugin class. Handles Notepad++ lifecycle notifications, ESPHome
  // project commands, toolbar customization, menu state, and project window
  // synchronization.

  TESPHomePlugin = class(TNppPlugin)
  private
    FMenu: TNppCommands;
    FToolbar: TNppToolbar;

  public
    OperationsOngoing: Boolean; // True while plugin-driven file operations should not trigger UI refresh loops

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
    procedure ShowHideConsole;
    procedure ConfigToolbar;
    procedure AboutWindow;


  protected

    function CreateToolbarIcons(const Entry: TNppMenuEntry; out IconData: TToolbarIconsWithDarkMode): Boolean;
    function CreateDisabledToolbarIcon(SourceIcon: HICON;
      Width, Height: Integer): HICON;
    function ReadToolbarConfiguration(const DefaultValue: string): string;
    procedure WriteToolbarConfiguration(const Value: string);

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

  public
    constructor Create; override;
    destructor Destroy; override;
    procedure SetInfo(NppData: TNppData); override;

    procedure DependencyAdd;
    procedure DependencyRemove(const DepFile: string);

    procedure RefreshCurrentProject;
    procedure RefreshProjectList;

    procedure RefreshNppTitle;
    procedure RefreshPluginMenu;

    function CheckESPHome: Boolean;
    function CheckCurrentProject: Boolean;

    property Commands: TNppCommands read FMenu;
    property Toolbar: TNppToolbar read FToolbar;

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
  NppESPHome.FormToolbar, NppESPHome.FormAbout, NppESPHome.FormProjects,
  NppESPHome.FormConsole, NppESPHome.ConPty, IniFiles,
  TDMB, Vcl.Forms, Vcl.Dialogs,
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
// Purpose: Forwards the Notepad++ command callback to the docked console
// visibility toggle.
// *****************************************************************************
procedure _ShowHideConsole; cdecl;
begin
  Plugin.ShowHideConsole;
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
  CommandStr: array [scRun .. scCleanAll] of string = ('Run', 'Compile', 'Upload', 'Logs', 'Clean', 'Clean-All');
var
  ConsoleHandle: HWND;
  CommandLine, Switch, Device, ConsoleTitle: string;
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

    CommandLine := Trim(Format('%s %s %s "%s"', [CommandLine, LowerCase(CommandStr[Command]), Switch, ExpandFileName(FileName)]));

    // Optional solo mode keeps only one ESPHome console alive at a time.
    if GetOption(csKeyConsoleSoloMode, False) then
      if IsPIDRunning(LastConsolePID) then
        KillProcessTree(LastConsolePID);

    // Prefer the embedded pseudoconsole. If Windows does not provide ConPTY,
    // or session startup fails, the existing external console remains the
    // compatibility fallback.
    if Assigned(FormConsole) and FormConsole.Visible and TConPtySession.IsSupported then
    begin
      try
        ConsoleTitle := Format('%s "%S"', [CommandStr[Command], ProjectList.Current.FriendlyName]);

        FormConsole.StartCommand(
          // Integrated sessions always terminate cmd.exe with ESPHome and do
          // not need the external console's conditional "pause" behavior.
          Format('"%s" /c "%s"',
            [GetEnvironmentVariable('ComSpec'), CommandLine]),
          ExtractFilePath(ProjectList.Current.FileName), ConsoleTitle);

        Plugin.Commands.SetChecked(fiShowHideConsole, True);
        ConfigIniFile.WriteBool(csSectionGeneral, csKeyConsoleWindow, True);
        Exit;
      except
        on E: Exception do
          OutputDebugString(PChar('NppESPHome ConPTY fallback: ' + E.Message));
      end;
    end;

    // Reaching this point means the embedded console was disabled,
    // unsupported, or failed to start. Use the external-console fallback.
    // Wrap the command for cmd.exe, choosing whether the console closes automatically.
    if GetOption(csKeyConsoleAutoClose, True) then
      CommandLine := Format('/c "%s" || pause', [CommandLine])
    else
      CommandLine := Format('/k "%s"', [CommandLine]);

    case Command of
      scRun: ConsoleTitle := rsConsoleCommandRun;
      scCompile: ConsoleTitle := rsConsoleCommandCompile;
      scUpload: ConsoleTitle := rsConsoleCommandUpload;
      scLogs: ConsoleTitle := rsConsoleCommandLogs;
      scClean: ConsoleTitle := rsConsoleCommandClean;
      scCleanAll: ConsoleTitle := rsConsoleCommandCleanAll;
    end;
    ConsoleTitle := Format('%s - [%s]',
      [ConsoleTitle, ProjectList.Current.FriendlyName]);

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
        Title := ConsoleTitle;
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
    FMenu.SetChecked(fiShowHidePrjWin, FormProjects.Visible);
    ConfigIniFile.WriteBool(csSectionGeneral, csKeyProjectWindow, FormProjects.Visible);
  end;
end;

// *****************************************************************************
// Purpose: Toggles the docked ESPHome console without terminating its active
// pseudoconsole session.
// *****************************************************************************
procedure TESPHomePlugin.ShowHideConsole;
begin
  if Assigned(FormConsole) then
  begin
    if FormConsole.Visible then
      FormConsole.Hide
    else
      FormConsole.Show;
    FMenu.SetChecked(fiShowHideConsole, FormConsole.Visible);
    ConfigIniFile.WriteBool(csSectionGeneral, csKeyConsoleWindow,
      FormConsole.Visible);
  end;
end;
// *****************************************************************************
// Purpose: Opens the toolbar customization dialog.
// *****************************************************************************
procedure TESPHomePlugin.ConfigToolbar;
begin
  if Assigned(FormToolbar) then
    Exit;
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
  FToolbar.CaptureNativeButtons;
  FToolbar.Refresh;


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
  FormProjects := TFormProjects.Create(Plugin, FMenu.IndexOf(fiShowHidePrjWin));
  FormConsole := TFormConsole.Create(Plugin,
    FMenu.IndexOf(fiShowHideConsole));

  // Restore the last saved visibility of the project window.
  if ConfigIniFile.ReadBool(csSectionGeneral, csKeyProjectWindow, True) then
    FormProjects.Show
  else
    FormProjects.Hide;

  FMenu.SetChecked(fiShowHidePrjWin, FormProjects.Visible);
  if ConfigIniFile.ReadBool(csSectionGeneral, csKeyConsoleWindow, False) then
    FormConsole.Show
  else
    FormConsole.Hide;
  FMenu.SetChecked(fiShowHideConsole, FormConsole.Visible);
  FMenu.SetEnabled(fiConfigToolbar, Plugin.IsNppMinVersion(8, 0));

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
  // Stop worker threads and unregister docked forms before releasing the
  // configuration and project objects they reference.
  FreeAndNil(FormToolbar);
  FreeAndNil(FormConsole);
  FreeAndNil(FormProjects);
  // Release shared objects in reverse startup order.
  FreeAndNil(TemplateList);
  FreeAndNil(ProjectList);
  FreeAndNil(ConfigIniFile);
  FreeAndNil(FToolbar);
  FreeAndNil(FMenu);
  FreeAndNil(Resources);
  Plugin := nil;
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
  FToolbar.Initialize;
end;

// *****************************************************************************
// Purpose: Reacts to Notepad++ dark mode changes by updating plugin forms,
// toolbar images, and command enabled state.
// *****************************************************************************
procedure TESPHomePlugin.DoNppnDarkModeChanged;
begin
  inherited;
  if Assigned(FormProjects) then
    FormProjects.ToggleDarkMode;
  if Assigned(FormConsole) then
    FormConsole.ToggleDarkMode;
  if Assigned(FormToolbar) then
    FormToolbar.ToggleDarkMode;

  FToolbar.Refresh;
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
  // Let Notepad++ complete its image-list update, then rebuild from the main
  // VCL thread. The global guard prevents a queued refresh after shutdown.
  TThread.ForceQueue(nil,
    procedure
    begin
      if Assigned(Plugin) and not Plugin.IsShuttingDown then
      begin
        Plugin.FToolbar.Refresh;
        if Assigned(FormToolbar) then
          FormToolbar.ToggleDarkMode;
      end;
    end);
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
// Purpose: Creates the plugin instance, sets its name, and registers all
// Notepad++ menu commands and shortcuts without requiring host services.
// *****************************************************************************
constructor TESPHomePlugin.Create;
begin
  inherited Create;
  try
    FMenu := TNppCommands.Create(Self);
    FToolbar := TNppToolbar.Create(Self, FMenu, CreateToolbarIcons,
      CreateDisabledToolbarIcon, ReadToolbarConfiguration,
      WriteToolbarConfiguration);

    // Suppress document-change refresh handlers while opening a batch of files.
    OperationsOngoing := True;
    PluginName := csPluginName;

    // Register menu entries in the exact order they should appear in Notepad++.
    FMenu.AddCommand(fiProjectAdd, miProjectAdd, _ProjectAdd);
    FMenu.AddCommand(fiProjectRemove, miProjectRemove, _ProjectRemove);
    FMenu.AddCommand(fiProjectSelect, miProjectSelect, _ProjectSelect,
      MakeShortcutKey(True, True, False, $79));
    FMenu.AddSeparator('sep.project.select');
    FMenu.AddCommand(fiProjectConfigure, miProjectConfigure,
      _ProjectConfigure, MakeShortcutKey(True, False, False, $79));
    FMenu.AddSeparator('sep.project.configure');
    FMenu.AddCommand(fiProjectOpenFiles, miProjectOpenFiles,
      _ProjectOpenFiles);
    FMenu.AddSeparator('sep.project.commands');
    FMenu.AddCommand(fiCommandRun, miCommandRun, _CommandRun,
      MakeShortcutKey(False, False, False, $78));
    FMenu.AddCommand(fiCommandCompile, miCommandCompile, _CommandCompile,
      MakeShortcutKey(True, False, False, $78));
    FMenu.AddCommand(fiCommandUpload, miCommandUpload, _CommandUpload,
      MakeShortcutKey(False, False, True, $78));
    FMenu.AddCommand(fiCommandLogs, miCommandLogs, _CommandLogs);
    FMenu.AddCommand(fiCommandClean, miCommandClean, _CommandClean);
    FMenu.AddCommand(fiCommandCleanAll, miCommandCleanAll, _CommandCleanAll);
    FMenu.AddSeparator('sep.commands.start');
    FMenu.AddCommand(fiStartHelp, miStartHelp, _StartHelp,
      MakeShortcutKey(True, False, False, $70));
    FMenu.AddCommand(fiStartUpgrade, miStartUpgrade, _StartUpgrade);
    FMenu.AddSeparator('sep.start.shell');
    FMenu.AddCommand(fiStartTerminal, miStartTerminal, _StartTerminal);
    FMenu.AddCommand(fiStartExplorer, miStartExplorer, _StartExplorer);
    FMenu.AddSeparator('sep.start.windows');
    FMenu.AddCommand(fiShowHidePrjWin, miShowHidePrjWin, _ShowHidePrjWin);
    FMenu.AddCommand(fiShowHideConsole, miShowHideConsole, _ShowHideConsole);
    FMenu.AddSeparator('sep.windows.toolbar');
    FMenu.AddCommand(fiConfigToolbar, miConfigToolbar, _ConfigToolbar);
    FMenu.AddCommand(fiAboutWindow, miAboutWindow, _AboutWindow);

    // Publish the singleton only after construction has completed successfully.
    Plugin := Self;
  except
    Plugin := nil;
    raise;
  end;
end;

destructor TESPHomePlugin.Destroy;
begin
  FreeAndNil(FToolbar);
  FreeAndNil(FMenu);
  inherited;
end;

// *****************************************************************************
// Purpose: Receives Notepad++ host data and initializes plugin-wide file paths,
// configuration storage, project list, and template list.
// *****************************************************************************
procedure TESPHomePlugin.SetInfo(NppData: TNppData);
begin
  inherited SetInfo(NppData);
  try
    // Image collections use WIC and therefore belong to host initialization,
    // not to the lightweight construction performed by getName/getFuncsArray.
    Resources := TResources.Create(nil);
    PopulateBlackImageCollection(Resources.StandardImages,
      Resources.LightModeImages);
    // Resolve ESPHome once during startup; validation happens when commands run.
    ESPHomeFile := ExpandFileName(FindFileInPath('esphome.exe'));
    // Keep plugin settings beside the Notepad++ plugin configuration directory.
    ConfigIniFile := TIniFile.Create(TPath.Combine(GetPluginConfigDir,
      ChangeFileExt(GetName, '.ini')));
    TemplateFile := TPath.Combine(GetPluginConfigDir,
      ChangeFileExt(GetName, '.xml'));
    // Shared project/template lists are initialized after host paths are known.
    ProjectList := TProjectList.Create;
    TemplateList := TTemplateList.Create(TemplateFile);
  except
    FreeAndNil(TemplateList);
    FreeAndNil(ProjectList);
    FreeAndNil(ConfigIniFile);
    FreeAndNil(Resources);
    raise;
  end;
end;

function TESPHomePlugin.CreateToolbarIcons(const Entry: TNppMenuEntry;
  out IconData: TToolbarIconsWithDarkMode): Boolean;
var
  Bitmap: TBitmap;
begin
  FillChar(IconData, SizeOf(IconData), 0);
  Result := False;
  if not Assigned(Resources) or
     (Resources.StandardImages.GetIndexByName(Entry.Id) < 0) then
    Exit;

  try
    Bitmap := Resources.LowResImages.GetBitmap(Entry.Id, 20, 20);
    try
      IconData.ToolbarBmp := HBITMAP(CopyImage(Bitmap.Handle, IMAGE_BITMAP,
        0, 0, LR_CREATEDIBSECTION));
    finally
      Bitmap.Free;
    end;

    Bitmap := Resources.StandardImages.GetBitmap(Entry.Id, 40, 40);
    try
      IconData.ToolbarIconDarkMode := CreateIconFromBitmap(Bitmap);
      ConvertBitmapToBlack(Bitmap);
      IconData.ToolbarIcon := CreateIconFromBitmap(Bitmap);
    finally
      Bitmap.Free;
    end;
    Result := (IconData.ToolbarBmp <> 0) and
      (IconData.ToolbarIcon <> 0) and
      (IconData.ToolbarIconDarkMode <> 0);
  except
    if IconData.ToolbarBmp <> 0 then
      DeleteObject(IconData.ToolbarBmp);
    if IconData.ToolbarIcon <> 0 then
      DestroyIcon(IconData.ToolbarIcon);
    if IconData.ToolbarIconDarkMode <> 0 then
      DestroyIcon(IconData.ToolbarIconDarkMode);
    FillChar(IconData, SizeOf(IconData), 0);
    Result := False;
  end;
end;

function TESPHomePlugin.CreateDisabledToolbarIcon(SourceIcon: HICON;
  Width, Height: Integer): HICON;
var
  Bitmap: TBitmap;
  Icon: TIcon;
begin
  Result := 0;
  if (SourceIcon = 0) or (Width <= 0) or (Height <= 0) then
    Exit;
  Bitmap := TBitmap.Create;
  try
    Bitmap.PixelFormat := pf32bit;
    Bitmap.SetSize(Width, Height);
    Bitmap.Canvas.Brush.Color := clBtnFace;
    Bitmap.Canvas.FillRect(Rect(0, 0, Width, Height));
    Icon := TIcon.Create;
    try
      Icon.Handle := CopyIcon(SourceIcon);
      if Icon.Handle = 0 then
        Exit;
      Bitmap.Canvas.Draw(0, 0, Icon);
    finally
      Icon.Free;
    end;
    ConvertBitmapToDisabled(Bitmap);
    Result := CreateIconFromBitmap(Bitmap);
  finally
    Bitmap.Free;
  end;
end;

function TESPHomePlugin.ReadToolbarConfiguration(
  const DefaultValue: string): string;
begin
  if Assigned(ConfigIniFile) then
    Result := ConfigIniFile.ReadString(csSectionGeneral, csKeyToolbarConfig,
      DefaultValue)
  else
    Result := DefaultValue;
end;

procedure TESPHomePlugin.WriteToolbarConfiguration(const Value: string);
begin
  if Assigned(ConfigIniFile) then
    ConfigIniFile.WriteString(csSectionGeneral, csKeyToolbarConfig, Value);
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
  ProjectAssigned: Boolean;
begin
  ProjectAssigned := Assigned(ProjectList.Current);
  if ProjectAssigned then
    Text := Format(miProjectConfigureEx, [ProjectList.Current.FriendlyName])
  else
    Text := miProjectConfigure;
  FMenu.SetCaption(fiProjectConfigure, Text);

  // SetEnabled updates the native menu and the toolbar model through the
  // framework event, so application code has one source of truth.
  FMenu.SetEnabled(fiProjectConfigure, ProjectAssigned);
  FMenu.SetEnabled(fiProjectOpenFiles, ProjectAssigned);
  FMenu.SetEnabled(fiProjectRemove, ProjectAssigned);
  FMenu.SetEnabled(fiCommandRun, ProjectAssigned);
  FMenu.SetEnabled(fiCommandCompile, ProjectAssigned);
  FMenu.SetEnabled(fiCommandUpload, ProjectAssigned);
  FMenu.SetEnabled(fiCommandLogs, ProjectAssigned);
  FMenu.SetEnabled(fiCommandClean, ProjectAssigned);
  FMenu.SetEnabled(fiCommandCleanAll, ProjectAssigned);
  FMenu.SetEnabled(fiStartTerminal, ProjectAssigned);
  FMenu.SetEnabled(fiStartExplorer, ProjectAssigned);
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


