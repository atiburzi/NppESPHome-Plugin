# Framework smoke tests

The console programs in this directory exercise the reusable Notepad++ plugin
framework without requiring a running Notepad++ process.

Coverage:

- NppApiAbiTests: ABI sizes, offsets, and pointer-width assumptions.
- NppHostTests: injectable transports, host version queries, native commands,
  and toolbar-handle resolution.
- NppPluginLifecycleTests: notifications, owned services, and idempotent shutdown.
- NppPluginDocumentTests: view-aware file enumeration, safe dark-mode color
  queries, and explicit read-only state for new and already-open documents.
- NppPluginMenuTests: the plugin-owned command registry, stable IDs, state, and listeners.
- NppPluginToolbarConfigTests: current stable-ID format, rejection of obsolete
  prefixes, add/remove reconciliation, plugin-owned toolbar lifecycle, and
  failed native-button deletion, stable-ID lookup, and resource reinitialization.
- NppPluginFormTests: normal/docking forms, shared VCL application attachment,
  multiple-form lifetime, and out-of-order destruction.
- NppPluginExportSmokeTests: exported DLL entry points and lazy plugin startup.

After loading the Delphi environment with rsvars.bat, compile a test directly:

    dcc32 -B -Q -U"Lib" -I"Lib" -E"Tests" -N"Tests\dcu\Win32" Tests\NppHostTests.dpr

Use dcc64 and the Win64 output directories for the 64-bit matrix. The export
test takes the matching compiled plugin DLL as its only argument:

    Tests\NppPluginExportSmokeTests.exe Build\Verify\Win32\NppESPHome.dll
