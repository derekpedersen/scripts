# eksctl

Module for eksctl-related tooling and shell helpers.

## Files

- install.sh: install eksctl through the central installer runtime.
- uninstall.sh: uninstall eksctl through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for eksctl installation on Windows.

## Usage

From repo root:

```bash
bash ./tools.install.sh eksctl
```

```bash
bash ./tools.uninstall.sh eksctl
```

PowerShell (Windows):

```powershell
pwsh ./eksctl/install.windows.ps1
```

