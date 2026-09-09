# vscode

Module for vscode-related tooling and shell helpers.

## Files

- install.sh: install vscode through the central installer runtime.
- uninstall.sh: uninstall vscode through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for vscode installation on Windows.

## Aliases

Accepted alias names: code

## Usage

From repo root:

```bash
bash ./tools.install.sh vscode
```

```bash
bash ./tools.uninstall.sh vscode
```

PowerShell (Windows):

```powershell
pwsh ./vscode/install.windows.ps1
```

