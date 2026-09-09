# helm

Module for helm-related tooling and shell helpers.

## Files

- install.sh: install helm through the central installer runtime.
- uninstall.sh: uninstall helm through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for helm installation on Windows.

## Usage

From repo root:

```bash
bash ./tools/install.sh helm
```

```bash
bash ./tools/uninstall.sh helm
```

PowerShell (Windows):

```powershell
pwsh ./helm/install.windows.ps1
```

