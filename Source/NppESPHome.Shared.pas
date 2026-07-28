// Central shared unit for the NppESPHome plugin.
// Contains core classes for managing ESPHome projects, templates, system utilities, and UI image manipulation.
unit NppESPHome.Shared;

interface

uses
  System.Classes, System.Generics.Collections, Winapi.Windows, Vcl.ComCtrls, Vcl.Graphics, Vcl.VirtualImage, Vcl.ImageCollection, Vcl.VirtualImageList, XMLIntf, IniFiles,
  System.UITypes, NppMessages;

const
  PingTimeout = 3 * 1000; // Timeout for pinging devices, in milliseconds

// Configuration constants for AutoSave behaviors
const
  ciAutoSaveProject = 1;
  ciAutoSaveProjectAndDeps = 2;
  ciAutoSaveAllFiles = 3;

// Configuration constants for the Console Window starting positions
  ciConsolePosDecidedByWindows = 0;
  ciConsolePosScreenCenter = 1;
  ciConsolePosTopLeftSide = 2;
  ciConsolePosBottomLeftSide = 3;
  ciConsolePosTopRightSide = 4;
  ciConsolePosBottomRightSide = 5;

// ESPHome log level constants
  ciLogLevelCritical = 0;
  ciLogLevelError = 1;
  ciLogLevelWarning = 2;
  ciLogLevelInfo = 3;
  ciLogLevelDebug = 4;
  ciLogLevelDefault = 5;

// Keys used in the INI configuration file to store user preferences
const
  csDefaultEmpty = '';
  csSectionGeneral = 'General';
  //csSectionProjects = 'Projects';
  csKeyCurrentProject = 'CurrentProject';
  //csKeyToolbarBitmap = 'ToolbarBitmap';
  //csKeyToolbarSequence = 'ToolbarSequence';
  csKeyToolbarConfig = 'ToolbarConfig';
  csKeyProjectWindow = 'ProjectWindow';
  csKeyProjectPanelSize = 'ProjectPanelSize';
  csKeyNppAutosave = 'NppAutosave';
  csKeyDependenciesCount = 'DependenciesCount';
  csKeyConsoleAutoClose = 'ConsoleAutoClose';
  csKeyConsoleSoloMode = 'ConsoleSoloMode';
  csKeyConsoleAlwaysOnTop = 'ConsoleAlwaysOnTop';
  csKeyConsoleStartingPosition = 'ConsoleStartingPosition';
  csKeyConsoleStartingMonitor = 'ConsoleStartingMonitor';
  csKeyESPHomeLogLevel = 'ESPHomeLogLevel';
  csKeyESPHomeTargetDevice = 'ESPHomeTargetDevice';
  csKeyESPHomeExtraParameters = 'ESPHomeExtraParameters';
  csKeyRunNoLogs = 'RunNoLogs';
  csKeyRunReset = 'RunReset';
  csKeyRunExtraParameters = 'RunExtraParameters';
  csKeyCompileGenerateOnly = 'CompileGenerateOnly';
  csKeyUploadExtraParameters = 'UploadExtraParameters';
  csKeyCompileExtraParameters = 'CompileExtraParameters';
  csKeyCleanExtraParameters = 'CleanExtraParameters';
  csKeyLogsReset = 'LogsReset';
  csKeyLogsExtraParameters = 'LogsExtraParameters';
  csKeyDependencyPrefix = 'Dependency';

// ESPHome commands indices
const
  scRun = 0;
  scCompile = 1;
  scUpload = 2;
  scLogs = 3;
  scClean = 4;
  scCleanAll = 5;

// UI Icon name mappings
const
  csIconNone = 'none';
  csIconWiFi = 'wifi';
  csIconSerial = 'serial';
  csIconWindow = 'window';

// Localized strings used for Console commands and UI Elements
resourcestring
  rsConsoleCommandRun = 'ESPHome - Run';
  rsConsoleCommandCompile = 'ESPHome - Compile';
  rsConsoleCommandUpload = 'ESPHome - Upload';
  rsConsoleCommandLogs = 'ESPHome - Show Logs';
  rsConsoleCommandClean = 'ESPHome - Clean';
  rsConsoleCommandCleanAll = 'ESPHome - Clean All';

resourcestring
  rsDefaultNone = 'None';
  rsDefaultWiFi = 'OTA';

resourcestring
  rsAnyCategory = '(Any Category)';

// Localized strings for messages, warnings, and dialog boxes
resourcestring
  rsMessageBoxError = 'ESPHome Plugin Error';
  rsMessageBoxWarning = 'ESPHome Plugin Warning';
  rsMessageBoxInfo = 'ESPHome Plugin Information';
  rsESPHomeDocURL = 'https://www.esphome.io/components/';

resourcestring
  rsInvalidESPHomeInstallation = 'No valid installation of ESPHome has been found on your system.' +
    #13#10'Please (re)install ESPHome following the instructions available on the following web page:' +
    #13#13#10'https://www.esphome.io/guides/installing_esphome/';
  rsNoProjectSelected = 'No ESPHome project is currently selected.' + #13#13#10'To use this command, please select the current project and try again.' +
    #13#10'You can select it through the menù command:' + #13#10'"Plugins" -> "NppESPHome" -> "Select Project..."';

resourcestring
  rsProjectAlreadyExists = 'Project "%s" already exists among the configured projects.';
  rsProjectAlreadyExists2 = 'Please select another project.';
  rsInvalidProjectFile = '"%s" is an invalid ESPHome project file.';
  rsInvalidProjectFile2 = 'Valid project files must contains at least a basic ESPHome configuration in the YAML file.';
  rsKnownProjectRemoval = 'Project "%s" is going to be removed from the projects known list.';
  rsKnownProjectRemoval2 = 'Project files are preserved.' + sLineBreak + sLineBreak + 'Are you sure?';
  rsConfirmOverwriteTemplates = 'You are going to overwrite your "NppESPHome.xml" templates file with the one available on GitHub.';
  rsConfirmOverwriteTemplates2 = 'Any modification done on the local XML will be lost.';
  rsConfirmOverwriteTemplates3 = 'Are you sure you want to continue?';
  rsConfirmOverwriteTemplates4 = 'I am really sure and I want to overwrite my local template file.';
  rsTemplatesXMLDownloaded = 'Default XML Templates file downloaded from GitHub.';
  rsConfirmExecuteCleanAll = 'Are you sure you want to run "esphome clean-all" command?';
  rsConfirmExecuteCleanAll2 = 'You are about to run "esphome clean-all" for project "%s".' + sLineBreak + sLineBreak +
    'This will remove all ESPHome build files, PlatformIO platforms and packages, ' +
    'and the PlatformIO core directory related to the selected project or working folder.' + sLineBreak + sLineBreak +
    'This is useful for a full rebuild, but the next compilation may take a long time.' + sLineBreak + sLineBreak + 'Do you want to continue?';

resourcestring
  rsTemplatesNotFound = 'No "NppESPHome.xml" templates file has been found on your system.';
  rsTemplatesNotFound2 = 'Do you want to download the default one from GitHub portal?';

type
  PProject = ^TProject;

  // Represents a single ESPHome project.
  // It handles parsing the YAML file to extract hardware properties and managing INI settings.
  TProject = class
  private
    FFileName: string;
    FName: string;
    FFriendlyName: string;
    FMicrocontroller: string;
    FBoard: string;
    FFramework: string;
    FHasWiFi: Boolean;
    FHasWebServer: Boolean;
    FValid: Boolean;
    FOptionDeps: TStringList; // List of file dependencies for this project
    function GetUIName: string;
    function GetFriendlyName: string;
    function GetDescription: string;
    function GetOptionDeps: TStringList;

  public
    constructor Create(const AFileName: string);
    property FileName: string read FFileName;
    property Name: string read FName;
    property UIName: string read GetUIName;
    property FriendlyName: string read GetFriendlyName;
    property Microcontroller: string read FMicrocontroller;
    property Board: string read FBoard;
    property Framework: string read FFramework;
    property HasWiFi: Boolean read FHasWiFi;
    property HasWebServer: Boolean read FHasWebServer;
    property Description: string read GetDescription;
    property IsValid: Boolean read FValid; // True if parsed successfully

    // Overloaded helper methods to read/write specific settings for this project to the global INI
    function GetOption(const Option: string; const Default: Boolean): Boolean; overload;
    function GetOption(const Option: string; const Default: Integer): Integer; overload;
    function GetOption(const Option: string; const Default: string): string; overload;

    procedure SetOption(const Option: string; const Value: Boolean); overload;
    procedure SetOption(const Option: string; const Value: Integer); overload;
    procedure SetOption(const Option: string; const Value: string); overload;

    property OptionDependencies: TStringList read GetOptionDeps;
    procedure LoadOptionDependencies;
    procedure SaveOptionDependencies;

  end;

  PProjectList = ^TProjectList;

  // Manages a collection of TProject objects.
  // Handles saving and loading the complete project list to/from the INI file.
  TProjectList = class(TObjectList<TProject>)
  private
    FCurrent: TProject; // The currently active project in the plugin
    procedure SetCurrent(P: TProject);
    function GetCurrent: TProject;
  public
    constructor Create;
    property Current: TProject read GetCurrent write SetCurrent;
    procedure LoadConfig;
    procedure SaveConfig;
    function GetProjectFromFileName(const FileName: string; const IncludeDeps: boolean = False): TProject;
    function GetProjectFromUIName(const UIName: string): TProject;
  end;

type
  PTemplate = ^TTemplate;

  // Represents a reusable YAML snippet (Template)
  TTemplate = record
    Name: string;
    Category: string;
    Description: string;
    OnlineHelp: string;
    YAML: string;
  end;

  PTemplateList = ^TTemplateList;

  // Manages a list of TTemplate objects, loaded from the NppESPHome.xml file
  TTemplateList = class(TList<TTemplate>)
  private
    FXMLDoc: IXMLDocument;
  public
    constructor Create(const AFileName: string);
    procedure Refresh;
    procedure RetrieveTemplates(S: TStrings; const Category: string; const Filter: string); overload;
    procedure RetrieveTemplates(S: TListItems; const Category: string; const Filter: string); overload;
    procedure RetrieveCategories(S: TStrings);
    function IndexOfName(const AName: string): NativeInt;
  end;

var
  // Global singletons for projects and templates
  ProjectList: TProjectList;
  TemplateList: TTemplateList;

var
  ESPHomeFile: string = '';
  TemplateFile: string = '';

var
  ConfigIniFile: TIniFile = nil; // Global INI file handler


// Global Utility Function Declarations

// File and Path Utilities
function FindFileInPath(const FileName: string): string;
procedure DownloadTemplateFileFromGitHub;
procedure GetEnvironmentVars(List: TStrings);
function IsValidHttpUrl(const AUrl: string): Boolean;


// Bitwise operations
function GetBit(const Value: Int64; BitPos: ShortInt): Boolean;
function SetBit(const Value: Int64; BitPos: ShortInt; State: Boolean): Int64;

// Shortcut management
function ShortcutToString(const S: PShortcutKey): string;
function MakeShortcutKey(const Ctrl, Alt, Shift: Boolean; const AKey: UCHAR): PShortcutKey;

// Process Management (Monitoring and Killing background tasks)
function IsPIDRunning(PID: DWORD): Boolean;
function KillProcessByPID(PID: DWORD): Boolean;
function KillProcessTree(PID: DWORD): Boolean;
function GetMainWindowHandleByPID(const TargetPID: DWORD; Timeout: Integer = 3000): HWND;

// UI & Image manipulation (Supporting dark mode, disabled states, etc.)
function CreateIconFromBitmap(Bitmap: Vcl.Graphics.TBitmap): HICON;
procedure ConvertBitmapToBlack(Bitmap: Vcl.Graphics.TBitmap);
procedure ConvertBitmapToDisabled(Bitmap: Vcl.Graphics.TBitmap);
procedure ReplaceBitmapHue(ABitmap: Vcl.Graphics.TBitmap; const SourceColor: TAlphaColor; const TargetColor: TAlphaColor; const HueTolerance: Single = 30 / 360;
  const MinSaturation: Single = 0.15);
procedure PopulateBlackImageCollection(ASource, ADest: TImageCollection);

procedure AssignWindowIcon(AIcon: TIcon);
procedure AssignImageResources(AVirtualImage: TVirtualImage); overload;
procedure AssignImageResources(AVirtualImageList: TVirtualImageList); overload;

implementation

uses
  NppESPHome.Plugin, SysUtils, System.StrUtils, Neslib.Yaml, TDMB, Vcl.Dialogs, Vcl.Controls, Xml.XMLDoc, System.IOUtils, System.NetEncoding, System.Net.HttpClient,
  System.Net.HttpClientComponent, System.Net.URLClient, TlHelp32, System.UIConsts;

// ============================================================================
// TProject Implementation
// ============================================================================

{
  Purpose: Initializes a new TProject instance by parsing the provided YAML file.
  It extracts critical ESPHome configurations (like device name, microcontroller type,
  board type, framework, and modules like WiFi or WebServer).
}
constructor TProject.Create(const AFileName: string);
var
  Index: Integer;
  Doc: IYamlDocument;
  Name: string;
  SubstitutionMap: TDictionary<string, string>; // Maps variable names to their substitution values

  // Local Helper: Replaces YAML variables (like $name or ${name}) with actual values
  // extracted from the 'substitutions' block of the YAML file.
  function Substitute(const Value: string): string;
  var
    Pair: TPair<string, string>;
    ResultString, Replacement: string;
  begin
    ResultString := Value;
    repeat
      Result := ResultString;
      // Iterate over the dictionary of substitutions
      for Pair in SubstitutionMap do
      begin
        // 1. Check for standard format: $variable
        Replacement := '$' + Pair.Key;
        if ContainsText(ResultString, Replacement) then
          ResultString := ResultString.Replace(Replacement, Pair.Value, [rfReplaceAll, rfIgnoreCase]);

        // 2. Check for bracketed format: ${variable}
        Replacement := '${' + Pair.Key + '}';
        if ContainsText(ResultString, Replacement) then
          ResultString := ResultString.Replace(Replacement, Pair.Value, [rfReplaceAll, rfIgnoreCase]);
      end;
    // Loop until the string stops changing. This handles nested substitutions
    // (e.g., $var1 resolving to a string that contains $var2).
    until ResultString = Result;
  end;

  // Local Helper: Scans the parsed YAML document for known microcontroller keys.
  function FindMicrocontroller: string;
  const
    // List of platforms officially supported by ESPHome
    Microcontrollers: array[0..6] of string = ('esp32', 'esp8266', 'bk72xx', 'ln882x', 'rp2040', 'rtl87xx', 'host');
  var
    Microcontroller: string;
  begin
    Result := '';
    for Microcontroller in Microcontrollers do
      // If the node for a specific microcontroller exists (is not Null), we found our platform
      if Doc.Root.Values[Microcontroller].NodeType <> TYamlNodeType.Null then
        Exit(Microcontroller);
  end;

begin
  FValid := False;
  FOptionDeps := TStringList.Create(dupIgnore, true, False); // Creates a list avoiding duplicate dependency names
  Name := ExpandFileName(AFileName);

  // Check if the file physically exists before attempting to parse
  if FileExists(Name) then
  begin
    // Attempt to load and parse the YAML file using Neslib.Yaml
    Doc := TYamlDocument.Load(Name);
    if Assigned(Doc) then
    begin
      SubstitutionMap := TDictionary<string, string>.Create;

      // STEP 1: Pre-load the Substitution Map.
      // We must do this first because the device name, board, etc. might rely on these variables.
      for Index := 0 to Doc.Root.Values['substitutions'].Count - 1 do
        SubstitutionMap.Add(
          Doc.Root.Values['substitutions'].Elements[Index].Key,
          Doc.Root.Values['substitutions'].Elements[Index].Value
        );

      // STEP 2: Extract the basic core node: 'esphome -> name'
      FName := Substitute(Doc.Root.Values['esphome'].Values['name'].ToString());

      // If 'name' is populated, we assume the file is a structurally valid ESPHome configuration
      if (FName <> '') then
      begin
        FFileName := AFileName;
        FFriendlyName := Substitute(Doc.Root.Values['esphome'].Values['friendly_name'].ToString());

        // STEP 3: Identify hardware parameters
        FMicrocontroller := FindMicrocontroller;
        FBoard := Substitute(Doc.Root.Values[FMicrocontroller].Values['board'].ToString());
        FFramework := Substitute(Doc.Root.Values[FMicrocontroller].Values['framework'].Values['type'].ToString());

        // STEP 4: Check for the presence of specific top-level modules
        FHasWiFi := Doc.Root.Values['wifi'].NodeType <> TYamlNodeType.Null;
        FHasWebServer := Doc.Root.Values['web_server'].NodeType <> TYamlNodeType.Null;

        // The project is fully valid only if we managed to identify the underlying microcontroller
        FValid := FMicrocontroller <> '';

        // STEP 5: Load specific user settings/dependencies linked to this file from the global INI
        LoadOptionDependencies;
      end;

      // Free the dictionary to prevent memory leaks
      SubstitutionMap.Free;
    end;
  end;
end;

{
  Purpose: Returns the friendly name of the project if one is defined in the YAML.
  If not, it falls back to the technical internal name.
}
function TProject.GetFriendlyName: string;
begin
  if FFriendlyName <> '' then
    Result := FFriendlyName
  else
    Result := FName;
end;

{
  Purpose: Generates a formatted string used primarily for displaying the project
  in UI elements like dropdown menus or ListViews.
  Format: "FriendlyName - ("filename.yaml" in "C:\Path\To\Project")"
}
function TProject.GetUIName: string;
begin
  Result := Format('%s - ("%s" in "%s")', [FriendlyName, ExtractFileName(FileName), ExtractFilePath(FileName)]);
end;

// Resource strings for the Description properties
resourcestring
  rsFieldName = 'Name';
  rsFieldFriendlyName = 'Friendly Name';
  rsFieldMicrocontroller = 'Microcontroller';
  rsFieldBoard = 'Board';
  rsFieldFramework = 'Framework';
  rsFieldFileName = 'Project File Name';
  rsFieldPath = 'Project File Path';
  rsFieldWiFi = 'WiFi';
  rsFieldEnabled = 'Enabled';
  rsFieldDisabled = 'Disabled';
  rsFieldWebServer = 'WebServer';
  rsFieldYes = 'Yes';
  rsFieldNo = 'No';

{
  Purpose: Generates a comprehensive, multi-line string containing all parsed
  hardware and software properties. Used mostly for tooltips or info panels.
}
function TProject.GetDescription: string;
  // Local Helper: Appends a new line to the description only if the content is not empty.
  function SetupString(AText, ALabel, AContent: string): string;
  begin
    if AContent <> '' then
    begin
      if AText <> '' then
        AText := AText + #13#10; // Append standard Windows line break
      AText := AText + ALabel + ': ' + AContent + '';
    end;
    Result := AText;
  end;

begin
  // Progressively build the description string
  Result := SetupString('', rsFieldName, Self.Name);
  Result := SetupString(Result, rsFieldFriendlyName, Self.FriendlyName);
  Result := SetupString(Result, rsFieldMicrocontroller, Self.Microcontroller);
  Result := SetupString(Result, rsFieldBoard, Self.Board);
  Result := SetupString(Result, rsFieldFramework, Self.Framework);
  Result := SetupString(Result, rsFieldFileName, ExtractFileName(FileName));
  Result := SetupString(Result, rsFieldPath, ExtractFilePath(FileName));

  // Determine WiFi and WebServer statuses
  if Self.HasWiFi then
  begin
    Result := SetupString(Result, rsFieldWiFi, rsFieldEnabled);
    if Self.HasWebServer then
      Result := SetupString(Result, rsFieldWebServer, rsFieldYes)
    else
      Result := SetupString(Result, rsFieldWebServer, rsFieldNo);
  end
  else
    Result := SetupString(Result, rsFieldWiFi, rsFieldDisabled);
end;

function TProject.GetOptionDeps: TStringList;
begin
  Result := FOptionDeps;
end;

// ----------------------------------------------------------------------------
// INI Configuration Readers/Writers for the Specific Project
// ----------------------------------------------------------------------------
// These overloaded methods read and write values to the global INI file.
// They use the project's absolute file path (FileName) as the INI Section Name.
// This isolates configuration so that each project maintains its own state.

function TProject.GetOption(const Option: string; const Default: Boolean): Boolean;
begin
  Result := Default;
  if Assigned(ConfigIniFile) then
    Result := ConfigIniFile.ReadBool(FileName, Option, Default);
end;

function TProject.GetOption(const Option: string; const Default: Integer): Integer;
begin
  Result := Default;
  if Assigned(ConfigIniFile) then
    Result := ConfigIniFile.ReadInteger(FileName, Option, Default);
end;

function TProject.GetOption(const Option: string; const Default: string): string;
begin
  Result := Default;
  if Assigned(ConfigIniFile) then
    Result := ConfigIniFile.ReadString(FileName, Option, Default);
end;

procedure TProject.SetOption(const Option: string; const Value: Boolean);
begin
  if Assigned(ConfigIniFile) then
    ConfigIniFile.WriteBool(FileName, Option, Value);
end;

procedure TProject.SetOption(const Option: string; const Value: Integer);
begin
  if Assigned(ConfigIniFile) then
    ConfigIniFile.WriteInteger(FileName, Option, Value);
end;

procedure TProject.SetOption(const Option: string; const Value: string);
begin
  if Assigned(ConfigIniFile) then
    ConfigIniFile.WriteString(FileName, Option, Value);
end;

{
  Purpose: Reads the file dependencies (e.g., included YAML files, secrets.yaml)
  associated with this specific project from the INI file and stores them in FOptionDeps.
}
procedure TProject.LoadOptionDependencies;
var
  I, Count: Integer;
  R: string;
begin
  if Assigned(ConfigIniFile) then
  begin
    FOptionDeps.Clear;
    // Read the total count of dependencies stored
    Count := GetOption(csKeyDependenciesCount, 0);
    // Loop through and read each numbered key (e.g., Dependency0, Dependency1)
    for I := 0 to Count - 1 do
    begin
      R := GetOption(Format(csKeyDependencyPrefix + '%d', [I]), csDefaultEmpty);
      if R <> csDefaultEmpty then
        FOptionDeps.Add(R);
    end;
  end;
end;

{
  Purpose: Saves the current list of file dependencies to the INI file.
  It first cleans up any existing dependency entries to avoid ghost records.
}
procedure TProject.SaveOptionDependencies;
var
  S: string;
  I: Integer;
  SList: TStringList;
begin
  if Assigned(ConfigIniFile) then
  begin
    SList := TStringList.Create;
    // Step 1: Read all keys currently under this project's section
    ConfigIniFile.ReadSection(FileName, SList);

    // Step 2: Delete any existing keys that start with the dependency prefix ('Dependency')
    for S in SList do
      if SameText(csKeyDependencyPrefix, LeftStr(S, Length(csKeyDependencyPrefix))) then
        ConfigIniFile.DeleteKey(FileName, S);
    SList.Free;

    // Step 3: Write the new count and recreate the numbered keys sequentially
    SetOption(csKeyDependenciesCount, FOptionDeps.Count);
    for I := 0 to FOptionDeps.Count - 1 do
      SetOption(Format(csKeyDependencyPrefix + '%d', [I]), FOptionDeps[I]);
  end;
end;

// ============================================================================
// TProjectList Implementation
// ============================================================================

{
  Purpose: Initializes the list, enabling auto-free (objects are destroyed when removed),
  and automatically loads previously saved projects from the INI file.
}
constructor TProjectList.Create;
begin
  FCurrent := nil;
  inherited Create(True); // True = Owns objects (memory management)
  LoadConfig;
end;

{
  Purpose: Sets the currently active project and saves this state to the INI file
  so it persists across Notepad++ restarts.
}
procedure TProjectList.SetCurrent(P: TProject);
begin
  if Assigned(P) and (Self.IndexOf(P) >= 0) then
  begin
    FCurrent := P;
    ConfigIniFile.WriteString(csSectionGeneral, csKeyCurrentProject, FCurrent.FileName);
  end
  else
  begin
    FCurrent := nil;
    // If no project is selected, remove the key from the General section
    ConfigIniFile.DeleteKey(csSectionGeneral, csKeyCurrentProject);
  end;
end;

{
  Purpose: Retrieves the currently active project. If none is loaded in memory yet,
  it attempts to read the last known project from the INI file (Lazy-loading).
}
function TProjectList.GetCurrent: TProject;
begin
  if not Assigned(FCurrent) then
    FCurrent := GetProjectFromFileName(ConfigIniFile.ReadString(csSectionGeneral, csKeyCurrentProject, csDefaultEmpty));
  Result := FCurrent;
end;

{
  Purpose: Iterates over the INI file. Since every section (except 'General') represents
  the file path of a project, it tries to instantiate a TProject for each section.
}
procedure TProjectList.LoadConfig;
var
  Project: TProject;
  Sections: TStringList;
  FileName: string;
begin
  Self.Clear;
  FCurrent := nil;
  Sections := TStringList.Create;
  ConfigIniFile.ReadSections(Sections);

  for FileName in Sections do
  begin
    // Skip the General settings section
    if FileName <> csSectionGeneral then
    begin
      Project := TProject.Create(FileName);
      // Only add to the list if the YAML was successfully parsed
      if Project.IsValid then
        Self.Add(Project)
      else
        Project.Free; // Cleanup memory if instantiation failed
    end;
  end;
  Sections.Free;
end;

{
  Purpose: Iterates through memory to ensure autosave options are written.
  It also performs a cleanup of the INI file, erasing sections for projects
  that no longer exist or are invalid.
}
procedure TProjectList.SaveConfig;
var
  Project: TProject;
  Sections: TStringList;
  FileName: string;
begin
  // Update properties for valid projects, or erase the section if the project became invalid
  for Project in Self do
    if Project.IsValid then
      Project.SetOption(csKeyNppAutosave, Project.GetOption(csKeyNppAutosave, ciAutoSaveProjectAndDeps))
    else
      ConfigIniFile.EraseSection(Project.FileName);

  // Housekeeping: Read all sections in the INI file. If a section exists but
  // there is no corresponding TProject in memory, erase the section.
  Sections := TStringList.Create;
  ConfigIniFile.ReadSections(Sections);
  for FileName in Sections do
    if (FileName <> csSectionGeneral) and (Self.GetProjectFromFileName(FileName) = nil) then
      ConfigIniFile.EraseSection(FileName);
  Sections.Free;
end;

{
  Purpose: Searches the loaded projects by their absolute file path.
  If IncludeDeps is True, it will also return the project if the queried filename
  belongs to one of the project's dependencies (e.g., finding the master project
  when a user opens a secrets.yaml file).
}
function TProjectList.GetProjectFromFileName(const FileName: string; const IncludeDeps: boolean = False): TProject;
var
  S: string;
  P: TProject;
begin
  Result := nil;
  for P in Self do
  begin
    // Compare paths case-insensitively
    if SameText(P.FileName, ExpandFileName(FileName)) then
    begin
      Result := P;
      Exit;
    end;

    // Check dependency list if requested
    if IncludeDeps then
    begin
      for S in P.OptionDependencies do
        if SameText(ExpandFileName(S), ExpandFileName(FileName)) then
        begin
          Result := P;
          Exit;
        end;
    end;
  end;
end;

{
  Purpose: Finds a project based on its generated UI Name string.
}
function TProjectList.GetProjectFromUIName(const UIName: string): TProject;
var
  P: TProject;
begin
  Result := nil;
  for P in Self do
    if P.UIName = UIName then
    begin
      Result := P;
      Exit;
    end;
end;

// ============================================================================
// TTemplateList Implementation
// ============================================================================

{
  Purpose: Initializes the template manager. If the local XML file containing
  ESPHome templates is missing, it prompts the user to download it directly from GitHub.
}
constructor TTemplateList.Create(const AFileName: string);
begin
  inherited Create;

  if not FileExists(TemplateFile) then
  begin
    // Show a dialog asking to download the default templates
    if TD(rsTemplatesNotFound).WindowCaption(rsMessageBoxWarning).Text(rsTemplatesNotFound2).Warning.YesNo.SetFlags([tfAllowDialogCancellation]).Execute(nil) = mrYes then
    begin
      DownloadTemplateFileFromGitHub;
      TD(rsTemplatesXMLDownloaded).WindowCaption(rsMessageBoxInfo).Info.OK.SetFlags([tfAllowDialogCancellation]).Execute(nil);
    end;
  end;

  // If the file now exists, instantiate the XML Document and parse it
  if FileExists(AFileName) then
  begin
    FXMLDoc := TXMLDocument.Create(nil);
    FXMLDoc.FileName := AFileName;
    Refresh;
  end;
end;

resourcestring
  rsErrorReadingTemplateFile = 'The following error has been encountered reading the XML Template file:';

{
  Purpose: Parses the NppESPHome.xml file, extracting the template Name, Category,
  Description, and the actual YAML snippet. Populates the list in memory.
}
procedure TTemplateList.Refresh;
var
  Index: Integer;
  RootNode: IXMLNode;
  Template: TTemplate;
begin
  Self.Clear;
  if TFile.GetSize(TemplateFile) > 0 then
  begin
    try
      FXMLDoc.Active := True;
      FXMLDoc.Refresh;
      RootNode := FXMLDoc.DocumentElement;

      if Assigned(RootNode) then
        // Iterate through all child nodes (which represent individual <Template> tags)
        for Index := 0 to RootNode.ChildNodes.Count - 1 do
        begin
          Template.Name := RootNode.ChildNodes[Index].ChildNodes['Name'].Text;
          Template.Category := RootNode.ChildNodes[Index].ChildNodes['Category'].Text;
          Template.OnlineHelp := RootNode.ChildNodes[Index].ChildNodes['OnlineHelp'].Text;
          Template.Description := RootNode.ChildNodes[Index].ChildNodes['Description'].Text;

          // The YAML content is stored in the XML as HTML entities (to avoid breaking the XML).
          // TNetEncoding.HTML.Decode converts things like &lt; back to <
          Template.YAML := TNetEncoding.HTML.Decode(RootNode.ChildNodes[Index].ChildNodes['YAML'].Text);

          // Prevent duplicate entries
          if Self.IndexOfName(Template.Name) < 0 then
            Self.Add(Template);
        end;
    except
      on E: Exception do
        // Display parse errors (e.g., malformed XML) to the user
        TD(rsErrorReadingTemplateFile).Text(Format('%s', [E.Message])).WindowCaption(rsMessageBoxError).Error.OK.SetFlags([tfAllowDialogCancellation]).Execute(nil);
    end;
  end;
end;

{
  Purpose: Populates a standard TStrings object (like a ComboBox) with templates,
  applying an optional Category filter and a text Search filter.
}
procedure TTemplateList.RetrieveTemplates(S: TStrings; const Category: string; const Filter: string);
var
  Item: string;
  List: TStringList;
  Template: TTemplate;
begin
  S.Clear;
  List := TStringList.Create(dupIgnore, True, False);

  for Template in Self do
    // Check if it matches the category (or if "Any Category" is selected) AND matches the text filter
    if ((Category = '') or (Category = rsAnyCategory) or (Template.Category = Category)) and ((Filter = '') or ContainsText(Template.Name, Filter)) then
      List.Add(Format('%s [%s]', [Template.Name, Template.Category]));

  for Item in List do
    S.Add(Item);
  List.Free;
end;

{
  Purpose: Overloaded version of RetrieveTemplates. Instead of strings, it populates
  a UI ListView component (TListItems) with the Name as the caption and Category as a sub-item.
}
procedure TTemplateList.RetrieveTemplates(S: TListItems; const Category: string; const Filter: string);
var
  Item: TListItem;
  Template: TTemplate;
begin
  S.Clear;
  for Template in Self do
    if ((Category = '') or (Category = rsAnyCategory) or (Template.Category = Category)) and ((Filter = '') or ContainsText(Template.Name, Filter)) then
    begin
      Item := S.Add;
      Item.Caption := Template.Name;
      Item.SubItems.Add(Template.Category);
    end;
end;

{
  Purpose: Extracts a unique list of all template categories available in the XML.
}
procedure TTemplateList.RetrieveCategories(S: TStrings);
var
  Category: string;
  Template: TTemplate;
  Categories: TStringList;
begin
  S.Clear;
  Categories := TStringList.Create(dupIgnore, True, False);
  for Template in Self do
    Categories.Add(Template.Category);
  for Category in Categories do
    S.Add(Category);
  Categories.Free;
end;

{
  Purpose: Helper function to find the array index of a template based on its Name.
}
function TTemplateList.IndexOfName(const AName: string): NativeInt;
var
  Index: NativeInt;
begin
  Result := -1;
  for Index := 0 to Self.Count - 1 do
    if AName = Self.Items[Index].Name then
    begin
      Result := Index;
      Exit
    end;
end;

// ============================================================================
// Shortcut Management Functions
// ============================================================================

{
  Purpose: Converts a Notepad++ shortcut record into a readable menu suffix.
  Used when refreshing dynamic menu captions so remapped shortcuts stay visible.
}
function ShortcutToString(const S: PShortcutKey): string;
var
  Parts: TArray<string>;
  KeyName: array [0 .. 255] of Char;
begin
  SetLength(Parts, 0);
  // Collect active modifiers first, preserving the familiar shortcut order.
  if S.IsCtrl then
    Parts := Parts + ['Ctrl'];
  if S.IsAlt then
    Parts := Parts + ['Alt'];
  if S.IsShift then
    Parts := Parts + ['Shift'];
  if S.Key <> 0 then
  begin
    // Ask Windows for a localized key name; fall back to the raw virtual-key code.
    if GetKeyNameText(MapVirtualKey(S.Key, MAPVK_VK_TO_VSC) shl 16, KeyName, Length(KeyName)) > 0 then
      Parts := Parts + [KeyName]
    else
      Parts := Parts + [Format('VK_%d', [S.Key])];
  end;
  Result := Trim(string.Join('+', Parts));
end;

{
  Purpose: Allocates and initializes a Notepad++ shortcut definition.
  The returned pointer is passed to AddFuncItem when registering commands.
}
function MakeShortcutKey(const Ctrl, Alt, Shift: Boolean; const AKey: UCHAR): PShortcutKey;
begin
  // Notepad++ expects a pointer that stays valid after registration.
  Result := New(PShortcutKey);
  with Result^ do
  begin
    IsCtrl := Ctrl;
    IsAlt := Alt;
    IsShift := Shift;
    Key := AKey;
  end;
end;

// ============================================================================
// Process Management Utilities
// ============================================================================

{
  Purpose: Checks if a Windows process (given its Process ID) is still actively running.
}
function IsPIDRunning(PID: DWORD): Boolean;
var
  Res: DWORD;
  hProcess: THandle;
begin
  Result := False;
  // Open an access handle to the process with permission to query its status
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION, False, PID);
  if hProcess <> 0 then
  try
    // Retrieve the exit code. If it hasn't exited, the API returns STILL_ACTIVE (259)
    Result := GetExitCodeProcess(hProcess, Res);
    Result := Result and (Res = STILL_ACTIVE);
  finally
    CloseHandle(hProcess); // Always close handles to prevent memory/resource leaks
  end;
end;

{
  Purpose: Forcibly terminates a single running process by its PID.
}
function KillProcessByPID(PID: DWORD): Boolean;
var
  hProcess: THandle;
begin
  Result := False;
  // Open the process with termination rights
  hProcess := OpenProcess(PROCESS_TERMINATE, False, PID);
  if hProcess <> 0 then
  try
    // Kill the process. The '0' is the exit code we force the application to return
    Result := TerminateProcess(hProcess, 0);
  finally
    CloseHandle(hProcess);
  end;
end;

{
  Purpose: Terminates a process AND all its child processes recursively.
  Crucial for command-line tools like ESPHome, which might spawn Python or PlatformIO child processes.
}
function KillProcessTree(PID: DWORD): Boolean;
var
  hSnap: THandle;
  pe: TProcessEntry32;
begin
  // Create a snapshot of all processes currently running in Windows
  hSnap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if hSnap <> INVALID_HANDLE_VALUE then
  try
    pe.dwSize := SizeOf(pe);
    // Iterate through the snapshot list
    if Process32First(hSnap, pe) then
      repeat
        // If the current process lists our target PID as its parent, it's a child.
        // We call KillProcessTree recursively to kill it (and its children).
        if (pe.th32ParentProcessID = PID) then
          KillProcessTree(pe.th32ProcessID);
      until not Process32Next(hSnap, pe);
  finally
    CloseHandle(hSnap);
  end;

  // After killing all children, kill the main parent process
  Result := KillProcessByPID(PID);
end;

// Structure used to pass target PID and receive the window handle in the EnumWindows callback
type
  PFindWindowRecord = ^TFindWindowRecord;
  TFindWindowRecord = record
    PID: DWORD;
    FoundHWND: HWND;
  end;

{
  Purpose: Callback function used by the Windows API EnumWindows.
  It is called once for every top-level window on the screen.
}
function EnumWindowsCallback(Handle: HWND; lParam: lParam): BOOL; stdcall;
var
  WindowPID: DWORD;
  SearchRec: PFindWindowRecord;
begin
  Result := True; // True tells EnumWindows to continue to the next window
  SearchRec := PFindWindowRecord(lParam);

  // Get the Process ID that owns this specific Window Handle
  GetWindowThreadProcessId(Handle, @WindowPID);

  // If the Window's PID matches our target PID, we found the application's GUI
  if (WindowPID = SearchRec^.PID) then
  begin
    SearchRec^.FoundHWND := Handle; // Store the handle
    Result := False; // Stop enumeration (optimizes performance)
  end;
end;

{
  Purpose: Finds the main Window Handle (HWND) of a running application given its PID.
  It includes a timeout mechanism because GUI applications take a few milliseconds
  to actually create their windows after the process starts.
}
function GetMainWindowHandleByPID(const TargetPID: DWORD; Timeout: Integer = 3000): HWND;
var
  SearchRec: TFindWindowRecord;
begin
  SearchRec.PID := TargetPID;
  SearchRec.FoundHWND := 0;

  // Start the enumeration, passing the memory address of SearchRec
  EnumWindows(@EnumWindowsCallback, lParam(@SearchRec));

  // Blocking wait loop: if the window isn't found yet, sleep for 50ms and try again
  while (SearchRec.FoundHWND = 0) and (Timeout > 0) do
  begin
    Sleep(50);
    Dec(Timeout, 50);
    EnumWindows(@EnumWindowsCallback, lParam(@SearchRec));
  end;

  Result := SearchRec.FoundHWND;
end;

// ============================================================================
// Path and Environment Utilities
// ============================================================================

{
  Purpose: Retrieves all environment variables of the current Windows session
  (like %PATH%, %APPDATA%) and stores them in a TStrings list.
}
procedure GetEnvironmentVars(List: TStrings);
var
  EnvBlock: PChar;
  P: PChar;
begin
  List.Clear;
  // Get Environment block. It returns a contiguous block of null-terminated strings
  EnvBlock := GetEnvironmentStrings;
  try
    P := EnvBlock;
    // Iterate through memory until we hit a double null-terminator (#0)
    while P^ <> #0 do
    begin
      List.Add(P);
      Inc(P, lstrlen(P) + 1); // Move pointer past the current string and its null terminator
    end;
  finally
    FreeEnvironmentStrings(EnvBlock); // Release system memory
  end;
end;


{
  Purpose: Validates whether a given string is a formally correct URL
           and uses either the HTTP or HTTPS protocol.
}
function IsValidHttpUrl(const AUrl: string): Boolean;
var
  LUri: TURI;
begin
  try
    // If the string is not a valid URL, the constructor will throw an exception
    LUri := TURI.Create(AUrl);
    // Check if the scheme/protocol is HTTP or HTTPS (case-insensitive)
    Result := SameText(LUri.Scheme, 'http') or SameText(LUri.Scheme, 'https');
  except
    on E: ENetURIException do
    begin
      // Any parsing error means the URL is invalid
      Result := False;
    end;
  end;
end;

{
  Purpose: Searches for an executable file (e.g., "esphome.exe") across all
  directories defined in the system's %PATH% variable.
}
function FindFileInPath(const FileName: string): string;
var
  Buffer: array[0..MAX_PATH - 1] of WideChar;
  BufferSize: DWORD;
  FilePart: LPWSTR;
begin
  Result := '';
  FilePart := nil;
  // SearchPath is a core Windows API that resolves executables just like the command prompt does
  BufferSize := SearchPath(nil, PChar(FileName), nil, MAX_PATH, Buffer, FilePart);
  if BufferSize > 0 then
    Result := StrPas(Buffer); // Convert WideChar array to Delphi string
end;

{
  Purpose: Converts a long Windows path containing spaces into an old 8.3 DOS-style path
  (e.g., "C:\Program Files" -> "C:\PROGRA~1"). Required for compatibility with some
  legacy command line tools that break when encountering spaces.
}
function ShortFileName(const LongFileName: string): string;
var
  ShortName: array[0..MAX_PATH] of Char;
begin
  Result := '';
  if GetShortPathName(PChar(LongFileName), ShortName, MAX_PATH) > 0 then
    Result := ShortName;
end;

resourcestring
  rsTemplatesGitHubUrl = 'https://raw.githubusercontent.com/atiburzi/NppESPHome-Plugin/refs/heads/main/Templates/NppESPHome.xml';

{
  Purpose: Downloads the default XML templates file directly from the GitHub repository
  and saves it to the local plugin directory.
}
procedure DownloadTemplateFileFromGitHub;
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  FileStream: TFileStream;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    // Execute GET request
    Response := HTTP.Get(rsTemplatesGitHubUrl);
    // Open a file stream on the disk to write the data
    FileStream := TFileStream.Create(TemplateFile, fmCreate);
    try
      // Ensure the memory stream is at the beginning, then copy the payload to disk
      Response.ContentStream.Position := 0;
      FileStream.CopyFrom(Response.ContentStream, Response.ContentStream.Size);
    finally
      FileStream.Free;
    end;
  finally
    HTTP.Free;
  end;
end;

// ============================================================================
// UI & Image Manipulation Utilities
// ============================================================================

{
  Purpose: Checks if the user's custom toolbar configuration contains any valid icon handles.
}
function HasToolbarIcon(const IconData: TToolbarIconsWithDarkMode): Boolean;
begin
  Result := (IconData.ToolbarBmp <> 0) or (IconData.ToolbarIcon <> 0) or (IconData.ToolbarIconDarkMode <> 0);
end;

{
  Purpose: Converts a standard VCL TBitmap graphic into a Windows Hardware Icon Handle (HICON).
  This is needed to assign icons to system-level objects like Windows Forms or Taskbar items.
}
function CreateIconFromBitmap(Bitmap: Vcl.Graphics.TBitmap): HICON;
var
  IconInfo: TIconInfo;
begin
  FillChar(IconInfo, SizeOf(IconInfo), 0);
  IconInfo.fIcon := True;
  IconInfo.hbmMask := Bitmap.Handle; // Use the bitmap for both image and mask
  IconInfo.hbmColor := Bitmap.Handle;
  // System call to generate the HICON structure
  Result := CreateIconIndirect(IconInfo);
end;

{
  Purpose: Mutates an image by converting all visible pixels to pure black.
  Used to dynamically generate "Dark Mode" silhouette icons from standard icons.
}
procedure ConvertBitmapToBlack(Bitmap: Vcl.Graphics.TBitmap);
var
  x, y: Integer;
  P: PRGBQuad;
begin
  // Force 32-bit format so we have access to the Alpha channel (rgbReserved)
  Bitmap.PixelFormat := pf32bit;

  for y := 0 to Bitmap.Height - 1 do
  begin
    // ScanLine gives a memory pointer to the start of the pixel row (very fast access)
    P := Bitmap.ScanLine[y];
    for x := 0 to Bitmap.Width - 1 do
    begin
      // If the alpha channel > 0, the pixel is at least partially visible
      if P^.rgbReserved > 0 then
      begin
        // Zero out the RGB channels (leaving alpha intact), resulting in black
        P^.rgbRed := 0;
        P^.rgbGreen := 0;
        P^.rgbBlue := 0;
      end;
      Inc(P); // Move pointer to the next pixel
    end;
  end;
end;

{
  Purpose: Applies a "disabled" visual state to an icon. It converts the image to
  grayscale and reduces its opacity, making it look washed out (standard Windows UI behavior).
}
procedure ConvertBitmapToDisabled(Bitmap: Vcl.Graphics.TBitmap);
var
  x, y: Integer;
  P: PRGBQuad;
  Gray: Byte;
begin
  Bitmap.PixelFormat := pf32bit;

  for y := 0 to Bitmap.Height - 1 do
  begin
    P := Bitmap.ScanLine[y];
    for x := 0 to Bitmap.Width - 1 do
    begin
      if P^.rgbReserved > 0 then
      begin
        // 1. Calculate Grayscale. We use a modified luminance formula based on human eye perception
        // (Green is brightest, Blue is darkest). Integer math (shr 8) is used instead of floats for speed.
        Gray := (P^.rgbRed * 60 + P^.rgbGreen * 100 + P^.rgbBlue * 20) shr 8;

        // 2. Set all color channels to the calculated gray value
        P^.rgbRed   := Gray;
        P^.rgbGreen := Gray;
        P^.rgbBlue  := Gray;

        // 3. Halve the alpha channel (opacity) to create the transparent/faded disabled effect
        P^.rgbReserved := P^.rgbReserved div 2;
      end;
      Inc(P);
    end;
  end;
end;

{
  Purpose: Finds pixels of a specific color (SourceColor) and dynamically changes
  them to a new color (TargetColor) without losing shadows/highlights.
  It uses the HSL (Hue, Saturation, Lightness) color space to achieve this.
}
procedure ReplaceBitmapHue(ABitmap: Vcl.Graphics.TBitmap; const SourceColor: TAlphaColor; const TargetColor: TAlphaColor; const HueTolerance: Single = 30 / 360;
  const MinSaturation: Single = 0.15);
type
  // Define an array pointer to map over the scanline safely
  PRGBQuadArray = ^TRGBQuadArray;
  TRGBQuadArray = array[0..MaxInt div SizeOf(TRGBQuad) - 1] of TRGBQuad;

  // Local Helper: Calculates the shortest distance between two hues on a 360-degree color wheel
  function HueDistance(const H1, H2: Single): Single;
  begin
    Result := Abs(H1 - H2);
    if Result > 0.5 then
      Result := 1.0 - Result;
  end;

var
  X, Y: Integer;
  Row: PRGBQuadArray;
  P: TRGBQuad;
  C, NewC: TAlphaColor;
  H, S, L: Single;
  SourceH, SourceS, SourceL: Single;
  TargetH, TargetS, TargetL: Single;
begin
  // Convert our target and source colors from RGB space to HSL space
  RGBtoHSL(SourceColor, SourceH, SourceS, SourceL);
  RGBtoHSL(TargetColor, TargetH, TargetS, TargetL);
  ABitmap.PixelFormat := pf32bit;

  for Y := 0 to ABitmap.Height - 1 do
  begin
    Row := ABitmap.ScanLine[Y];
    for X := 0 to ABitmap.Width - 1 do
    begin
      P := Row[X];
      if P.rgbReserved > 0 then
      begin
        // Reconstruct the AlphaColor DWORD from the individual byte channels
        C := TAlphaColor($FF000000) or (TAlphaColor(P.rgbRed) shl 16) or (TAlphaColor(P.rgbGreen) shl 8) or TAlphaColor(P.rgbBlue);

        // Find the Hue, Saturation, and Lightness of the current pixel
        RGBtoHSL(C, H, S, L);

        // Check if the pixel has enough color (isn't gray/white/black) AND
        // if its hue matches the target hue within the specified tolerance.
        if (S >= MinSaturation) and (HueDistance(H, SourceH) <= HueTolerance) then
        begin
          // Swap the Hue to the new TargetHue, keeping original Saturation and Lightness
          NewC := HSLtoRGB(TargetH, S, L);

          // Write the modified color back to the memory block
          Row[X].rgbRed := TAlphaColorRec(NewC).R;
          Row[X].rgbGreen := TAlphaColorRec(NewC).G;
          Row[X].rgbBlue := TAlphaColorRec(NewC).B;
        end;
      end;
    end;
  end;
end;

{
  Purpose: Clones an entire ImageCollection, running the ConvertBitmapToBlack routine
  on every single image inside it. Used during application startup to generate a
  Dark Mode compatible icon set.
}
procedure PopulateBlackImageCollection(ASource, ADest: TImageCollection);
var
  I, J: Integer;
  SrcItem, DstItem: TImageCollectionItem;
  SrcImg, DstImg: TImageCollectionSourceItem;
  Bmp: TBitmap;
begin
  // BeginUpdate stops the UI from redrawing while we modify the collection
  ADest.Images.BeginUpdate;
  try
    ADest.Images.Clear;
    for I := 0 to ASource.Images.Count - 1 do
    begin
      SrcItem := ASource.Images.Items[I];
      DstItem := ADest.Images.Add;
      DstItem.Name := SrcItem.Name;
      DstItem.Description := SrcItem.Description;

      // Items in an ImageCollection can contain multiple sizes of the same image
      for J := 0 to SrcItem.SourceImages.Count - 1 do
      begin
        SrcImg := SrcItem.SourceImages.Items[J];
        Bmp := TBitmap.Create;
        try
          Bmp.Assign(SrcImg.Image);
          Bmp.AlphaFormat := afDefined;
          Bmp.PixelFormat := pf32bit;

          ConvertBitmapToBlack(Bmp); // Apply the black mask effect

          DstImg := DstItem.SourceImages.Add;
          DstImg.Image.Assign(Bmp);
        finally
          Bmp.Free;
        end;
      end;
    end;
  finally
    ADest.Images.EndUpdate;
  end;
end;

{
  Purpose: Assigns an icon to a Windows form/dialog based on the application's current theme.
}
procedure AssignWindowIcon(AIcon: TIcon);
var
  Icon: TIcon;
  Images: TVirtualImageList;
begin
  Images := TVirtualImageList.Create(nil);
  Images.Width := 32;
  Images.Height := 32;
  Icon := TIcon.Create;
  try
    // Fetch the correct icon set (Light vs Dark)
    AssignImageResources(Images);
    Images.AutoFill := True;

    // Extract the specific 'window' icon and copy it to the provided AIcon
    Images.GetIcon(Images.GetIndexByName(csIconWindow), Icon);
    AIcon.Assign(Icon);
  finally
    Icon.Free;
    Images.Free;
  end;
end;

{
  Purpose: Points a TVirtualImage component to the correct ImageCollection based
  on Notepad++'s current theme (Dark Mode vs Light Mode).
}
procedure AssignImageResources(AVirtualImage: TVirtualImage); overload;
begin
  if Plugin.IsDarkModeEnabled then
    AVirtualImage.ImageCollection := Resources.StandardImages
  else
    AVirtualImage.ImageCollection := Resources.LightModeImages;
end;

{
  Purpose: Overloaded method that does the same as above, but for a TVirtualImageList
  (used by Toolbars and Menus).
}
procedure AssignImageResources(AVirtualImageList: TVirtualImageList);
begin
  if Plugin.IsDarkModeEnabled then
    AVirtualImageList.ImageCollection := Resources.StandardImages
  else
    AVirtualImageList.ImageCollection := Resources.LightModeImages;
end;

// ============================================================================
// Bitwise Utilities
// ============================================================================

{
  Purpose: Reads the state (1 or 0) of a specific bit inside an integer.
  How it works: It shifts a '1' left by BitPos to create a mask (e.g., 001000),
  then uses bitwise AND. If the result is not 0, the bit was active.
}
function GetBit(const Value: Int64; BitPos: ShortInt): Boolean;
begin
  Result := (Value and (1 shl BitPos)) <> 0;
end;

{
  Purpose: Modifies a specific bit inside an integer to either 1 (True) or 0 (False).
  How it works:
  1. (Value and not (1 shl BitPos)) -> Creates a mask with a 0 at the target position
     and 1s elsewhere, effectively clearing that bit.
  2. (Ord(State) shl BitPos) -> Shifts a 1 or 0 to the target position.
  3. OR combines them, injecting the new state without affecting other bits.
}
function SetBit(const Value: Int64; BitPos: ShortInt; State: Boolean): Int64;
begin
  Result := (Value and not (1 shl BitPos)) or (Ord(State) shl BitPos);
end;

end.
