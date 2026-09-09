# redis

Module for redis-related tooling and shell helpers.

## Files

- install.sh: install redis through the central installer runtime.
- uninstall.sh: uninstall redis through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for redis installation on Windows.

## Usage

From repo root:

```bash
bash ./tools/install.sh redis
```

```bash
bash ./tools/uninstall.sh redis
```

PowerShell (Windows):

```powershell
pwsh ./redis/install.windows.ps1
```

