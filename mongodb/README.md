# mongodb

Module for mongodb-related tooling and shell helpers.

## Files

- install.sh: install mongodb through the central installer runtime.
- uninstall.sh: uninstall mongodb through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for mongodb installation on Windows.

## Usage

From repo root:

```bash
bash ./tools/install.sh mongodb
```

```bash
bash ./tools/uninstall.sh mongodb
```

PowerShell (Windows):

```powershell
pwsh ./mongodb/install.windows.ps1
```

