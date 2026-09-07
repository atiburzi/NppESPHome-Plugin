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
  Npp.Plugin in '..\Lib\Npp.Plugin.pas',
  Npp.Commands in '..\Lib\Npp.Commands.pas',
  Npp.Toolbar in '..\Lib\Npp.Toolbar.pas',
  Npp.Api in '..\Lib\Npp.Api.pas',
  Npp.MenuCmdID in '..\Lib\Npp.MenuCmdID.pas',
  Npp.Scintilla.Api in '..\Lib\Npp.Scintilla.Api.pas',
  FileVersionInfo in '..\Lib\FileVersionInfo.pas',
  NppESPHome.FormSelectProject in 'NppESPHome.FormSelectProject.pas' {FormSelection},
  NppESPHome.FormConfiguration in 'NppESPHome.FormConfiguration.pas' {FormConfiguration},
  NppESPHome.Shared in 'NppESPHome.Shared.pas',
  NppESPHome.FormAbout in 'NppESPHome.FormAbout.pas' {FormAbout},
  NppESPHome.FormProjects in 'NppESPHome.FormProjects.pas' {FormProjects},
  NppESPHome.ConPty in 'NppESPHome.ConPty.pas',
  NppESPHome.FormConsole in 'NppESPHome.FormConsole.pas' {FormConsole},
  NppESPHome.Plugin in 'NppESPHome.Plugin.pas' {Resources: TDataModule},
  NppESPHome.FormToolbar in 'NppESPHome.FormToolbar.pas' {FormToolbar},
  Npp.Vcl.Docking in '..\Lib\Npp.Vcl.Docking.pas',
  Npp.Vcl.Forms in '..\Lib\Npp.Vcl.Forms.pas',
  Npp.Host in '..\Lib\Npp.Host.pas';

{$R *.res}

var
  BasePlugin: TNppPlugin;

{$I ..\Lib\NppPluginInclude.pas}

begin
  // Propagate DLL entry point to RTL
  DLLProc := @DLLEntryPoint;
end.

