unit ESPHomeShared;

interface

uses
  System.Classes, System.Generics.Collections, Winapi.Windows, Vcl.ComCtrls, Vcl.Graphics, Vcl.VirtualImage, Vcl.ImageCollection, Vcl.VirtualImageList, XMLIntf, IniFiles,
  System.UITypes, NppSupport, Winapi.CommCtrl;

const
  PingTimeout = 3 * 1000;

const
  ciAutoSaveNone = 0;
  ciAutoSaveProject = 1;
  ciAutoSaveProjectAndDeps = 2;
  ciAutoSaveAllFiles = 3;
  ciConsolePosDecidedByWindows = 0;
  ciConsolePosScreenCenter = 1;
  ciConsolePosTopLeftSide = 2;
  ciConsolePosBottomLeftSide = 3;
  ciConsolePosTopRightSide = 4;
  ciConsolePosBottomRightSide = 5;
  ciConsolePosLastPosition = 6;
  ciLogLevelCritical = 0;
  ciLogLevelError = 1;
  ciLogLevelWarning = 2;
  ciLogLevelInfo = 3;
  ciLogLevelDebug = 4;
  ciLogLevelDefault = 5;

const
  csDefaultEmpty = '';
  csSectionGeneral = 'General';
  csSectionProjects = 'Projects';
  csKeyCurrentProject = 'CurrentProject';
  csKeyToolbarBitmap = 'ToolbarBitmap';
  csKeyToolbarSequence = 'ToolbarSequence';
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

const
  scRun = 0;
  scCompile = 1;
  scUpload = 2;
  scLogs = 3;
  scClean = 4;
  scCleanAll = 5;

const
  csIconNone = 'none';
  csIconWiFi = 'wifi';
  csIconSerial = 'serial';
  csIconWindow = 'window';

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
    FOptionDeps: TStringList;
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
    property IsValid: Boolean read FValid;

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

  TProjectList = class(TObjectList<TProject>)
  private
    FCurrent: TProject;
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

  TTemplate = record
    Name: string;
    Category: string;
    Description: string;
    YAML: string;
  end;

  PTemplateList = ^TTemplateList;

  TTemplateList = class(TList<TTemplate>)
    FXMLDoc: IXMLDocument;
    constructor Create(const AFileName: string);
    procedure Refresh;
    procedure RetrieveTemplates(S: TStrings; const Category: string; const Filter: string); overload;
    procedure RetrieveTemplates(S: TListItems; const Category: string; const Filter: string); overload;
    procedure RetrieveCategories(S: TStrings);
    function IndexOfName(const AName: string): NativeInt;
  end;

var
  ProjectList: TProjectList;
  TemplateList: TTemplateList;

var
  ESPHomeFile: string = '';
  TemplateFile: string = '';

var
  ConfigIniFile: TIniFile = nil;


//function ShortFileName(const LongFileName: string): string;
function FindFileInPath(const FileName: string): string;
procedure DownloadTemplateFileFromGitHub;
procedure GetEnvironmentVars(List: TStrings);
function GetBit(const Value: Int64; BitPos: ShortInt): Boolean;
function SetBit(const Value: Int64; BitPos: ShortInt; State: Boolean): Int64;

function IsPIDRunning(PID: DWORD): Boolean;
function KillProcessByPID(PID: DWORD): Boolean;
function KillProcessTree(PID: DWORD): Boolean;
function GetMainWindowHandleByPID(const TargetPID: DWORD; Timeout: Integer = 3000): HWND;

//function HasToolbarIcon(const IconData: TToolbarIconsWithDarkMode): Boolean;
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
  ESPHomePlugin, SysUtils, System.StrUtils, Neslib.Yaml, TDMB, Vcl.Dialogs, Vcl.Controls, Xml.XMLDoc, System.IOUtils, System.NetEncoding, System.Net.HttpClient,
  System.Net.HttpClientComponent, TlHelp32, System.UIConsts, Winapi.Messages;

constructor TProject.Create(const AFileName: string);
var
  Index: Integer;
  Doc: IYamlDocument;
  Name: string;
  SubstitutionMap: TDictionary<string, string>;

  function Substitute(const Value: string): string;
  var
    Pair: TPair<string, string>;
    ResultString, Replacement: string;
  begin
    ResultString := Value;
    repeat
      Result := ResultString;
      for Pair in SubstitutionMap do
      begin
        Replacement := '$' + Pair.Key;
        if ContainsText(ResultString, Replacement) then
          ResultString := ResultString.Replace(Replacement, Pair.Value, [rfReplaceAll, rfIgnoreCase]);
        Replacement := '${' + Pair.Key + '}';
        if ContainsText(ResultString, Replacement) then
          ResultString := ResultString.Replace(Replacement, Pair.Value, [rfReplaceAll, rfIgnoreCase]);
      end;
    until ResultString = Result;
  end;

  function FindMicrocontroller: string;
  const
    Microcontrollers: array[0..6] of string = ('esp32', 'esp8266', 'bk72xx', 'ln882x', 'rp2040', 'rtl87xx', 'host');
  var
    Microcontroller: string;
  begin
    Result := '';
    for Microcontroller in Microcontrollers do
      if Doc.Root.Values[Microcontroller].NodeType <> TYamlNodeType.Null then
        Exit(Microcontroller);
  end;

begin
  FValid := False;
  FOptionDeps := TStringList.Create(dupIgnore, true, False);
  Name := ExpandFileName(AFileName);
  if FileExists(Name) then
  begin
    Doc := TYamlDocument.Load(Name);
    if Assigned(Doc) then
    begin
      SubstitutionMap := TDictionary<string, string>.Create;
      for Index := 0 to Doc.Root.Values['substitutions'].Count - 1 do
        SubstitutionMap.Add(Doc.Root.Values['substitutions'].Elements[Index].Key, Doc.Root.Values['substitutions'].Elements[Index].Value);
      FName := Substitute(Doc.Root.Values['esphome'].Values['name'].ToString());
      if (FName <> '') then
      begin
        FFileName := AFileName;
        FFriendlyName := Substitute(Doc.Root.Values['esphome'].Values['friendly_name'].ToString());
        FMicrocontroller := FindMicrocontroller;
        FBoard := Substitute(Doc.Root.Values[FMicrocontroller].Values['board'].ToString());
        FFramework := Substitute(Doc.Root.Values[FMicrocontroller].Values['framework'].Values['type'].ToString());
        FHasWiFi := Doc.Root.Values['wifi'].NodeType <> TYamlNodeType.Null;
        FHasWebServer := Doc.Root.Values['web_server'].NodeType <> TYamlNodeType.Null;
        FValid := FMicrocontroller <> '';
        LoadOptionDependencies;
      end;
      SubstitutionMap.Free;
    end;
  end;
end;

function TProject.GetFriendlyName: string;
begin
  if FFriendlyName <> '' then
    Result := FFriendlyName
  else
    Result := FName;
end;

function TProject.GetUIName: string;
begin
  Result := Format('%s - ("%s" in "%s")', [FriendlyName, ExtractFileName(FileName), ExtractFilePath(FileName)]);
end;

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

function TProject.GetDescription: string;

  function SetupString(AText, ALabel, AContent: string): string;
  begin
    if AContent <> '' then
    begin
      if AText <> '' then
        AText := AText + #13#10;
      AText := AText + ALabel + ': ' + AContent + '';
    end;
    Result := AText;
  end;

begin
  Result := SetupString('', rsFieldName, Self.Name);
  Result := SetupString(Result, rsFieldFriendlyName, Self.FriendlyName);
  Result := SetupString(Result, rsFieldMicrocontroller, Self.Microcontroller);
  Result := SetupString(Result, rsFieldBoard, Self.Board);
  Result := SetupString(Result, rsFieldFramework, Self.Framework);
  Result := SetupString(Result, rsFieldFileName, ExtractFileName(FileName));
  Result := SetupString(Result, rsFieldPath, ExtractFilePath(FileName));
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

procedure TProject.LoadOptionDependencies;
var
  I, Count: Integer;
  R: string;
begin
  if Assigned(ConfigIniFile) then
  begin
    FOptionDeps.Clear;
    Count := GetOption(csKeyDependenciesCount, 0);
    for I := 0 to Count - 1 do
    begin
      R := GetOption(Format(csKeyDependencyPrefix + '%d', [I]), csDefaultEmpty);
      if R <> csDefaultEmpty then
        FOptionDeps.Add(R);
    end;
  end;
end;

procedure TProject.SaveOptionDependencies;
var
  S: string;
  I: Integer;
  SList: TStringList;
begin
  if Assigned(ConfigIniFile) then
  begin
    SList := TStringList.Create;
    ConfigIniFile.ReadSection(FileName, SList);
    for S in SList do
      if SameText(csKeyDependencyPrefix, LeftStr(S, Length(csKeyDependencyPrefix))) then
        ConfigIniFile.DeleteKey(FileName, S);
    SList.Free;
    SetOption(csKeyDependenciesCount, FOptionDeps.Count);
    for I := 0 to FOptionDeps.Count - 1 do
      SetOption(Format(csKeyDependencyPrefix + '%d', [I]), FOptionDeps[I]);
  end;
end;

constructor TProjectList.Create;
begin
  FCurrent := nil;
  inherited Create(True);
  LoadConfig;
end;

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
    ConfigIniFile.DeleteKey(csSectionGeneral, csKeyCurrentProject);
  end;
end;

function TProjectList.GetCurrent: TProject;
begin
  if not Assigned(FCurrent) then
    FCurrent := GetProjectFromFileName(ConfigIniFile.ReadString(csSectionGeneral, csKeyCurrentProject, csDefaultEmpty));
  Result := FCurrent;
end;

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
    if FileName <> csSectionGeneral then
    begin
      Project := TProject.Create(FileName);
      if Project.IsValid then
        Self.Add(Project)
      else
        Project.Free;
    end;
  end;
  Sections.Free;
end;

procedure TProjectList.SaveConfig;
var
  Project: TProject;
  Sections: TStringList;
  FileName: string;
begin
  for Project in Self do
    if Project.IsValid then
      Project.SetOption(csKeyNppAutosave, Project.GetOption(csKeyNppAutosave, ciAutoSaveProjectAndDeps))
    else
      ConfigIniFile.EraseSection(Project.FileName);

  // Elimino eventuali sezioni rimaste nel file ini
  Sections := TStringList.Create;
  ConfigIniFile.ReadSections(Sections);
  for FileName in Sections do
    if (FileName <> csSectionGeneral) and (Self.GetProjectFromFileName(FileName) = nil) then
      ConfigIniFile.EraseSection(FileName);
  Sections.Free;
end;

function TProjectList.GetProjectFromFileName(const FileName: string; const IncludeDeps: boolean = False): TProject;
var
  S: string;
  P: TProject;
begin
  Result := nil;
  for P in Self do
  begin
    if SameText(P.FileName, ExpandFileName(FileName)) then
    begin
      Result := P;
      Exit;
    end;
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

constructor TTemplateList.Create(const AFileName: string);
begin
  inherited Create;
  if not FileExists(TemplateFile) then
  begin
    if TD(rsTemplatesNotFound).WindowCaption(rsMessageBoxWarning).Text(rsTemplatesNotFound2).Warning.YesNo.SetFlags([tfAllowDialogCancellation]).Execute(nil) =
      mrYes then
    begin
      DownloadTemplateFileFromGitHub;
      TD(rsTemplatesXMLDownloaded).WindowCaption(rsMessageBoxInfo).Info.OK.SetFlags([tfAllowDialogCancellation]).Execute(nil);
    end
    else
      TFile.Create(TemplateFile);
  end;
  if FileExists(AFileName) then
  begin
    FXMLDoc := TXMLDocument.Create(nil);
    FXMLDoc.FileName := AFileName;
    Refresh;
  end;
end;

resourcestring
  rsErrorReadingTemplateFile = 'The following error has been encountered reading the XML Template file:';

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
        for Index := 0 to RootNode.ChildNodes.Count - 1 do
        begin
          Template.Name := RootNode.ChildNodes[Index].ChildNodes['Name'].Text;
          Template.Category := RootNode.ChildNodes[Index].ChildNodes['Category'].Text;
          Template.Description := RootNode.ChildNodes[Index].ChildNodes['Description'].Text;
          Template.YAML := TNetEncoding.HTML.Decode(RootNode.ChildNodes[Index].ChildNodes['YAML'].Text);
          if Self.IndexOfName(Template.Name) < 0 then
            Self.Add(Template);
        end;
    except
      on E: Exception do
        TD(rsErrorReadingTemplateFile).Text(Format('%s', [E.Message])).WindowCaption(rsMessageBoxError).Error.OK.SetFlags([tfAllowDialogCancellation]).Execute(nil);
    end;
  end;
end;

procedure TTemplateList.RetrieveTemplates(S: TStrings; const Category: string; const Filter: string);
var
  Item: string;
  List: TStringList;
  Template: TTemplate;
begin
  S.Clear;
  List := TStringList.Create(dupIgnore, True, False);
  for Template in Self do
    if ((Category = '') or (Category = rsAnyCategory) or (Template.Category = Category)) and ((Filter = '') or ContainsText(Template.Name, Filter)) then
      List.Add(Format('%s [%s]', [Template.Name, Template.Category]));
  for Item in List do
    S.Add(Item);
  List.Free;
end;

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

function IsPIDRunning(PID: DWORD): Boolean;
var
  Res: DWORD;
  hProcess: THandle;
begin
  Result := False;
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION, False, PID);
  if hProcess <> 0 then
  try
    Result := GetExitCodeProcess(hProcess, Res);
    Result := Result and (Res = STILL_ACTIVE);
  finally
    CloseHandle(hProcess);
  end;
end;

function KillProcessByPID(PID: DWORD): Boolean;
var
  hProcess: THandle;
begin
  Result := False;
  hProcess := OpenProcess(PROCESS_TERMINATE, False, PID);
  if hProcess <> 0 then
  try
    Result := TerminateProcess(hProcess, 0);
  finally
    CloseHandle(hProcess);
  end;
end;

function KillProcessTree(PID: DWORD): Boolean;
var
  hSnap: THandle;
  pe: TProcessEntry32;
begin
  hSnap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if hSnap <> INVALID_HANDLE_VALUE then
  try
    pe.dwSize := SizeOf(pe);
    if Process32First(hSnap, pe) then
      repeat
        if (pe.th32ParentProcessID = PID) then
          KillProcessTree(pe.th32ProcessID);
      until not Process32Next(hSnap, pe);
  finally
    CloseHandle(hSnap);
  end;
  Result := KillProcessByPID(PID);
end;

// Structure to pass data to the callback function
type
  PFindWindowRecord = ^TFindWindowRecord;

  TFindWindowRecord = record
    PID: DWORD;
    FoundHWND: HWND;
  end;

// Callback function for EnumWindows
function EnumWindowsCallback(Handle: HWND; lParam: lParam): BOOL; stdcall;
var
  WindowPID: DWORD;
  SearchRec: PFindWindowRecord;
begin
  Result := True; // Default, continue enumeration
  SearchRec := PFindWindowRecord(lParam);
  GetWindowThreadProcessId(Handle, @WindowPID); // Gets the PID of the current window
  if (WindowPID = SearchRec^.PID) //and (GetWindow(Handle, GW_OWNER) = 0)
    then // If PID matches, check if it's the main window
  begin
    SearchRec^.FoundHWND := Handle;
    Result := False; // Stop enumeration (faster)
  end;
end;

function GetMainWindowHandleByPID(const TargetPID: DWORD; Timeout: Integer = 3000): HWND;
var
  SearchRec: TFindWindowRecord;
begin
  SearchRec.PID := TargetPID;
  SearchRec.FoundHWND := 0;
  EnumWindows(@EnumWindowsCallback, lParam(@SearchRec));
  while (SearchRec.FoundHWND = 0) and (Timeout > 0) do
  begin
    Sleep(50);
    Dec(Timeout, 50);
    EnumWindows(@EnumWindowsCallback, lParam(@SearchRec));
  end;
  Result := SearchRec.FoundHWND;
end;

procedure GetEnvironmentVars(List: TStrings);
var
  EnvBlock: PChar;
  P: PChar;
begin
  List.Clear;
  EnvBlock := GetEnvironmentStrings;
  try
    P := EnvBlock;
    while P^ <> #0 do
    begin
      List.Add(P);
      Inc(P, lstrlen(P) + 1);
    end;
  finally
    FreeEnvironmentStrings(EnvBlock);
  end;
end;

function FindFileInPath(const FileName: string): string;
var
  Buffer: array[0..MAX_PATH - 1] of WideChar;
  BufferSize: DWORD;
  FilePart: LPWSTR;
begin
  Result := '';
  FilePart := nil;
  BufferSize := SearchPath(nil, PChar(FileName), nil, MAX_PATH, Buffer, FilePart);
  if BufferSize > 0 then
    Result := StrPas(Buffer);
end;

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

procedure DownloadTemplateFileFromGitHub;
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  FileStream: TFileStream;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    Response := HTTP.Get(rsTemplatesGitHubUrl);
    FileStream := TFileStream.Create(TemplateFile, fmCreate);
    try
      Response.ContentStream.Position := 0;
      FileStream.CopyFrom(Response.ContentStream, Response.ContentStream.Size);
    finally
      FileStream.Free;
    end;
  finally
    HTTP.Free;
  end;
end;

function HasToolbarIcon(const IconData: TToolbarIconsWithDarkMode): Boolean;
begin
  Result := (IconData.ToolbarBmp <> 0) or (IconData.ToolbarIcon <> 0) or (IconData.ToolbarIconDarkMode <> 0);
end;

function CreateIconFromBitmap(Bitmap: Vcl.Graphics.TBitmap): HICON;
var
  IconInfo: TIconInfo;
begin
  FillChar(IconInfo, SizeOf(IconInfo), 0);
  IconInfo.fIcon := True;
  IconInfo.hbmMask := Bitmap.Handle;
  IconInfo.hbmColor := Bitmap.Handle;
  Result := CreateIconIndirect(IconInfo);
end;

procedure ConvertBitmapToBlack(Bitmap: Vcl.Graphics.TBitmap);
var
  x, y: Integer;
  P: PRGBQuad;
begin
  Bitmap.PixelFormat := pf32bit;
  for y := 0 to Bitmap.Height - 1 do
  begin
    P := Bitmap.ScanLine[y];
    for x := 0 to Bitmap.Width - 1 do
    begin
      if P^.rgbReserved > 0 then // Alpha channel
      begin
        P^.rgbRed := 0;
        P^.rgbGreen := 0;
        P^.rgbBlue := 0;
      end;
      Inc(P);
    end;
  end;
end;

procedure ConvertBitmapToDisabled(Bitmap: Vcl.Graphics.TBitmap);
var
  x, y: Integer;
  P: PRGBQuad;
  Gray: Byte;
begin
  // Assicuriamoci che la bitmap sia a 32-bit (ARGB)
  Bitmap.PixelFormat := pf32bit;

  for y := 0 to Bitmap.Height - 1 do
  begin
    P := Bitmap.ScanLine[y];
    for x := 0 to Bitmap.Width - 1 do
    begin
      // Elaboriamo solo i pixel che non sono completamente trasparenti
      if P^.rgbReserved > 0 then
      begin
        // 1. Calcola il livello di grigio usando la formula della luminanza (NTSC)
        // (Rosso * 0.3 + Verde * 0.59 + Blu * 0.11) ottimizzata per interi
        //Gray := (P^.rgbRed * 77 + P^.rgbGreen * 150 + P^.rgbBlue * 29) shr 8;
        Gray := (P^.rgbRed * 60 + P^.rgbGreen * 100 + P^.rgbBlue * 20) shr 8;

        // 2. Applica il grigio a tutti i canali colore
        P^.rgbRed   := Gray;
        P^.rgbGreen := Gray;
        P^.rgbBlue  := Gray;

        // 3. EFFETTO DISABILITATO (Opzionale ma consigliato):
        // Dimezziamo l'opacità per renderla sbiadita (washed-out),
        // tipico delle icone disabilitate nelle toolbar di Windows.
        P^.rgbReserved := P^.rgbReserved div 2;
      end;

      Inc(P); // Passa al pixel successivo
    end;
  end;
end;


procedure ReplaceBitmapHue(ABitmap: Vcl.Graphics.TBitmap; const SourceColor: TAlphaColor; const TargetColor: TAlphaColor; const HueTolerance: Single = 30 / 360;
  const MinSaturation: Single = 0.15);
type
  PRGBQuadArray = ^TRGBQuadArray;

  TRGBQuadArray = array[0..MaxInt div SizeOf(TRGBQuad) - 1] of TRGBQuad;

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
        C := TAlphaColor($FF000000) or (TAlphaColor(P.rgbRed) shl 16) or (TAlphaColor(P.rgbGreen) shl 8) or TAlphaColor(P.rgbBlue);
        RGBtoHSL(C, H, S, L);
        if (S >= MinSaturation) and (HueDistance(H, SourceH) <= HueTolerance) then
        begin
          NewC := HSLtoRGB(TargetH, S, L);
          Row[X].rgbRed := TAlphaColorRec(NewC).R;
          Row[X].rgbGreen := TAlphaColorRec(NewC).G;
          Row[X].rgbBlue := TAlphaColorRec(NewC).B;
        end;
      end;
    end;
  end;
end;

procedure PopulateBlackImageCollection(ASource, ADest: TImageCollection);
var
  I, J: Integer;
  SrcItem, DstItem: TImageCollectionItem;
  SrcImg, DstImg: TImageCollectionSourceItem;
  Bmp: TBitmap;
begin
  ADest.Images.BeginUpdate;
  try
    ADest.Images.Clear;
    for I := 0 to ASource.Images.Count - 1 do
    begin
      SrcItem := ASource.Images.Items[I];
      DstItem := ADest.Images.Add;
      DstItem.Name := SrcItem.Name;
      DstItem.Description := SrcItem.Description;
      for J := 0 to SrcItem.SourceImages.Count - 1 do
      begin
        SrcImg := SrcItem.SourceImages.Items[J];
        Bmp := TBitmap.Create;
        try
          Bmp.Assign(SrcImg.Image);
          Bmp.AlphaFormat := afDefined;
          Bmp.PixelFormat := pf32bit;
          ConvertBitmapToBlack(Bmp);
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
    AssignImageResources(Images);
    Images.AutoFill := True;
    Images.GetIcon(Images.GetIndexByName(csIconWindow), Icon);
    AIcon.Assign(Icon);
  finally
    Icon.Free;
    Images.Free;
  end;
end;

procedure AssignImageResources(AVirtualImage: TVirtualImage); overload;
begin
  if Plugin.IsDarkModeEnabled then
    AVirtualImage.ImageCollection := Resources.StandardImages
  else
    AVirtualImage.ImageCollection := Resources.LightModeImages;
end;

procedure AssignImageResources(AVirtualImageList: TVirtualImageList);
begin
  if Plugin.IsDarkModeEnabled then
    AVirtualImageList.ImageCollection := Resources.StandardImages
  else
    AVirtualImageList.ImageCollection := Resources.LightModeImages;
end;

function GetBit(const Value: Int64; BitPos: ShortInt): Boolean;
begin
  Result := (Value and (1 shl BitPos)) <> 0;
end;

function SetBit(const Value: Int64; BitPos: ShortInt; State: Boolean): Int64;
begin
  Result := (Value and not (1 shl BitPos)) or (Ord(State) shl BitPos);
end;

end.

