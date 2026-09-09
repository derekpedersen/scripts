# gcloud

Module for gcloud-related tooling and shell helpers.

## Files

- bash.sh: shell helpers for gcloud.
- install.sh: install gcloud through the central installer runtime.
- uninstall.sh: uninstall gcloud through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for gcloud installation on Windows.

## Aliases

Accepted alias names: google-cloud

## Usage

From repo root:

```bash
bash ./tools/install.sh gcloud
```

```bash
bash ./tools/uninstall.sh gcloud
```

PowerShell (Windows):

```powershell
pwsh ./gcloud/install.windows.ps1
```

