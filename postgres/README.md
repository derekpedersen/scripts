# postgres

Module for postgres-related tooling and shell helpers.

## Files

- install.sh: install postgres through the central installer runtime.
- uninstall.sh: uninstall postgres through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for postgres installation on Windows.

## Usage

From repo root:

```bash
bash ./tools.install.sh postgres
```

```bash
bash ./tools.uninstall.sh postgres
```

PowerShell (Windows):

```powershell
pwsh ./postgres/install.windows.ps1
```

