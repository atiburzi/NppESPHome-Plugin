{
    Base class for Notepad++ plugin dialog development.

    The content of this file was originally provided by Damjan Zobo Cvetko
    Modified by Andreas Heim for using in the plugin framework for Delphi.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
}

unit Npp.Vcl.Forms;


interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Math, System.Types,
  System.Classes, Vcl.Controls, Vcl.Forms,
  Npp.Api, Npp.Plugin;

type
  TNppPluginForm = class(TForm)
  private
    FRegistered: Boolean;
    FThemeInitialized: Boolean;
    FApplicationAttached: Boolean;
    function CanRegister: Boolean;
    procedure AttachApplication;
    procedure DetachApplication;

  protected
    procedure CreateParams(var Params: TCreateParams); override;

    procedure DoCreate; override;
    procedure DoClose(var Action: TCloseAction); override;

    procedure RegisterForm();
    procedure UnregisterForm();

  public
    ParentPlugin: TNppPlugin;
    DefaultCloseAction: TCloseAction;

    constructor Create(ParentPlugin: TNppPlugin); reintroduce; overload; virtual;
    constructor Create(AOwner: TNppPluginForm); reintroduce; overload; virtual;
    constructor CreateRuntime(ParentPlugin: TNppPlugin;
      Dummy: Integer); virtual;
    destructor Destroy; override;

    procedure InitLanguage; virtual;
    procedure ToggleDarkMode; virtual;
    procedure SubclassAndTheme(DmFlag: TNppDarkMode); virtual;

    function WantChildKey(Child: TControl; var Message: TMessage): Boolean; override;

  end;

  // Generic name for plugins that do not want the historical prefix.
  TNppForm = TNppPluginForm;

implementation

var
  VclAttachmentCount: Integer;
  PreviousApplicationHandle: HWND;

procedure TNppPluginForm.AttachApplication;
begin
  if FApplicationAttached then
    Exit;
  if not Assigned(ParentPlugin) then
    Exit;
  if VclAttachmentCount = 0 then
  begin
    PreviousApplicationHandle := Application.Handle;
    Application.Handle := ParentPlugin.NppData.NppHandle;
  end;
  Inc(VclAttachmentCount);
  FApplicationAttached := True;
end;

procedure TNppPluginForm.DetachApplication;
begin
  if not FApplicationAttached then
    Exit;
  FApplicationAttached := False;
  if VclAttachmentCount > 0 then
    Dec(VclAttachmentCount);
  if VclAttachmentCount = 0 then
  begin
    if Assigned(ParentPlugin) and
      (Application.Handle = ParentPlugin.NppData.NppHandle) then
      Application.Handle := PreviousApplicationHandle;
    PreviousApplicationHandle := 0;
  end;
end;

// Constructor for main dialogs
constructor TNppPluginForm.Create(ParentPlugin: TNppPlugin);
begin
  if not Assigned(ParentPlugin) then
    raise EArgumentNilException.Create('ParentPlugin');
  Self.ParentPlugin := ParentPlugin;
  DefaultCloseAction := caNone;
  FThemeInitialized := False;
  FRegistered := False;
  FApplicationAttached := False;
  AttachApplication;
  try
    inherited Create(nil);
  except
    DetachApplication;
    raise;
  end;
  ParentWindow := ParentPlugin.NppData.NppHandle;
  RegisterForm();
  if ParentPlugin.IsNppMinVersion(8, 410) then
    ToggleDarkMode;
end;

// Constructor for sub dialogs
constructor TNppPluginForm.Create(AOwner: TNppPluginForm);
begin
  if not Assigned(AOwner) then
    raise EArgumentNilException.Create('AOwner');
  ParentPlugin := AOwner.ParentPlugin;
  DefaultCloseAction := caNone;
  FThemeInitialized := False;
  FRegistered := False;
  FApplicationAttached := False;
  AttachApplication;
  try
    inherited Create(AOwner);
  except
    DetachApplication;
    raise;
  end;
  if ParentPlugin.IsNppMinVersion(8, 410) then
    ToggleDarkMode;
end;

constructor TNppPluginForm.CreateRuntime(ParentPlugin: TNppPlugin;
  Dummy: Integer);
begin
  if not Assigned(ParentPlugin) then
    raise EArgumentNilException.Create('ParentPlugin');
  Self.ParentPlugin := ParentPlugin;
  DefaultCloseAction := caNone;
  FThemeInitialized := False;
  FRegistered := False;
  FApplicationAttached := False;
  AttachApplication;
  try
    inherited CreateNew(nil);
  except
    DetachApplication;
    raise;
  end;
  ParentWindow := ParentPlugin.NppData.NppHandle;
  RegisterForm;
  if ParentPlugin.IsNppMinVersion(8, 410) then
    ToggleDarkMode;
end;

destructor TNppPluginForm.Destroy;
begin
  try
    UnregisterForm();
    inherited;
  finally
    DetachApplication;
  end;
end;


// Register plugin's dialog in Notepad++
procedure TNppPluginForm.RegisterForm();
begin
  if not CanRegister then
    Exit;
  FRegistered := ParentPlugin.Host.SendNpp(NPPM_MODELESSDIALOG,
    MODELESSDIALOGADD, Handle) <> 0;
end;



// Unregister plugin's dialog in Notepad++
procedure TNppPluginForm.UnregisterForm();
begin
  if not FRegistered then
    Exit;
  if CanRegister then
    ParentPlugin.Host.SendNpp(NPPM_MODELESSDIALOG,
      MODELESSDIALOGREMOVE, Handle);
  FRegistered := False;
end;

function TNppPluginForm.CanRegister: Boolean;
begin
  Result := (Assigned(ParentPlugin) and IsWindow(ParentPlugin.NppData.NppHandle) and Self.HandleAllocated);
end;

// Set caption of GUI controls
procedure TNppPluginForm.InitLanguage;
begin
  // override
end;

// Remove WS_CHILD window style to allow the Notepad++ UI to get visible
// when the task bar icon of Notepad++ has been clicked
procedure TNppPluginForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style and (not WS_CHILD);
end;

// Ensure correct placement of plugin dialogs
procedure TNppPluginForm.DoCreate;
var
  ParentHandle: HWND;
  ParentRect: TRect;
  TargetRect: TRect;
  MonitorRect: TRect;
  WorkareaRect: TRect;
  CurMonitor: TMonitor;
begin
  ParentHandle := ParentWindow;
  if (ParentHandle = 0) and Assigned(ParentPlugin) then
    ParentHandle := ParentPlugin.NppData.NppHandle;

  if (ParentHandle <> 0) and GetWindowRect(ParentHandle, ParentRect) then
  begin
    TargetRect := Bounds(Max(ParentRect.Left, (ParentRect.Left + ParentRect.Right - Width) div 2), Max(ParentRect.Top, (ParentRect.Top + ParentRect.Bottom -
      Height) div 2), Width, Height);

    CurMonitor := Screen.MonitorFromRect(TargetRect);
    MonitorRect := CurMonitor.BoundsRect;
    WorkareaRect := CurMonitor.WorkareaRect;

    TargetRect.Location := Point(EnsureRange(TargetRect.Left, MonitorRect.Left, IfThen(CurMonitor.Primary, WorkareaRect.Right, MonitorRect.Right) - TargetRect.Width),
      EnsureRange(TargetRect.Top, MonitorRect.Top, IfThen(CurMonitor.Primary, WorkareaRect.Bottom, MonitorRect.Bottom) - TargetRect.Height));

    BoundsRect := TargetRect;
  end;
  inherited;
end;

// Perform close action according to plugin's needs
procedure TNppPluginForm.DoClose(var Action: TCloseAction);
begin
  if (DefaultCloseAction <> caNone) then
    Action := DefaultCloseAction;
  inherited;
end;

procedure TNppPluginForm.ToggleDarkMode;
var
  DmFlag: TNppDarkMode;
begin
  if FThemeInitialized then
    DmFlag := dmfHandleChange
  else
  begin
    DmFlag := dmfInit;
    FThemeInitialized := True;
  end;
  if Assigned(ParentPlugin) and ParentPlugin.IsNppMinVersion(8, 540) then
    SubclassAndTheme(DmFlag);
end;

procedure TNppPluginForm.SubclassAndTheme(DmFlag: TNppDarkMode);
begin
  if Assigned(ParentPlugin) and HandleAllocated then
    ParentPlugin.Host.SendNpp(NPPM_DARKMODESUBCLASSANDTHEME,
      WPARAM(DmFlag), LPARAM(Self.Handle));
end;

// This is going to help us solve the problems we are having because of N++ handling our messages
function TNppPluginForm.WantChildKey(Child: TControl; var Message: TMessage): Boolean;
begin
  Result := Assigned(Child) and
    (Child.Perform(CN_BASE + Message.Msg, Message.WParam, Message.LParam) <> 0);
end;


end.
