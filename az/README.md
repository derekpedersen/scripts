# az

Module for az-related tooling and shell helpers.

## Files

- bash.sh: shell helpers for az.
- install.sh: install az through the central installer runtime.
- uninstall.sh: uninstall az through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for az installation on Windows.

## Aliases

Accepted alias names: azure, azure-cli

## Usage

From repo root:

```bash
bash ./tools.install.sh az
```

```bash
bash ./tools.uninstall.sh az
```

PowerShell (Windows):

```powershell
pwsh ./az/install.windows.ps1
```

