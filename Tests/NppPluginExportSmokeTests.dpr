program NppPluginExportSmokeTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Winapi.Windows,
  Npp.Api in '..\Lib\Npp.Api.pas',
  Npp.Scintilla.Api in '..\Lib\Npp.Scintilla.Api.pas';

type
  TGetName = function: nppPChar; cdecl;
  TGetFuncsArray = function(out FuncCount: Integer): PFuncItem; cdecl;
  TBeNotified = procedure(Notification: PSCNotification); cdecl;
  TSetInfo = procedure(NppData: TNppData); cdecl;
  TMessageProc = function(Msg: Cardinal; WParam: WPARAM;
    LParam: LPARAM): LRESULT; cdecl;
  TIsUnicode = function: LongBool; cdecl;

procedure Check(const Condition: Boolean; const MessageText: string);
begin
  if not Condition then
    raise Exception.Create(MessageText);
end;

procedure RunTest(const DllPath: string);
var
  Module: HMODULE;
  GetName: TGetName;
  GetFuncsArray: TGetFuncsArray;
  BeNotified: TBeNotified;
  SetInfo: TSetInfo;
  MessageProc: TMessageProc;
  IsUnicode: TIsUnicode;
  FuncItems: PFuncItem;
  FuncCount: Integer;
  PluginName: nppPChar;
  Notification: TSCNotification;
begin
  Module := LoadLibrary(PChar(DllPath));
  if Module = 0 then
    RaiseLastOSError;
  try
    GetName := TGetName(GetProcAddress(Module, 'getName'));
    GetFuncsArray := TGetFuncsArray(GetProcAddress(Module, 'getFuncsArray'));
    BeNotified := TBeNotified(GetProcAddress(Module, 'beNotified'));
    SetInfo := TSetInfo(GetProcAddress(Module, 'setInfo'));
    MessageProc := TMessageProc(GetProcAddress(Module, 'messageProc'));
    IsUnicode := TIsUnicode(GetProcAddress(Module, 'isUnicode'));

    Check(Assigned(GetName), 'getName export is missing');
    Check(Assigned(GetFuncsArray), 'getFuncsArray export is missing');
    Check(Assigned(BeNotified), 'beNotified export is missing');
    Check(Assigned(SetInfo), 'setInfo export is missing');
    Check(Assigned(MessageProc), 'messageProc export is missing');
    Check(Assigned(IsUnicode), 'isUnicode export is missing');

    Check(IsUnicode(), 'isUnicode returned FALSE');
    PluginName := GetName();
    Check(PluginName <> nil, 'getName returned nil');
    Check(string(PluginName) = 'NppESPHome',
      Format('Unexpected plugin name: "%s"', [string(PluginName)]));

    FuncItems := GetFuncsArray(FuncCount);
    Check(FuncItems <> nil, 'getFuncsArray returned nil');
    Check(FuncCount > 0, 'The plugin did not expose any commands');

    FillChar(Notification, SizeOf(Notification), 0);
    Notification.nmhdr.code := NPPN_SHUTDOWN;
    BeNotified(@Notification);
  finally
    FreeLibrary(Module);
  end;
end;

begin
  try
    Check(ParamCount = 1,
      'Usage: NppPluginExportSmokeTests <path-to-NppESPHome.dll>');
    RunTest(ExpandFileName(ParamStr(1)));
    Writeln('Plugin export smoke test passed for ',
      SizeOf(Pointer) * 8, '-bit.');
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
