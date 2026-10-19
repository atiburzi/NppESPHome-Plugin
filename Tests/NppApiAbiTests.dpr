program NppApiAbiTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Winapi.Windows,
  Npp.Api in '..\Lib\Npp.Api.pas',
  Npp.Scintilla.Api in '..\Lib\Npp.Scintilla.Api.pas';

procedure CheckEqual(const Name: string; const Actual, Expected: NativeUInt);
begin
  if Actual <> Expected then
    raise Exception.CreateFmt('%s: expected %d, got %d',
      [Name, Expected, Actual]);
end;

function FieldOffset(const RecordAddress, FieldAddress: Pointer): NativeUInt;
begin
  Result := NativeUInt(FieldAddress) - NativeUInt(RecordAddress);
end;

procedure CheckCommonConstants;
begin
  CheckEqual('FNITEM_NAMELEN', FNITEM_NAMELEN, 64);
  CheckEqual('SizeOf(TShortcutKey)', SizeOf(TShortcutKey), 4);
  CheckEqual('SizeOf(TNppDarkModeColors)', SizeOf(TNppDarkModeColors), 48);
  CheckEqual('Ord(L_TOML)', Ord(L_TOML), 92);
  CheckEqual('Ord(L_EXTERNAL)', Ord(L_EXTERNAL), 96);
  CheckEqual('DWS_USEOWNDARKMODE', DWS_USEOWNDARKMODE, $00000008);
  CheckEqual('SC_UPDATE_TEXT', SC_UPDATE_TEXT, $10);
  CheckEqual('SC_UPDATE_LINE_COUNT', SC_UPDATE_LINE_COUNT, $20);
  CheckEqual('SCI_GETBOOSTREGEXERRMSG', SCI_GETBOOSTREGEXERRMSG, 5000);
end;

procedure CheckRecordLayout;
var
  NppData: TNppData;
  FuncItem: TFuncItem;
  DockingData: TTbData;
  SessionInfo: TSessionInfo;
  CommunicationInfo: TCommunicationInfo;
  Notification: TSCNotification;
  TextRange: TTextRangeFull;
  TextToFind: TTextToFindFull;
begin
  if SizeOf(Pointer) = 8 then
  begin
    CheckEqual('SizeOf(TNppData)', SizeOf(TNppData), 24);
    CheckEqual('TNppData.ScintillaMainHandle',
      FieldOffset(@NppData, @NppData.ScintillaMainHandle), 8);

    CheckEqual('SizeOf(TFuncItem)', SizeOf(TFuncItem), 152);
    CheckEqual('TFuncItem.CmdID', FieldOffset(@FuncItem, @FuncItem.CmdID), 136);
    CheckEqual('TFuncItem.Checked', FieldOffset(@FuncItem, @FuncItem.Checked), 140);
    CheckEqual('TFuncItem.ShortcutKey',
      FieldOffset(@FuncItem, @FuncItem.ShortcutKey), 144);

    CheckEqual('SizeOf(TTbData)', SizeOf(TTbData), 72);
    CheckEqual('TTbData.PrevContainer',
      FieldOffset(@DockingData, @DockingData.PrevContainer), 56);
    CheckEqual('TTbData.ModuleName',
      FieldOffset(@DockingData, @DockingData.ModuleName), 64);

    CheckEqual('SizeOf(TSessionInfo)', SizeOf(TSessionInfo), 24);
    CheckEqual('TSessionInfo.Files',
      FieldOffset(@SessionInfo, @SessionInfo.Files), 16);
    CheckEqual('SizeOf(TCommunicationInfo)', SizeOf(TCommunicationInfo), 24);
    CheckEqual('TCommunicationInfo.srcModuleName',
      FieldOffset(@CommunicationInfo, @CommunicationInfo.srcModuleName), 8);

    CheckEqual('SizeOf(TNotifyHeader)', SizeOf(TNotifyHeader), 24);
    CheckEqual('SizeOf(TSCNotification)', SizeOf(TSCNotification), 160);
    CheckEqual('TSCNotification.text',
      FieldOffset(@Notification, @Notification.text), 48);
    CheckEqual('TSCNotification.characterSource',
      FieldOffset(@Notification, @Notification.characterSource), 152);

    CheckEqual('SizeOf(TTextRangeFull)', SizeOf(TTextRangeFull), 24);
    CheckEqual('SizeOf(TTextToFindFull)', SizeOf(TTextToFindFull), 40);
    CheckEqual('TTextToFindFull.lpstrText',
      FieldOffset(@TextToFind, @TextToFind.lpstrText), 16);
    CheckEqual('TTextToFindFull.chrgText',
      FieldOffset(@TextToFind, @TextToFind.chrgText), 24);
  end
  else
  begin
    CheckEqual('SizeOf(TNppData)', SizeOf(TNppData), 12);
    CheckEqual('TNppData.ScintillaMainHandle',
      FieldOffset(@NppData, @NppData.ScintillaMainHandle), 4);

    CheckEqual('SizeOf(TFuncItem)', SizeOf(TFuncItem), 144);
    CheckEqual('TFuncItem.CmdID', FieldOffset(@FuncItem, @FuncItem.CmdID), 132);
    CheckEqual('TFuncItem.Checked', FieldOffset(@FuncItem, @FuncItem.Checked), 136);
    CheckEqual('TFuncItem.ShortcutKey',
      FieldOffset(@FuncItem, @FuncItem.ShortcutKey), 140);

    CheckEqual('SizeOf(TTbData)', SizeOf(TTbData), 48);
    CheckEqual('TTbData.PrevContainer',
      FieldOffset(@DockingData, @DockingData.PrevContainer), 40);
    CheckEqual('TTbData.ModuleName',
      FieldOffset(@DockingData, @DockingData.ModuleName), 44);

    CheckEqual('SizeOf(TSessionInfo)', SizeOf(TSessionInfo), 12);
    CheckEqual('TSessionInfo.Files',
      FieldOffset(@SessionInfo, @SessionInfo.Files), 8);
    CheckEqual('SizeOf(TCommunicationInfo)', SizeOf(TCommunicationInfo), 12);
    CheckEqual('TCommunicationInfo.srcModuleName',
      FieldOffset(@CommunicationInfo, @CommunicationInfo.srcModuleName), 4);

    CheckEqual('SizeOf(TNotifyHeader)', SizeOf(TNotifyHeader), 12);
    CheckEqual('SizeOf(TSCNotification)', SizeOf(TSCNotification), 100);
    CheckEqual('TSCNotification.text',
      FieldOffset(@Notification, @Notification.text), 28);
    CheckEqual('TSCNotification.characterSource',
      FieldOffset(@Notification, @Notification.characterSource), 96);

    CheckEqual('SizeOf(TTextRangeFull)', SizeOf(TTextRangeFull), 12);
    CheckEqual('SizeOf(TTextToFindFull)', SizeOf(TTextToFindFull), 20);
    CheckEqual('TTextToFindFull.lpstrText',
      FieldOffset(@TextToFind, @TextToFind.lpstrText), 8);
    CheckEqual('TTextToFindFull.chrgText',
      FieldOffset(@TextToFind, @TextToFind.chrgText), 12);
  end;

  // This assignment is also a compile-time check that Scintilla text buffers
  // are declared as ANSI/UTF-8 pointers rather than Delphi Unicode PChar.
  TextRange.lpstrText := PAnsiChar(AnsiString('UTF-8'));
end;

begin
  try
    CheckCommonConstants;
    CheckRecordLayout;
    Writeln('Notepad++/Scintilla ABI checks passed for ',
      SizeOf(Pointer) * 8, '-bit.');
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, E.ClassName, ': ', E.Message);
      Halt(1);
    end;
  end;
end.
