# wget

Module for wget-related tooling and shell helpers.

## Files

- install.sh: install wget through the central installer runtime.
- uninstall.sh: uninstall wget through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for wget installation on Windows.

## Usage

From repo root:

```bash
bash ./tools/install.sh wget
```

```bash
bash ./tools/uninstall.sh wget
```

PowerShell (Windows):

```powershell
pwsh ./wget/install.windows.ps1
```

