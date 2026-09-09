# dotnetcore

Module for dotnetcore-related tooling and shell helpers.

## Files

- install.sh: install dotnetcore through the central installer runtime.
- uninstall.sh: uninstall dotnetcore through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for dotnetcore installation on Windows.

## Aliases

Accepted alias names: dotnet

## Usage

From repo root:

```bash
bash ./tools/install.sh dotnetcore
```

```bash
bash ./tools/uninstall.sh dotnetcore
```

PowerShell (Windows):

```powershell
pwsh ./dotnetcore/install.windows.ps1
```

