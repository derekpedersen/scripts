# mysql

Module for mysql-related tooling and shell helpers.

## Files

- install.sh: install mysql through the central installer runtime.
- uninstall.sh: uninstall mysql through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for mysql installation on Windows.

## Usage

From repo root:

```bash
bash ./tools.install.sh mysql
```

```bash
bash ./tools.uninstall.sh mysql
```

PowerShell (Windows):

```powershell
pwsh ./mysql/install.windows.ps1
```

