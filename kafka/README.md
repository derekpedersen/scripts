# kafka

Module for kafka-related tooling and shell helpers.

## Files

- install.sh: install kafka through the central installer runtime.
- uninstall.sh: uninstall kafka through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for kafka installation on Windows.

## Usage

From repo root:

```bash
bash ./tools/install.sh kafka
```

```bash
bash ./tools/uninstall.sh kafka
```

PowerShell (Windows):

```powershell
pwsh ./kafka/install.windows.ps1
```

