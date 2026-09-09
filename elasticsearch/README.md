# elasticsearch

Module for elasticsearch-related tooling and shell helpers.

## Files

- install.sh: install elasticsearch through the central installer runtime.
- uninstall.sh: uninstall elasticsearch through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for elasticsearch installation on Windows.

## Usage

From repo root:

```bash
bash ./tools/install.sh elasticsearch
```

```bash
bash ./tools/uninstall.sh elasticsearch
```

PowerShell (Windows):

```powershell
pwsh ./elasticsearch/install.windows.ps1
```

