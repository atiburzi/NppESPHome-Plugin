# Component manuals

This directory contains the detailed manuals for the public components of the
Notepad++ Delphi plugin framework. Each manual describes responsibilities,
ownership, related types, every public property and method, error behavior, and
short usage examples based on the current source code.

## Available manuals

- [`TNppHost`](Npp.Host.md) — typed and injectable access to Notepad++,
  Scintilla, and native window messages.
- [`TNppCommands`](Npp.Commands.md) — command registration, stable IDs,
  shortcuts, menu state, ABI publication, and enabled-state listeners.
- [`TFileVersionInfo`](FileVersionInfo.md) — Windows executable and DLL
  version-resource queries.
- [`TNppPlugin`](Npp.Plugin.md) — plugin lifecycle, notifications, owned
  services, document queries, and file operations.
- [`Npp.Toolbar`](Npp.Toolbar.md) — `TNppToolbarLayout`, `TNppToolbar`, layout
  configuration, icon ownership, and native toolbar synchronization.
- [`TNppPluginForm`](Npp.Vcl.Forms.md) — optional integration for normal VCL
  plugin forms.
- [`TNppPluginDocking`](Npp.Vcl.Docking.md) — optional integration for docked
  VCL plugin panels.

## Localization

All exception messages and DLL-export fallback diagnostics owned by the
framework are declared as Delphi `resourcestring` values in the unit that owns
the corresponding behavior. They can therefore be translated with the normal
Delphi resource-module or satellite-DLL workflow without adding an application
dependency to the framework.

Translations must preserve formatting placeholders such as `%s` and `%d`.
Technical identifiers passed to `EArgumentNilException`, such as `AHost` and
`IconProvider`, deliberately remain inline parameter-name literals and must not
be translated. The surrounding exception sentence is provided by the
localized Delphi RTL.
