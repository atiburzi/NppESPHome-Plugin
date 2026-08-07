// NppESPHome Notepad++ plugin library entry point.
// Exports the standard Notepad++ plugin API and owns the lifetime of the concrete plugin instance.
library NppESPHome;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters.

  Important note about VCL usage: when this DLL will be implicitly
  loaded and this DLL uses TWicImage / TImageCollection created in
  any unit initialization section, then Vcl.WicImageInit must be
  included into your library's USES clause. }

{$IFNDEF DEBUG}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$ENDIF}



uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  NppPlugin in '..\Lib\NppPlugin.pas',
  NppMessages in '..\Lib\NppMessages.pas',
  NppMenuCmdID in '..\Lib\NppMenuCmdID.pas',
  NppScintilla in '..\Lib\NppScintilla.pas',
  FileVersionInfo in '..\Lib\FileVersionInfo.pas',
  NppESPHome.FormSelectProject in 'NppESPHome.FormSelectProject.pas' {FormSelection},
  NppESPHome.FormConfiguration in 'NppESPHome.FormConfiguration.pas' {FormConfiguration},
  NppESPHome.Shared in 'NppESPHome.Shared.pas',
  NppESPHome.FormAbout in 'NppESPHome.FormAbout.pas' {FormAbout},
  NppESPHome.FormToolbar in 'NppESPHome.FormToolbar.pas' {FormToolbar},
  NppESPHome.FormProjects in 'NppESPHome.FormProjects.pas' {FormProjects},
  NppESPHome.Plugin in 'NppESPHome.Plugin.pas' {Resources: TDataModule},
  NppPluginDockingForm in '..\Lib\NppPluginDockingForm.pas',
  NppPluginForm in '..\Lib\NppPluginForm.pas';

{$R *.res}

var
  BasePlugin: TNppPlugin;

// *****************************************************************************
// Purpose: Handles DLL process and thread lifecycle notifications, creating the
// plugin instance on attach and releasing it on detach.
// *****************************************************************************
procedure DLLEntryPoint(dwReason: DWord);
begin
  case dwReason of
    DLL_PROCESS_ATTACH:
      if not Assigned(BasePlugin) then
        BasePlugin := PluginClass.Create;
    DLL_PROCESS_DETACH:
      FreeAndNil(BasePlugin);
    DLL_THREAD_ATTACH:
      ;
    DLL_THREAD_DETACH:
      ;
  end;
end;

// *****************************************************************************
// Purpose: Adapts a raw Notepad++ window message to TMessage and forwards it to
// the active plugin instance.
// *****************************************************************************
function messageProc(msg: Cardinal; _wParam: WPARAM; _lParam: LPARAM): LRESULT; cdecl; export;
var
  xmsg: TMessage;
begin
  xmsg.msg := msg;
  xmsg.WPARAM := _wParam;
  xmsg.LPARAM := _lParam;
  xmsg.Result := 0;
  BasePlugin.messageProc(xmsg);
  Result := xmsg.Result;
end;

// *****************************************************************************
// Purpose: Forwards a Notepad++ or Scintilla notification to the active plugin
// instance.
// *****************************************************************************
procedure beNotified(sn: PSCNotification); cdecl; export;
begin
  BasePlugin.beNotified(sn);
end;

// *****************************************************************************
// Purpose: Supplies the Notepad++ window and Scintilla handles to the active
// plugin instance.
// *****************************************************************************
procedure setInfo(NppData: TNppData); cdecl; export;
begin
  BasePlugin.setInfo(NppData);
end;

// *****************************************************************************
// Purpose: Returns the plugin command table that Notepad++ uses to build the
// Plugins menu.
// *****************************************************************************
function getFuncsArray(out nFuncs: integer): Pointer; cdecl; export;
begin
  Result := BasePlugin.GetFuncsArray(nFuncs);
end;

// *****************************************************************************
// Purpose: Returns the plugin name exposed to Notepad++.
// *****************************************************************************
function getName(): nppPchar; cdecl; export;
begin
  Result := BasePlugin.GetName;
end;

// *****************************************************************************
// Purpose: Reports that the plugin uses the Unicode Notepad++ plugin interface.
// *****************************************************************************
function isUnicode: Boolean; cdecl; export;
begin
  Result := true;
end;

exports
  setInfo,
  getName,
  getFuncsArray,
  beNotified,
  messageProc,
  isUnicode;

begin
  // Propagate DLL entry point to RTL
  DLLProc := @DLLEntryPoint;
  // Create plugin instance
  DLLEntryPoint(DLL_PROCESS_ATTACH);
end.

