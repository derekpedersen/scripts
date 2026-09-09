# kubectl

Module for kubectl-related tooling and shell helpers.

## Files

- bash.sh: shell helpers for kubectl.
- install.sh: install kubectl through the central installer runtime.
- uninstall.sh: uninstall kubectl through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for kubectl installation on Windows.

## Aliases

Accepted alias names: kubernetes-cli

## Usage

From repo root:

```bash
bash ./tools.install.sh kubectl
```

```bash
bash ./tools.uninstall.sh kubectl
```

PowerShell (Windows):

```powershell
pwsh ./kubectl/install.windows.ps1
```

