# jq

Module for jq-related tooling and shell helpers.

## Files

- install.sh: install jq through the central installer runtime.
- uninstall.sh: uninstall jq through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for jq installation on Windows.

## Usage

From repo root:

```bash
bash ./tools.install.sh jq
```

```bash
bash ./tools.uninstall.sh jq
```

PowerShell (Windows):

```powershell
pwsh ./jq/install.windows.ps1
```

