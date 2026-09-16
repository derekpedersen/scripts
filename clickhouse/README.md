# clickhouse

Module for clickhouse-related tooling and shell helpers.

## Files

- install.sh: install clickhouse through the central installer runtime.
- uninstall.sh: uninstall clickhouse through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for clickhouse installation on Windows.

## Usage

From repo root:

```bash
bash ./tools.install.sh clickhouse
```

```bash
bash ./tools.uninstall.sh clickhouse
```

PowerShell (Windows):

```powershell
pwsh ./clickhouse/install.windows.ps1
```

