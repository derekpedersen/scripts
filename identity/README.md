# identity

Module for identity-related tooling and shell helpers.

## Files

- install.sh: install identity through the central installer runtime.
- uninstall.sh: uninstall identity through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for identity installation on Windows.

## Usage

From repo root:

```bash
bash ./tools/install.sh identity
```

```bash
bash ./tools/uninstall.sh identity
```

PowerShell (Windows):

```powershell
pwsh ./identity/install.windows.ps1
```

