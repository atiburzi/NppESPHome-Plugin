{******************************************************************************}
{                                                                              }
{ Rejbrand Task Dialog Message Box                                             }
{                                                                              }
{ Copyright © 2021–2025 Andreas Rejbrand                                       }
{                                                                              }
{ https://specials.rejbrand.se/dev/classes/TDMessageBox/TDMessageBox.html      }
{                                                                              }
{******************************************************************************}

unit TDMB;

interface

uses
  Windows, Messages, SysUtils, Types, UITypes, Classes, Dialogs, Forms, Graphics;

type
  TNotifyEventRef = reference to procedure(Sender: TObject);
  TTaskDialogButtonRec = record
    Caption: string;
    ModalResult: TModalResult;
    Default: Boolean;
    Enabled: Boolean;
  end;
  TDetailsPosition = (dpMain, dpFooter);
  TLinkHandler = reference to procedure(const AURL: string);
  PMsgBox = ^TMsgBox;
  TMsgBox = record
  strict private
    FOwner: HWND;
    FCaption,
    FMainText,
    FSecondText,
    FDetailsCaption,
    FDetailsText: string;
    FDetailsPosition: TDetailsPosition;
    FDetailsExpanded: Boolean;
    FIcon: TTaskDialogIcon;
    FCustomIcon: TIcon;
    FButtons: TTaskDialogCommonButtons;
    FDefButton: TTaskDialogCommonButton;
    FCustomButtons: TArray<TTaskDialogButtonRec>;
    FFooterText: string;
    FFooterIcon: TTaskDialogIcon;
    FCustomFooterIcon: TIcon;
    FVerificationText: string;
    FVerificationChecked: Boolean;
    FVerificationCheckedRes: PBoolean;
    FFlags: TTaskDialogFlags;
    FHyperlinks: Boolean;
    FRadioButtons: TArray<string>;
    FDefRadioButton: Integer;
    FLinkHandler: TLinkHandler;
    FRadioOut: Integer;
    FVerificationClicked: TNotifyEventRef;
    procedure HyperlinkClicked(Sender: TObject);
    procedure VerificationClicked(Sender: TObject);
    procedure MOPDialogCreated(Sender: TObject);
  public
    const DefaultFlags = [tfAllowDialogCancellation, tfPositionRelativeToWindow];
    function Execute(AOwnerForm: TCustomForm = nil): TModalResult; overload;
    function Execute(out ARadioButton: Integer; AOwnerForm: TCustomForm = nil): TModalResult; overload;
    function Text(const AText: string): TMsgBox;
    function TextFmt(const AText: string; const Args: array of const): TMsgBox;
    function Info: TMsgBox;
    function Warning: TMsgBox;
    function Error: TMsgBox;
    function Shield: TMsgBox;
    function CustomIcon(AIcon: TIcon): TMsgBox;
    function WindowCaption(const AText: string): TMsgBox;
    function Details(const AText: string; APosition: TDetailsPosition = dpMain;
      const ACaption: string = ''; AExpanded: Boolean = False): TMsgBox;
    function Footer(const AText: string; AIcon: TTaskDialogIcon = tdiNone;
      ACustomIcon: TIcon = nil): TMsgBox;
    function Verification(const AText: string; AChecked: PBoolean;
      ACallback: TNotifyEventRef = nil): TMsgBox;
    function Hypertext(ALinkHandler: TLinkHandler = nil): TMsgBox;
    function Close: TMsgBox;
    function OK: TMsgBox;
    function OKCancel: TMsgBox;
    function YesNo: TMsgBox;
    function YesNoCancel: TMsgBox;
    function AddButton(const ACaption: string; AModalResult: TModalResult;
      ADefault: Boolean = False; AEnabled: Boolean = True): TMsgBox;
    function DefButton(AButton: TTaskDialogCommonButton): TMsgBox;
    function AddRadioButton(const ACaption: string): TMsgBox;
    function AddRadioButtons(const ACaptions: array of string): TMsgBox;
    function DefRadioButton(AIndex: Integer): TMsgBox;
    function SetFlags(AFlags: TTaskDialogFlags): TMsgBox;
    function AddFlag(AFlag: TTaskDialogFlag): TMsgBox;
    function ClearFlag(AFlag: TTaskDialogFlag): TMsgBox;
  end;

function TD(const AText: string = ''): TMsgBox; overload;
function TD(E: Exception): TMsgBox; overload;

var
  // The Win32 task dialog supports the TDF_POSITION_RELATIVE_TO_WINDOW flag
  // for the dwFlags member of TASKDIALOGCONFIG. This makes the dialog centre
  // above the specified hwndParent. However, if the specified hwndParent is
  // a TForm that is a child of a different window, the VCL's focus state may
  // become out of sync with reality (the actual Win32 keyboard focus). If you
  // want the TDF_POSITION_RELATIVE_TO_WINDOW behaviour in such a scenario, you
  // need to skip the TDF_POSITION_RELATIVE_TO_WINDOW mechanism and instead
  // position the task dialog manually, which is what happens if the global
  // TDMB_ManualOwnerPos variable is set to True.
  TDMB_ManualOwnerPos: Boolean;

implementation

uses
  Math, DateUtils, StrUtils, ShellAPI;

type
  TTaskDialog2 = class(Dialogs.TTaskDialog)
  private
    FMsgBoxData: PMsgBox;
  end;

function TD(const AText: string): TMsgBox;
begin
  Result := Default(TMsgBox).SetFlags(TMsgBox.DefaultFlags).Text(AText);
end;

function IsSevereError(E: Exception): Boolean;
begin
  Result := (E is EExternal) or (E is EHeapException) or (E is EInvalidCast);
end;

function TD(E: Exception): TMsgBox;
resourcestring
  SExceptionClassNameValue = 'Exception class: %s';
begin
  Result := TD(E.Message).Details(Format(SExceptionClassNameValue, [E.ClassName]), dpFooter);
  if IsSevereError(E) then
    Result := Result.Error;
end;

{ TMsgBox }

function TMsgBox.AddButton(const ACaption: string;
  AModalResult: TModalResult; ADefault, AEnabled: Boolean): TMsgBox;
begin
  Result := Self;
  SetLength(Result.FCustomButtons, Succ(Length(Result.FCustomButtons)));
  Result.FCustomButtons[High(Result.FCustomButtons)].Caption := ACaption;
  Result.FCustomButtons[High(Result.FCustomButtons)].ModalResult := AModalResult;
  Result.FCustomButtons[High(Result.FCustomButtons)].Default := ADefault;
  Result.FCustomButtons[High(Result.FCustomButtons)].Enabled := AEnabled;
end;

function TMsgBox.AddFlag(AFlag: TTaskDialogFlag): TMsgBox;
begin
  Result := Self;
  Include(Result.FFlags, AFlag);
end;

function TMsgBox.AddRadioButton(const ACaption: string): TMsgBox;
begin
  Result := Self;
  Result.FRadioButtons := Result.FRadioButtons + [ACaption];
end;

function TMsgBox.AddRadioButtons(const ACaptions: array of string): TMsgBox;
begin
  Result := Self;
  var LOldLength := Length(Result.FRadioButtons);
  SetLength(Result.FRadioButtons, Length(Result.FRadioButtons) + Length(ACaptions));
  for var i := 0 to High(ACaptions) do
    Result.FRadioButtons[LOldLength + i] := ACaptions[i];
end;

function TMsgBox.ClearFlag(AFlag: TTaskDialogFlag): TMsgBox;
begin
  Result := Self;
  Exclude(Result.FFlags, AFlag);
end;

function TMsgBox.Close: TMsgBox;
begin
  Result := Self;
  Result.FButtons := [tcbClose];
  Result.FCustomButtons := nil;
end;

function TMsgBox.CustomIcon(AIcon: TIcon): TMsgBox;
begin
  Result := Self;
  Result.FCustomIcon := AIcon;
end;

function TMsgBox.DefButton(AButton: TTaskDialogCommonButton): TMsgBox;
begin
  Result := Self;
  Result.FDefButton := AButton;
end;

function TMsgBox.DefRadioButton(AIndex: Integer): TMsgBox;
begin
  Result := Self;
  Result.FDefRadioButton := AIndex;
  if AIndex = -1 then
    Include(Result.FFlags, tfNoDefaultRadioButton);
end;

function TMsgBox.Details(const AText: string; APosition: TDetailsPosition;
  const ACaption: string; AExpanded: Boolean): TMsgBox;
begin
  Result := Self;
  Result.FDetailsCaption := ACaption;
  Result.FDetailsText := AText;
  Result.FDetailsPosition := APosition;
  Result.FDetailsExpanded := AExpanded;
end;

function TMsgBox.Error: TMsgBox;
begin
  Result := Self;
  Result.FIcon := tdiError;
end;

function TMsgBox.Execute(out ARadioButton: Integer;
  AOwnerForm: TCustomForm): TModalResult;
begin
  Result := Execute(AOwnerForm);
  ARadioButton := FRadioOut;
end;

function TMsgBox.Execute(AOwnerForm: TCustomForm): TModalResult;
begin

  var TD := TTaskDialog2.Create(AOwnerForm);
  try
    TD.FMsgBoxData := @Self;
    if Assigned(AOwnerForm) then
      FOwner := AOwnerForm.Handle
    else
      FOwner := 0;
    TD.Flags := FFlags;
    if not FCaption.IsEmpty then
      TD.Caption := FCaption
    else
      TD.Caption := Application.Title;
    TD.Title := FMainText;
    TD.Text := FSecondText;
    TD.CommonButtons := FButtons;
    TD.DefaultButton := FDefButton;
    for var br in FCustomButtons do
    begin
      var b := TD.Buttons.Add;
      b.Caption := br.Caption;
      b.ModalResult := br.ModalResult;
      b.Default := br.Default;
      b.Enabled := br.Enabled;
    end;
    TD.ExpandButtonCaption := FDetailsCaption;
    TD.ExpandedText := FDetailsText;
    case FDetailsPosition of
      dpMain:
        TD.Flags := TD.Flags - [tfExpandFooterArea];
      dpFooter:
        TD.Flags := TD.Flags + [tfExpandFooterArea];
    end;
    case FDetailsExpanded of
      False:
        TD.Flags := TD.Flags - [tfExpandedByDefault];
      True:
        TD.Flags := TD.Flags + [tfExpandedByDefault];
    end;
    TD.MainIcon := FIcon;
    if Assigned(FCustomIcon) then
    begin
      TD.Flags := TD.Flags + [tfUseHiconMain];
      TD.CustomMainIcon := FCustomIcon;
    end
    else
      TD.Flags := TD.Flags - [tfUseHiconMain];
    TD.FooterText := FFooterText;
    TD.FooterIcon := FFooterIcon;
    if Assigned(FCustomFooterIcon) then
    begin
      TD.Flags := TD.Flags + [tfUseHiconFooter];
      TD.CustomFooterIcon := FCustomFooterIcon;
    end
    else
      TD.Flags := TD.Flags - [tfUseHiconFooter];
    TD.VerificationText := FVerificationText;
    case FVerificationChecked of
      False:
        TD.Flags := TD.Flags - [tfVerificationFlagChecked];
      True:
        TD.Flags := TD.Flags + [tfVerificationFlagChecked];
    end;
    for var rb in FRadioButtons do
    begin
      var b := TD.RadioButtons.Add;
      b.Caption := rb;
      if not (tfNoDefaultRadioButton in TD.Flags) and (FDefRadioButton = b.Index) then
        b.Default := True;
    end;
    if FHyperlinks then
    begin
      TD.Flags := TD.Flags + [tfEnableHyperlinks];
      TD.OnHyperlinkClicked := HyperlinkClicked;
    end
    else
      TD.Flags := TD.Flags - [tfEnableHyperlinks];
    TD.OnVerificationClicked := VerificationClicked;
    if (FOwner <> 0) and TDMB_ManualOwnerPos then
    begin
      TD.OnDialogCreated := MOPDialogCreated;
      Application.ModalStarted;
      try
        if TD.Execute then
          Result := TD.ModalResult
        else
          Result := mrCancel;
      finally
        Application.ModalFinished;
      end;
    end
    else if FOwner <> 0 then
    begin
      Application.ModalStarted;
      try
        if TD.Execute(FOwner) then
          Result := TD.ModalResult
        else
          Result := mrCancel;
      finally
        Application.ModalFinished;
      end;
    end
    else
    begin
      Application.ModalStarted;
      try
        if TD.Execute then
          Result := TD.ModalResult
        else
          Result := mrCancel;
      finally
        Application.ModalFinished;
      end;
    end;
    if (Length(FRadioButtons) > 0) and Assigned(TD.RadioButton) then
      FRadioOut := TD.RadioButton.Index
    else
      FRadioOut := -1;
    if Assigned(FVerificationCheckedRes) then
      FVerificationCheckedRes^ := tfVerificationFlagChecked in TD.Flags;
  finally
    TD.Free;
  end;

end;

function TMsgBox.Footer(const AText: string; AIcon: TTaskDialogIcon;
  ACustomIcon: TIcon): TMsgBox;
begin
  Result := Self;
  Result.FFooterText := AText;
  Result.FFooterIcon := AIcon;
  Result.FCustomFooterIcon := ACustomIcon;
end;

procedure TMsgBox.HyperlinkClicked(Sender: TObject);
begin
  if Sender is TTaskDialog then
  begin
    if Assigned(FLinkHandler) then
      FLinkHandler(TTaskDialog(Sender).URL)
    else
      ShellExecute(FOwner, 'open', PChar(TTaskDialog(Sender).URL), nil, nil, SW_SHOWNORMAL);
  end;
end;

function TMsgBox.Hypertext(ALinkHandler: TLinkHandler): TMsgBox;
begin
  Result := Self;
  Result.FLinkHandler := ALinkHandler;
  Result.FHyperlinks := True;
end;

function TMsgBox.Info: TMsgBox;
begin
  Result := Self;
  Result.FIcon := tdiInformation;
end;

procedure TMsgBox.MOPDialogCreated(Sender: TObject);
begin
  if TDMB_ManualOwnerPos and (Sender is TTaskDialog2) then
  begin
    const TD = TTaskDialog2(Sender);
    const TDD = TD.FMsgBoxData;
    const LOwner = TDD.FOwner;
    if LOwner <> 0 then
    begin
      var LParentRect := Default(TRect);
      var LDlgRect := Default(TRect);
      if GetWindowRect(LOwner, LParentRect) and GetWindowRect(TD.Handle, LDlgRect) then
      begin
        const P = Point(
          LParentRect.Left + (LParentRect.Width - LDlgRect.Width) div 2,
          LParentRect.Top + (LParentRect.Height - LDlgRect.Height) div 2
        );
        SetWindowPos(
          TD.Handle,
          0,
          P.X,
          P.Y,
          0,
          0,
          SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER
        );
      end;
    end;
  end;
end;

function TMsgBox.OK: TMsgBox;
begin
  Result := Self;
  Result.FButtons := [tcbOk];
  Result.FCustomButtons := nil;
end;

function TMsgBox.OKCancel: TMsgBox;
begin
  Result := Self;
  Result.FButtons := [tcbOk, tcbCancel];
  Result.FCustomButtons := nil;
end;

function TMsgBox.SetFlags(AFlags: TTaskDialogFlags): TMsgBox;
begin
  Result := Self;
  Result.FFlags := AFlags;
end;

function TMsgBox.Shield: TMsgBox;
begin
  Result := Self;
  Result.FIcon := tdiShield;
end;

function TMsgBox.Text(const AText: string): TMsgBox;
begin
  Result := Self;
  if Result.FMainText.IsEmpty then
    Result.FMainText := AText
  else if Result.FSecondText.IsEmpty then
    Result.FSecondText := AText
  else
    Result.FSecondText := Result.FSecondText + sLineBreak + sLineBreak + AText;
end;

function TMsgBox.TextFmt(const AText: string;
  const Args: array of const): TMsgBox;
begin
  Result := Text(Format(AText, Args));
end;

function TMsgBox.Verification(const AText: string; AChecked: PBoolean;
  ACallback: TNotifyEventRef): TMsgBox;
begin
  Result := Self;
  Result.FVerificationText := AText;
  Result.FVerificationCheckedRes := AChecked;
  if Assigned(AChecked) then
    Result.FVerificationChecked := AChecked^;
  Result.FVerificationClicked := ACallback;
end;

procedure TMsgBox.VerificationClicked(Sender: TObject);
begin
  if Assigned(FVerificationClicked) then
    FVerificationClicked(Sender);
end;

function TMsgBox.Warning: TMsgBox;
begin
  Result := Self;
  Result.FIcon := tdiWarning;
end;

function TMsgBox.WindowCaption(const AText: string): TMsgBox;
begin
  Result := Self;
  Result.FCaption := AText;
end;

function TMsgBox.YesNo: TMsgBox;
begin
  Result := Self;
  Result.FButtons := [tcbYes, tcbNo];
  Result.FFlags := Result.FFlags - [tfAllowDialogCancellation];
  Result.FCustomButtons := nil;
end;

function TMsgBox.YesNoCancel: TMsgBox;
begin
  Result := Self;
  Result.FButtons := [tcbYes, tcbNo, tcbCancel];
  Result.FCustomButtons := nil;
end;

end.
