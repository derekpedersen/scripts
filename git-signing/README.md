# git-signing

Module for git-signing-related tooling and shell helpers.

## Files

- install.sh: install git-signing through the central installer runtime.
- uninstall.sh: uninstall git-signing through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for git-signing installation on Windows.

## Usage

From repo root:

```bash
bash ./tools/install.sh git-signing
```

```bash
bash ./tools/uninstall.sh git-signing
```

PowerShell (Windows):

```powershell
pwsh ./git-signing/install.windows.ps1
```

