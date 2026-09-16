# rabbitmq

Module for rabbitmq-related tooling and shell helpers.

## Files

- install.sh: install rabbitmq through the central installer runtime.
- uninstall.sh: uninstall rabbitmq through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for rabbitmq installation on Windows.

## Usage

From repo root:

```bash
bash ./tools.install.sh rabbitmq
```

```bash
bash ./tools.uninstall.sh rabbitmq
```

PowerShell (Windows):

```powershell
pwsh ./rabbitmq/install.windows.ps1
```

