# gpg

Module for gpg-related tooling and shell helpers.

## Files

- install.sh: install gpg through the central installer runtime.
- uninstall.sh: uninstall gpg through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for gpg installation on Windows.

## Usage

From repo root:

```bash
bash ./tools.install.sh gpg
```

```bash
bash ./tools.uninstall.sh gpg
```

PowerShell (Windows):

```powershell
pwsh ./gpg/install.windows.ps1
```

