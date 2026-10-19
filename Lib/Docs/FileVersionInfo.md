# `TFileVersionInfo`

`TFileVersionInfo` is a stateless Windows version-resource reader declared in
the `FileVersionInfo` unit. All operations are class functions; no instance is
required.

It reads localized string fields, fixed numeric file/product versions, and
Windows language names from EXE and DLL files.

## Required unit

```pascal
uses
  FileVersionInfo;
```

## Related types

### `TFileVersionInfoTag`

Selects a localized string field: `fvitCompanyName`,
`fvitFileDescription`, `fvitComments`, `fvitProductName`,
`fvitInternalName`, `fvitOriginalFilename`, `fvitFileVersion`,
`fvitProductVersion`, `fvitLegalCopyright`, `fvitLegalTrademarks`,
`fvitPrivateBuild`, or `fvitSpecialBuild`.

### `TNumericFileVersionInfoTag`

Selects `nfvitFileVersion` or `nfvitProductVersion` from
`VS_FIXEDFILEINFO`.

### `wLangIdEnglish`

The public constant `wLangIdEnglish = 1033` identifies English (United
States) and is useful as the preferred language for string queries.

## Methods

| Method | Purpose |
| --- | --- |
| `GetVersionInfoTagName` | Returns the Windows resource key for a string tag |
| `GetVersionInfoFriendlyTagName` | Returns a display label for a string tag |
| `GetVersionInfo` | Reads one localized string value |
| `GetNumericVersionInfoTagName` | Returns the resource key for a numeric tag |
| `GetNumericVersionInfoFriendlyTagName` | Returns a display label for a numeric tag |
| `GetNumericVersionInfo` | Reads four fixed version components |
| `GetLanguageName` | Resolves a Windows language ID to its localized name |

### `GetVersionInfoTagName`

```pascal
class function GetVersionInfoTagName(
  const InfoTag: TFileVersionInfoTag): string; static;
```

Returns the exact key used in `StringFileInfo`, such as `CompanyName` or
`LegalCopyright`.

```pascal
Key := TFileVersionInfo.GetVersionInfoTagName(fvitProductName);
```

### `GetVersionInfoFriendlyTagName`

Returns a human-readable English label such as `Product name`.

```pascal
LabelText := TFileVersionInfo.GetVersionInfoFriendlyTagName(
  fvitProductName);
```

### `GetVersionInfo`

```pascal
class function GetVersionInfo(const FileName: string;
  const InfoTag: TFileVersionInfoTag; var LangId: Word;
  out Buffer: string): Boolean; static;
```

Reads a localized string. `LangId` is both the preferred input language and
the language actually selected on output. The search prefers the requested
translation, then English, then the first translation containing the field.

The method returns `False` and clears `Buffer` when the file has no usable
version resource or field.

```pascal
Language := wLangIdEnglish;
if TFileVersionInfo.GetVersionInfo(DllPath, fvitLegalCopyright,
  Language, CopyrightText) then
  ShowMessage(CopyrightText);
```

### Numeric tag-name methods

```pascal
Key := TFileVersionInfo.GetNumericVersionInfoTagName(nfvitFileVersion);
LabelText := TFileVersionInfo.GetNumericVersionInfoFriendlyTagName(
  nfvitProductVersion);
```

They return `FileVersion`/`ProductVersion` and their display labels.

### `GetNumericVersionInfo`

```pascal
class function GetNumericVersionInfo(const FileName: string;
  const InfoTag: TNumericFileVersionInfoTag;
  out VersionMajor, VersionMinor, Release, Build: Integer): Boolean; static;
```

Reads the four components from `VS_FIXEDFILEINFO`. All outputs are reset to
zero before reading, so a failed call leaves deterministic values.

```pascal
if TFileVersionInfo.GetNumericVersionInfo(DllPath, nfvitFileVersion,
  Major, Minor, Release, Build) then
  VersionText := Format('%d.%d.%d.%d', [Major, Minor, Release, Build]);
```

### `GetLanguageName`

```pascal
class function GetLanguageName(LangId: Word): string;
```

Returns the localized Windows display name for a language identifier, or an
empty string if Windows cannot resolve it.

```pascal
LanguageName := TFileVersionInfo.GetLanguageName(wLangIdEnglish);
```

## Practical rules

- Use the numeric API for comparisons and the string API for display metadata.
- Treat a `False` result as “resource or field unavailable”; no exception is
  raised for ordinary lookup failures.
- Read the output `LangId` when reporting which translation was selected.
- Do not assume string and fixed numeric version fields contain identical text.
- No object ownership is involved because every method is static/class-level.

