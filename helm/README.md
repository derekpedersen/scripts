# helm

Module for helm-related tooling and shell helpers.

## Files

- bash.sh: shell shortcuts for Helm version helpers
- install.sh: install helm through the central installer runtime.
- uninstall.sh: uninstall helm through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for helm installation on Windows.

## Usage

From repo root:

```bash
bash ./tools.install.sh helm
```

```bash
bash ./bash.install.sh
```

Then use the installed helpers from your shell:

```bash
helm-set-version
helm-show-version
```

```bash
bash ./tools.uninstall.sh helm
```

PowerShell (Windows):

```powershell
pwsh ./helm/install.windows.ps1
```

