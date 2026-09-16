# doctl

Module for doctl-related tooling and shell helpers.

## Files

- bash.sh: shell helpers for doctl.
- install.sh: install doctl through the central installer runtime.
- uninstall.sh: uninstall doctl through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for doctl installation on Windows.

## Aliases

Accepted alias names: digitalocean, doks

## Usage

From repo root:

```bash
bash ./tools.install.sh doctl
```

```bash
bash ./tools.uninstall.sh doctl
```

PowerShell (Windows):

```powershell
pwsh ./doctl/install.windows.ps1
```

