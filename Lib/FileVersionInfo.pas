{
  Extraction of version infos from Windows EXE and DLL files.
  Author: Andreas Heim

  This file is part of the Notepad++ plugin framework for Delphi.

  This program is free software; you can redistribute it and/or modify it
  under the terms of the GNU General Public License version 3 as published
  by the Free Software Foundation.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
}

unit FileVersionInfo;

interface

uses
  Winapi.Windows,
  System.SysUtils;

const
  // Language ID of English
  wLangIdEnglish: Word = 1033;

type
  // Enum to specify the type of version info to query
  TFileVersionInfoTag = (
    fvitCompanyName,
    fvitFileDescription,
    fvitComments,
    fvitProductName,
    fvitInternalName,
    fvitOriginalFilename,
    fvitFileVersion,
    fvitProductVersion,
    fvitLegalCopyright,
    fvitLegalTrademarks,
    fvitPrivateBuild,
    fvitSpecialBuild
  );

  // Enum to specify the type of numeric version info to query
  TNumericFileVersionInfoTag = (
    nfvitFileVersion,
    nfvitProductVersion
  );

  // Class to read version infos from EXE or DLL files
  TFileVersionInfo = class
  public
    class function GetVersionInfoTagName(
      const InfoTag: TFileVersionInfoTag
    ): string; static;

    class function GetVersionInfoFriendlyTagName(
      const InfoTag: TFileVersionInfoTag
    ): string; static;

    class function GetVersionInfo(
      const FileName: string;
      const InfoTag: TFileVersionInfoTag;
      var LangId: Word;
      out Buffer: string
    ): Boolean; static;

    class function GetNumericVersionInfoTagName(
      const InfoTag: TNumericFileVersionInfoTag
    ): string; static;

    class function GetNumericVersionInfoFriendlyTagName(
      const InfoTag: TNumericFileVersionInfoTag
    ): string; static;

    class function GetNumericVersionInfo(
      const FileName: string;
      const InfoTag: TNumericFileVersionInfoTag;
      out VersionMajor: Integer;
      out VersionMinor: Integer;
      out Release: Integer;
      out Build: Integer
    ): Boolean; static;

    class function GetLanguageName(LangId: Word): string;
  end;

implementation

type
  TFileVersionTagMapping = record
    TagName: string;
    TagFriendlyName: string;
  end;

var
  szVersionInfoTags: array[TFileVersionInfoTag] of TFileVersionTagMapping = (
    (
      TagName: 'CompanyName';
      TagFriendlyName: 'Company name'
    ),
    (
      TagName: 'FileDescription';
      TagFriendlyName: 'Description'
    ),
    (
      TagName: 'Comments';
      TagFriendlyName: 'Comments'
    ),
    (
      TagName: 'ProductName';
      TagFriendlyName: 'Product name'
    ),
    (
      TagName: 'InternalName';
      TagFriendlyName: 'Internal name'
    ),
    (
      TagName: 'OriginalFilename';
      TagFriendlyName: 'Original filename'
    ),
    (
      TagName: 'FileVersion';
      TagFriendlyName: 'File version'
    ),
    (
      TagName: 'ProductVersion';
      TagFriendlyName: 'Product version'
    ),
    (
      TagName: 'LegalCopyright';
      TagFriendlyName: 'Copyright'
    ),
    (
      TagName: 'LegalTrademarks';
      TagFriendlyName: 'Trademarks'
    ),
    (
      TagName: 'PrivateBuild';
      TagFriendlyName: 'Private build'
    ),
    (
      TagName: 'SpecialBuild';
      TagFriendlyName: 'Special build'
    )
  );

  szNumericVersionInfoTags:
    array[TNumericFileVersionInfoTag] of TFileVersionTagMapping = (
      (
        TagName: 'FileVersion';
        TagFriendlyName: 'File version'
      ),
      (
        TagName: 'ProductVersion';
        TagFriendlyName: 'Product version'
      )
    );

// =============================================================================
// TFileVersionInfo
// =============================================================================

class function TFileVersionInfo.GetVersionInfoTagName(
  const InfoTag: TFileVersionInfoTag
): string;
begin
  Result := szVersionInfoTags[InfoTag].TagName;
end;

class function TFileVersionInfo.GetVersionInfoFriendlyTagName(
  const InfoTag: TFileVersionInfoTag
): string;
begin
  Result := szVersionInfoTags[InfoTag].TagFriendlyName;
end;

class function TFileVersionInfo.GetVersionInfo(
  const FileName: string;
  const InfoTag: TFileVersionInfoTag;
  var LangId: Word;
  out Buffer: string
): Boolean;
type
  TLangCodepage = packed record
    wLangId: Word;
    wCodePage: Word;
  end;

  {$POINTERMATH ON}
  PLangCodepage = ^TLangCodepage;
  {$POINTERMATH OFF}

var
  dwLen: DWORD;
  dwHandle: DWORD;
  lpData: Pointer;
  lpTranslate: PLangCodepage;
  cbTranslate: UINT;
  lpszSubData: string;
  lpszVersionData: PChar;
  dwBytes: UINT;
  wLangId: Word;
  bEngFound: Boolean;
  i: Integer;
begin
  Result := False;
  Buffer := '';

  dwLen := GetFileVersionInfoSize(PChar(FileName), dwHandle);
  if dwLen = 0 then
    Exit;

  GetMem(lpData, dwLen);
  try
    if not GetFileVersionInfo(
      PChar(FileName),
      dwHandle,
      dwLen,
      lpData
    ) then
      Exit;

    if not VerQueryValue(
      lpData,
      '\VarFileInfo\Translation',
      Pointer(lpTranslate),
      cbTranslate
    ) then
      Exit;

    wLangId := LangId;
    bEngFound := False;

    for i := 0 to Pred(cbTranslate div SizeOf(TLangCodepage)) do
    begin
      if (lpTranslate[i].wLangId = LangId) or
         (lpTranslate[i].wLangId = wLangIdEnglish) or
         not bEngFound then
      begin
        lpszSubData := Format(
          '\StringFileInfo\%.4x%.4x\%s',
          [
            lpTranslate[i].wLangId,
            lpTranslate[i].wCodePage,
            szVersionInfoTags[InfoTag].TagName
          ]
        );

        if not VerQueryValue(
          lpData,
          PChar(lpszSubData),
          Pointer(lpszVersionData),
          dwBytes
        ) then
          Continue;

        Buffer := Format('%s', [lpszVersionData]);
        wLangId := lpTranslate[i].wLangId;
        bEngFound := lpTranslate[i].wLangId = wLangIdEnglish;
        Result := True;

        if lpTranslate[i].wLangId = LangId then
          Break;
      end;
    end;

    LangId := wLangId;
  finally
    FreeMem(lpData);
  end;
end;

class function TFileVersionInfo.GetNumericVersionInfoTagName(
  const InfoTag: TNumericFileVersionInfoTag
): string;
begin
  Result := szNumericVersionInfoTags[InfoTag].TagName;
end;

class function TFileVersionInfo.GetNumericVersionInfoFriendlyTagName(
  const InfoTag: TNumericFileVersionInfoTag
): string;
begin
  Result := szNumericVersionInfoTags[InfoTag].TagFriendlyName;
end;

class function TFileVersionInfo.GetNumericVersionInfo(
  const FileName: string;
  const InfoTag: TNumericFileVersionInfoTag;
  out VersionMajor: Integer;
  out VersionMinor: Integer;
  out Release: Integer;
  out Build: Integer
): Boolean;
var
  dwLen: DWORD;
  dwHandle: DWORD;
  lpData: Pointer;
  dwBytes: UINT;
  FileInfo: PVSFixedFileInfo;
begin
  Result := False;

  VersionMajor := 0;
  VersionMinor := 0;
  Release := 0;
  Build := 0;

  dwLen := GetFileVersionInfoSize(PChar(FileName), dwHandle);
  if dwLen = 0 then
    Exit;

  GetMem(lpData, dwLen);
  try
    if not GetFileVersionInfo(
      PChar(FileName),
      dwHandle,
      dwLen,
      lpData
    ) then
      Exit;

    if not VerQueryValue(
      lpData,
      '\',
      Pointer(FileInfo),
      dwBytes
    ) then
      Exit;

    case InfoTag of
      nfvitProductVersion:
        begin
          VersionMajor := FileInfo.dwProductVersionMS shr 16;
          VersionMinor := FileInfo.dwProductVersionMS and $FFFF;
          Release := FileInfo.dwProductVersionLS shr 16;
          Build := FileInfo.dwProductVersionLS and $FFFF;
        end;

      nfvitFileVersion:
        begin
          VersionMajor := FileInfo.dwFileVersionMS shr 16;
          VersionMinor := FileInfo.dwFileVersionMS and $FFFF;
          Release := FileInfo.dwFileVersionLS shr 16;
          Build := FileInfo.dwFileVersionLS and $FFFF;
        end;
    end;

    Result := True;
  finally
    FreeMem(lpData);
  end;
end;

class function TFileVersionInfo.GetLanguageName(LangId: Word): string;
var
  Buffer: string;
  BufLen: Integer;
begin
  Result := '';
  Buffer := '';
  BufLen := 0;

  repeat
    SetLength(Buffer, BufLen);
    BufLen := GetLocaleInfo(
      LangId,
      LOCALE_SLANGUAGE,
      PChar(Buffer),
      BufLen
    );
  until BufLen = Length(Buffer);

  if Buffer <> '' then
  begin
    SetLength(Buffer, StrLen(PChar(Buffer)));
    Result := Buffer;
  end;
end;

end.
