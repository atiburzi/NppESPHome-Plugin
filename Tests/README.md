# Framework smoke tests

The console programs in this directory exercise the reusable Notepad++ plugin
framework without requiring a running Notepad++ process.

Coverage:

- NppApiAbiTests: ABI sizes, offsets, and pointer-width assumptions.
- NppHostTests: injectable synchronous/asynchronous host transports.
- NppPluginLifecycleTests: notifications and idempotent shutdown.
- NppPluginMenuTests: command registry, stable IDs, state, and listeners.
- NppPluginToolbarConfigTests: v2 layouts, legacy migration, add/remove merge,
  and failed native-button deletion.
- NppPluginFormTests: normal/docking forms and VCL application attachment.
- NppPluginExportSmokeTests: exported DLL entry points and lazy plugin startup.

After loading the Delphi environment with rsvars.bat, compile a test directly:

    dcc32 -B -Q -U"Lib" -I"Lib" -E"Tests" -N"Tests\dcu\Win32" Tests\NppHostTests.dpr

Use dcc64 and the Win64 output directories for the 64-bit matrix. The export
test takes the matching compiled plugin DLL as its only argument:

    Tests\NppPluginExportSmokeTests.exe Build\Verify\Win32\NppESPHome.dll
