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

unit NppPluginForms;


interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Math, System.Types,
  System.Classes, Vcl.Controls, Vcl.Forms,

  NppSupport, NppPlugin;

type
  TNppPluginForm = class(TForm)
  private
    FRegistered: Boolean;
    FThemeInitialized: Boolean;
    function CanRegister: Boolean;

  protected
    procedure CreateParams(var Params: TCreateParams); override;

    procedure DoCreate; override;
    procedure DoClose(var Action: TCloseAction); override;

    procedure RegisterForm();
    procedure UnregisterForm();

  public
    Plugin: TNppPlugin;
    DefaultCloseAction: TCloseAction;

    constructor Create(ParentPlugin: TNppPlugin); reintroduce; overload; virtual;
    constructor Create(AOwner: TNppPluginForm); reintroduce; overload; virtual;
    destructor Destroy; override;

    procedure InitLanguage; virtual;
    procedure ToggleDarkMode; virtual;
    procedure SubclassAndTheme(DmFlag: TNppDarkMode); virtual;

    function WantChildKey(Child: TControl; var Message: TMessage): Boolean; override;

  end;

implementation

{$R *.dfm}

// Constructor for main dialogs
constructor TNppPluginForm.Create(ParentPlugin: TNppPlugin);
begin
  Self.Plugin := ParentPlugin;
  DefaultCloseAction := caNone;
  FThemeInitialized := False;
  FRegistered := False;
  inherited Create(nil);
  ParentWindow := Self.Plugin.NppData.NppHandle;
  RegisterForm();
  if Plugin.IsNppMinVersion(8, 410) then
    ToggleDarkMode;
end;

// Constructor for sub dialogs
constructor TNppPluginForm.Create(AOwner: TNppPluginForm);
begin
  Self.Plugin := AOwner.Plugin;
  DefaultCloseAction := caNone;
  FThemeInitialized := False;
  FRegistered := False;
  inherited Create(AOwner);
  if Plugin.IsNppMinVersion(8, 410) then
    ToggleDarkMode;
end;

destructor TNppPluginForm.Destroy;
begin
  if (HandleAllocated) then
    UnregisterForm();
  inherited;
end;


// Register plugin's dialog in Notepad++
procedure TNppPluginForm.RegisterForm();
begin
  if not CanRegister then
    exit;
  FRegistered := SendMessage(Self.Plugin.NppData.NppHandle, NPPM_MODELESSDIALOG, MODELESSDIALOGADD, Handle) <> 0;
end;

// Unregister plugin's dialog in Notepad++
procedure TNppPluginForm.UnregisterForm();
begin
  if (not FRegistered) or (not CanRegister) or (not HandleAllocated) then
    exit;
  SendMessage(Self.Plugin.NppData.NppHandle, NPPM_MODELESSDIALOG, MODELESSDIALOGREMOVE, Handle);
end;

function TNppPluginForm.CanRegister: Boolean;
begin
  Result := (Assigned(Self.Plugin) and IsWindow(self.Plugin.NppData.NppHandle) and self.HandleAllocated);
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
  ParentRect: TRect;
  TargetRect: TRect;
  MonitorRect: TRect;
  WorkareaRect: TRect;
  CurMonitor: TMonitor;
begin
  if (ParentWindow <> 0) and GetWindowRect(ParentWindow, ParentRect) then
  begin
    TargetRect := Bounds(Max(ParentRect.Left, (ParentRect.Left + ParentRect.Right - Width) div 2),
      Max(ParentRect.Top, (ParentRect.Top + ParentRect.Bottom - Height) div 2), Width, Height);

    CurMonitor := Screen.MonitorFromRect(TargetRect);
    MonitorRect := CurMonitor.BoundsRect;
    WorkareaRect := CurMonitor.WorkareaRect;

    TargetRect.Location := Point(EnsureRange(TargetRect.Left, MonitorRect.Left, IfThen(CurMonitor.Primary, WorkareaRect.Right, MonitorRect.Right) -
      TargetRect.Width), EnsureRange(TargetRect.Top, MonitorRect.Top, IfThen(CurMonitor.Primary, WorkareaRect.Bottom, MonitorRect.Bottom) - TargetRect.Height));

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
  if Assigned(Plugin) and Plugin.IsNppMinVersion(8, 540) then
    SubclassAndTheme(DmFlag);
end;

procedure TNppPluginForm.SubclassAndTheme(DmFlag: TNppDarkMode);
begin
  SendMessage(Plugin.NppData.NppHandle, NPPM_DARKMODESUBCLASSANDTHEME, WPARAM(DmFlag), LPARAM(Self.Handle));
end;

// This is going to help us solve the problems we are having because of N++ handling our messages
function TNppPluginForm.WantChildKey(Child: TControl; var Message: TMessage): Boolean;
begin
  Result := (Child.Perform(CN_BASE + Message.Msg, Message.WParam, Message.LParam) <> 0);
end;


end.
