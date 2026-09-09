# golang

Module for golang-related tooling and shell helpers.

## Files

- install.sh: install golang through the central installer runtime.
- uninstall.sh: uninstall golang through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for golang installation on Windows.

## Usage

From repo root:

```bash
bash ./tools/install.sh golang
```

```bash
bash ./tools/uninstall.sh golang
```

PowerShell (Windows):

```powershell
pwsh ./golang/install.windows.ps1
```

