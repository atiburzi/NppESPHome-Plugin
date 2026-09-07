# NppESPHome Plugin

<p align="center">
  <img src="Art/main.png" alt="NppESPHome dockable project and template window"><br>
</p>

<p align="center">
  <a href="https://github.com/atiburzi/NppESPHome-Plugin">
    <img src="https://img.shields.io/badge/Platform-Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Windows">
  </a>
  <a href="https://notepad-plus-plus.org/">
    <img src="https://img.shields.io/badge/Editor-Notepad++-90E59A?style=for-the-badge&logo=notepadplusplus&logoColor=black" alt="Notepad++">
  </a>
  <a href="https://github.com/esphome/esphome">
    <img src="https://img.shields.io/badge/ESPHome-Integrated-000000?style=for-the-badge&logo=esphome&logoColor=white" alt="ESPHome">
  </a>
  <a href="https://www.embarcadero.com/products/delphi">
    <img src="https://img.shields.io/badge/Language-Delphi-E62431?style=for-the-badge&logo=delphi&logoColor=white" alt="Delphi">
  </a>
  <a href="http://mozilla.org/MPL/2.0/">
    <img src="https://img.shields.io/badge/License-MPL%202.0-F59E0B?style=for-the-badge" alt="MPL 2.0">
  </a>
</p>

<p align="center">
  <a href="https://github.com/atiburzi/NppESPHome-Plugin/tree/main/Bin">
    <img src="https://img.shields.io/badge/Download-DLL-2563EB?style=flat-square&logo=github" alt="Download DLL">
  </a>
  <a href="https://github.com/atiburzi/NppESPHome-Plugin/issues">
    <img src="https://img.shields.io/badge/Issues-Welcome-16A34A?style=flat-square&logo=github" alt="Issues Welcome">
  </a>
  <a href="https://github.com/atiburzi/NppESPHome-Plugin/pulls">
    <img src="https://img.shields.io/badge/PRs-Welcome-9333EA?style=flat-square&logo=github" alt="Pull Requests Welcome">
  </a>
</p>

NppESPHome is a Windows plugin written in Delphi that integrates common
[ESPHome](https://github.com/esphome/esphome) workflows into Notepad++. It
manages multiple projects and their related files, builds project-specific
ESPHome command lines, provides configurable native toolbars, inserts reusable
YAML snippets from an XML template library, and can run ESPHome in an
interactive dockable console backed by Windows ConPTY.

The plugin is a front end for the ESPHome command-line tools. It does not
replace ESPHome and does not include the ESPHome runtime.

---

## Highlights

- Multiple ESPHome projects with a persistent current-project selection
- YAML project validation and extraction of device metadata
- Manually managed dependency files for each project
- Direct **Run**, **Compile**, **Upload**, **Logs**, **Clean**, and
  **Clean-All** commands
- Interactive dockable console with ANSI colors, UTF-8 output, keyboard input,
  live status, elapsed time, and process controls
- Automatic external-console fallback when ConPTY is unavailable or the
  dockable console is hidden
- Per-project command, target, auto-save, and console options
- Dockable project and template window synchronized with the active document
- XML-based, searchable, and editable YAML template library
- Configurable Notepad++ toolbar with persistent order and visibility
- Light and Dark mode integration, including toolbar icon-set changes
- Shortcuts for ESPHome documentation, upgrade, terminal, and File Explorer

---

## Requirements

- Windows
- Notepad++ with the same architecture as the plugin DLL (`Win32` or `Win64`)
- ESPHome installed and `esphome.exe` available through the Windows `PATH`
- Notepad++ 8.0 or newer for custom toolbar configuration

The integrated console uses the Windows Pseudoconsole API (ConPTY), available
on Windows 10 version 1809 and newer. On systems without ConPTY, or when the
dockable console is hidden, commands continue to work in a standard external
Windows console.

The presence of `esphome.exe` is checked when an ESPHome command is invoked.
The **Upgrade ESPHome** utility also requires `pip.exe` to be available through
the `PATH`.

See the
[ESPHome installation guide](https://www.esphome.io/guides/installing_esphome/)
and the
[Notepad++ manual plugin installation guide](https://npp-user-manual.org/docs/plugins/#install-plugin-manually).

---

## Installation

1. Download the DLL for the architecture of your Notepad++ installation from
   the [`Bin` directory](https://github.com/atiburzi/NppESPHome-Plugin/tree/main/Bin).
2. Create a plugin subdirectory named `NppESPHome` below the Notepad++ plugin
   directory.
3. Copy the DLL to:

   ```text
   <Notepad++>\plugins\NppESPHome\NppESPHome.dll
   ```

4. Restart Notepad++.

The plugin creates its INI and template files in the configuration directory
provided by Notepad++ rather than beside the installed DLL.

---

## Getting Started

1. Choose **Plugins → NppESPHome → Add Project** and select an existing ESPHome
   YAML project file.
2. Use **Select Project** to make one of the known projects current.
3. Open **Configure Project** to select command, target, auto-save, and console
   options.
4. Add any YAML, CSV, C/C++ header/source, include, text, or other related files
   that should be treated as project dependencies.
5. Enable **Show/Hide ESPHome Console** if you want commands to run in the
   integrated docking form.
6. Execute an ESPHome command from the plugin menu, the Notepad++ toolbar, or
   the dockable project window.
7. Double-click a template to insert its YAML at the current editor selection.

Removing a project or dependency removes only its registration from the plugin;
it never deletes the underlying file.

---

## Project Model

When a project is added, the plugin parses the YAML file and accepts it when it
contains:

- a non-empty `esphome.name`;
- one supported top-level platform: `esp32`, `esp8266`, `bk72xx`, `ln882x`,
  `rp2040`, `rtl87xx`, or `host`.

Values referenced as `$name` or `${name}` are resolved from the top-level
`substitutions` section, including nested substitutions. The parser extracts
the friendly name, platform, board, framework, and the presence of `wifi` and
`web_server`. If `esphome.friendly_name` is absent, the project name is used for
display.

Each known project can have an arbitrary list of dependency files. The docked
tree displays those files below their owning project, can open the complete set
in one action, and can save them together before running ESPHome.

Activating either a main YAML file or one of its registered dependencies makes
the owning project current. The selection in the docked tree, command state,
plugin menu, toolbar, and project suffix in the Notepad++ title are updated
accordingly.

---

## ESPHome Commands

Every command runs in the current project's directory and passes the absolute
project filename to `esphome.exe`.

| Command | Generated ESPHome command | Project-specific options |
|---|---|---|
| Run | `run` | Target device, `--reset`, `--no-logs`, extra parameters |
| Compile | `compile` | `--only-generate`, extra parameters |
| Upload | `upload` | Target device, extra parameters |
| Logs | `logs` | Target device, `--reset`, extra parameters |
| Clean | `clean` | Extra parameters |
| Clean-All | `clean-all` | Requires explicit confirmation |

The selected ESPHome log level is added before the command with `-l` and can be
**Critical**, **Error**, **Warning**, **Info**, **Debug**, or **Default**. A
separate global extra-parameters field is also inserted before the command;
**Run**, **Compile**, **Upload**, **Logs**, and **Clean** also have their own
additional-parameters fields.

### Target Device

The target is stored per project and can be:

- **None**, which leaves target selection to ESPHome;
- one of the Windows serial `COM` ports listed from the system registry;
- **OTA**, which generates `--device OTA`.

The plugin enumerates serial ports when the configuration form is opened. It
does not scan the network for ESPHome nodes.

### Auto-Save

Before starting a command, the plugin can save:

- nothing;
- only the current project's main file;
- the project file and all registered dependencies;
- every open Notepad++ document.

## Dockable Interactive Console

The ESPHome console is a separate Notepad++ docking form. Its visibility is
controlled from **Plugins → NppESPHome → Show/Hide ESPHome Console** and is
restored between Notepad++ sessions.

When this window is visible and ConPTY is supported, ESPHome commands run in
the integrated console. The plugin starts `cmd.exe` with `/c`, hosts it in a
Windows pseudoconsole, and keeps both output and keyboard input connected to
the docking form. Starting another integrated command replaces the current
integrated session.

### Output and Terminal Behavior

The terminal view provides:

- UTF-8 decoding across asynchronous output chunks;
- the standard 16 ANSI colors, xterm 256-color sequences, and 24-bit RGB
  foreground/background colors;
- common SGR text attributes such as bold, italic, underline, and inverse;
- handling for the cursor, carriage-return, line-feed, erase-line, and other
  ANSI/VT sequences commonly produced by ESPHome and its build tools;
- automatic ConPTY resizing when the docking form changes size;
- horizontal and vertical scrollbars with word wrapping intentionally disabled;
- optional automatic following of the newest output, suspended when the user
  scrolls back and resumed with the **Follow** button;
- a bounded scrollback buffer: after roughly two million characters, the
  oldest portion is removed in line-aligned blocks.

The console is interactive. Normal text is sent to the pseudoconsole together
with Enter, Backspace, Tab, navigation keys, Insert/Delete, Page Up/Down, and
the function keys. `Ctrl+V` pastes clipboard text into the running process.
`Ctrl+C` copies an existing selection; without a selection, it sends the
interrupt character to ESPHome.

### Header, Status, and Controls

The console header shows the current command and project, for example
`Logs "Living Room"`. Its default title is `Console`, which is restored by
**Clear**.

The secondary status line reports **Ready**, **Running**, **Completed**,
**Stopped**, startup failures, and non-zero exit codes. While a command is
running it also shows elapsed time and a three-bar activity animation. Stopped
and error states use the same red visual treatment.

The header toolbar contains:

- **Select all**, which selects the complete terminal contents;
- **Copy**, enabled only when text is selected and briefly changed to
  **Copied** after use;
- **Save**, which writes the rendered plain-text output to a user-selected
  UTF-8 log file;
- **Follow**, which enables or pauses automatic scrolling to new output;
- **Clear**, which clears the view and resets the ANSI parser without changing
  the state of a process that is still running;
- **Stop**, visible only for a running integrated command and used to close the
  current pseudoconsole session.

Integrated-console colors, font, font size, scrollback size, and
**Clear output before each command** are stored separately for each project.

### External Console Fallback

The plugin uses its original external Windows console when:

- the dockable console is hidden;
- ConPTY is not available on the current Windows version; or
- creation of the integrated session fails.

The per-project console-window options apply to this fallback:

- close after a successful command and pause on failure, or remain open;
- keep the window always on top;
- let Windows position it, center it, or place it in any screen corner;
- select the monitor used for placement;
- enable **Solo Mode**, which terminates the previous plugin-launched external
  console before starting another one.

The integrated console always invokes `cmd.exe /c` without appending
`|| pause`; completion and errors are represented by its own status line. The
plugin stops its active integrated session and its last tracked external
ESPHome process when Notepad++ shuts down.

---

## Dockable Project and Template Window

The main plugin window is a Notepad++ docking form, not a separate project
editor. It contains two resizable areas.

### Projects

The project tree provides:

- project roots with platform-specific icons;
- dependency children with file-type icons;
- selection and opening of the represented file;
- add/remove project and dependency actions;
- project configuration and open-all-files actions;
- direct ESPHome command buttons;
- shortcuts to a terminal and File Explorer in the project directory.

The window visibility and the project/template splitter height are persisted.
Notepad++ manages the docking side and docking layout.

### Templates

Templates are loaded from `NppESPHome.xml` in the Notepad++ plugin
configuration directory. Each XML component contains:

```xml
<Component>
  <Name>Template name</Name>
  <Category>Category</Category>
  <OnlineHelp>https://example.com/help</OnlineHelp>
  <Description>Template description</Description>
  <YAML><![CDATA[
  # YAML inserted into the editor
  ]]></YAML>
</Component>
```

The browser supports:

- filtering template names as text is typed;
- filtering by category;
- displaying descriptions and optional online-help links;
- inserting UTF-8 YAML at the current selection with a double-click;
- opening the local XML file in Notepad++ for editing;
- manual reload and automatic reload after the XML file is saved;
- downloading or restoring the default XML from this repository after
  confirmation.

If the local XML file is missing on first load, the plugin offers to download
the default template collection.

---

## Configurable Notepad++ Toolbar

Toolbar customization is available with Notepad++ 8.0 or newer from
**Plugins → NppESPHome → Configure Toolbar**.

The dialog and its image resources belong to NppESPHome, while the reusable
`Npp.Toolbar` framework unit owns layout parsing, stable command IDs,
configuration-string persistence, and native toolbar synchronization.

For every supported plugin command, the dialog can:

- show or hide its toolbar button using a checkbox;
- reorder it with drag and drop;
- move it with `Ctrl+Up` and `Ctrl+Down`;
- restore the default order and visibility;
- apply and persist changes without restarting Notepad++.

The toolbar rebuild preserves the command association and enabled state. Icons
are refreshed when Notepad++ switches between Light and Dark mode or changes
among its Fluent UI, Filled Fluent UI, and Standard toolbar icon sets.

---

## Menu Commands and Default Shortcuts

All commands are available below **Plugins → NppESPHome**. Notepad++ can remap
their shortcuts through its **Shortcut Mapper**; the plugin then refreshes its
dynamic **Configure Project** menu caption.

| Command | Default shortcut |
|---|---:|
| Select Project | `Ctrl+Alt+F10` |
| Configure Project | `Ctrl+F10` |
| Run | `F9` |
| Compile | `Ctrl+F9` |
| Upload | `Shift+F9` |
| ESPHome Documentation | `Ctrl+F1` |

Other menu entries include adding/removing projects, opening project files,
Logs, Clean, Clean-All, upgrading ESPHome, opening a project terminal or File
Explorer, independently showing/hiding the project and console docking forms,
configuring the toolbar, and About.

The terminal starts in the project directory and receives two convenience
environment variables:

```text
ESPHome=<absolute path to esphome.exe>
ESPProject=<absolute path to the current project YAML>
```

**Upgrade ESPHome** runs `pip.exe install --upgrade esphome`, then displays the
installed ESPHome version. **ESPHome Documentation** opens the official
component documentation in the default browser.

---

## Configuration and Persistence

The plugin uses the configuration directory reported by Notepad++.

| File | Stored data |
|---|---|
| `NppESPHome.ini` | Known/current projects, dependencies, per-project command and console options, project/console docking-form visibility, splitter size, and toolbar configuration |
| `NppESPHome.xml` | User-editable YAML template collection |

Each project is stored in an INI section named with the absolute path of its
main YAML file. Removing a project also removes its corresponding settings
section.

---

## Screenshots

Click a preview to open its dedicated large-view page. Each page includes a
link back to this README.

<div align="center">

| Dockable window | Project selection | Project configuration |
|---|---|---|
| <a href="Art/screenshots/dockable-dark.md"><img src="Art/main_dark.png" width="240" alt="Dockable project and template window in Dark mode"></a> | <a href="Art/screenshots/project-selection-dark.md"><img src="Art/select_dark.png" width="240" alt="Select Project window in Dark mode"></a> | <a href="Art/screenshots/project-configuration-dark.md"><img src="Art/config_dark.png" width="240" alt="Configure Project window in Dark mode"></a> |

| Menu integration | External console fallback | Toolbar configuration |
|---|---|---|
| <a href="Art/screenshots/menu-integration-dark.md"><img src="Art/menu_dark.png" width="240" alt="Plugin menu in Dark mode"></a> | <a href="Art/screenshots/console-execution.md"><img src="Art/console.png" width="240" alt="ESPHome command running in the external console fallback"></a> | <a href="Art/screenshots/toolbar-configuration-dark.md"><img src="Art/toolbar_dark.png" width="240" alt="Toolbar configuration in Dark mode"></a> |

</div>

---

## Building from Source

The Delphi project is in [`Source`](Source), with shared Notepad++ plugin base
classes in [`Lib`](Lib), bundled third-party source and object files in
[`External`](External), default snippets in [`Templates`](Templates), and
prebuilt DLLs in [`Bin`](Bin).

The reusable framework has a dedicated
[`Lib` API and usage guide](Lib/README.md), including a complete plugin
example, command and toolbar lifecycle, method reference, ownership rules,
normal/docking VCL forms, and integration of an application-owned toolbar
configuration UI.

The current development baseline is:

- Delphi 13 / compiler 37.0
- Notepad++ 8.8.3

ESPHome is an external runtime discovered through `PATH`; the plugin source is
not tied to a specific ESPHome release.

The project builds `Win32` and `Win64` configurations and adds `Lib` and
`External` to the Delphi unit search path.

The Notepad++ plugin base was partially derived from and adapted from
[NppUISpy 1.2](https://github.com/dinkumoil/NppUISpy/tree/master/src/Lib).
Third-party libraries and components used by the project include:

- [Virtual-TreeView 8.3](https://github.com/JAM-Software/Virtual-TreeView)
- [Neslib.Yaml](https://github.com/neslib/Neslib.Yaml), backed by
  [LibYAML 0.2.5](https://github.com/yaml/libyaml)
- [JEDI Visual Component Library 3.50](https://github.com/project-jedi/jvcl)
- [Task Dialog Message Box with Fluent Interface](https://specials.rejbrand.se/dev/classes/TDMessageBox/TDMessageBox.html)

Delphi packages that are not bundled in the repository must be installed or
available through the compiler's library search path.

---

## Contributing

Bug reports, feature proposals, and pull requests are welcome. For significant
changes, opening an issue first makes it easier to agree on behavior and scope.

- [Issues](https://github.com/atiburzi/NppESPHome-Plugin/issues)
- [Pull requests](https://github.com/atiburzi/NppESPHome-Plugin/pulls)
- [Source code](https://github.com/atiburzi/NppESPHome-Plugin/tree/main/Source)

---

## License

The source code is released under the
[Mozilla Public License 2.0](http://mozilla.org/MPL/2.0/).

> Copyright © 2025–2026 Andrea Tiburzi
> This Source Code Form is subject to the terms of the Mozilla Public License,
> v. 2.0. If a copy of the MPL was not distributed with this file, you can
> obtain one at [http://mozilla.org/MPL/2.0/](http://mozilla.org/MPL/2.0/).
