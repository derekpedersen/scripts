# tools

Central installer and uninstaller entrypoints plus shared runtime/helpers.

## Files

- install.sh: central installer that resolves bundles and dispatches to module installers.
- uninstall.sh: central uninstaller that resolves bundles and dispatches to module uninstallers.
- install.ps1: PowerShell wrapper for Windows installs.
- uninstall.ps1: PowerShell wrapper for Windows uninstalls.
- common.sh: bundle definitions, alias normalization, and shared helper functions.
- module-runtime.sh: shared runtime sourced by per-module install/uninstall scripts.
- macos.sh: macOS platform install implementation used by module runtime.
- linux.sh: Linux platform install implementation used by module runtime.
- windows.sh: Windows platform install/uninstall implementation used by module runtime.
