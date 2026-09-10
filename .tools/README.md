# tools

Installer/runtime layer for the repo's bundle-based tool installation flow.

This folder contains the controller and platform logic that resolves bundles, dispatches module installers, and keeps the cross-platform behavior in one place. Individual tool packages continue to live as repo-root directories such as [docker](docker), [kubectl](kubectl), [aws](aws), [gcloud](gcloud), and [git](git).

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
