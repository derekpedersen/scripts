# python3

Module for python3-related tooling and shell helpers.

## Files

- install.sh: install python3 through the central installer runtime.
- uninstall.sh: uninstall python3 through the central installer runtime.
- install.windows.ps1: PowerShell wrapper for python3 installation on Windows.
- pip-tools.sh: reviewable list of Python tools managed with pip.

## Usage

From repo root:

```bash
bash ./.tools/install.sh python3
```

```bash
bash ./.tools/uninstall.sh python3
```

PowerShell (Windows):

```powershell
pwsh ./python3/install.windows.ps1
```

## Python tool manifest

Use the standalone manifest script to review or install a curated list of Python tools without changing the central installer flow.

### Review the list

```bash
bash python3/pip-tools.sh --list
```

### Preview the installs

```bash
bash python3/pip-tools.sh --dry-run
```

### Install the tools

```bash
bash python3/pip-tools.sh --install
```

### Update the manifest

Edit the `PYTHON_TOOLS` array at the top of `python3/pip-tools.sh` and keep the list in one place for easy review and updates.

Example:

```bash
PYTHON_TOOLS=(
  "pip-tools"
  "pipx"
  "virtualenv"
  "black"
  "ruff"
  "mypy"
  "pytest"
  "pre-commit"
  "requests"
  "boto3"
)
```

### Notes

- This is a user-scoped Python tool manifest, not a central installer bundle change.
- It relies on Python 3 and pip being available first.
- Use `--dry-run` before installing to review changes safely.

