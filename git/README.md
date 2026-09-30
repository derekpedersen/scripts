# git

Module for git-related tooling and shell helpers.

## Files

- bash.sh: shell helpers for git.
- install.sh: install git through the central installer runtime.
  On macOS and Linux this also installs vim and sets it as Git's `core.editor` if no editor is configured.
- uninstall.sh: uninstall git through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for git installation on Windows.

## Usage

From repo root:

```bash
bash ./tools.install.sh git
```

```bash
bash ./tools.uninstall.sh git
```

PowerShell (Windows):

```powershell
pwsh ./git/install.windows.ps1
```

