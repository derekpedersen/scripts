# yq

Module for yq-related tooling and shell helpers.

## Files

- install.sh: install yq through the central installer runtime.
- uninstall.sh: uninstall yq through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for yq installation on Windows.

## Usage

From repo root:

```bash
bash ./tools/install.sh yq
```

```bash
bash ./tools/uninstall.sh yq
```

PowerShell (Windows):

```powershell
pwsh ./yq/install.windows.ps1
```

