# docker

Module for docker-related tooling and shell helpers.

## Files

- bash.sh: shell helpers for docker.
- install.sh: install docker through the central installer runtime.
- uninstall.sh: uninstall docker through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for docker installation on Windows.

## Usage

From repo root:

```bash
bash ./tools/install.sh docker
```

```bash
bash ./tools/uninstall.sh docker
```

PowerShell (Windows):

```powershell
pwsh ./docker/install.windows.ps1
```

