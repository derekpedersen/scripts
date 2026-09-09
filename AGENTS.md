# AGENTS.md

## Overview
This repository contains bash helper modules, local developer install scripts, and small operational automation for macOS and Debian-based Linux environments.

## Principles
- Keep automation safe to rerun.
- Favor explicit, readable shell code over clever or opaque patterns.
- Keep OS-specific logic separate from the controller logic.
- Prefer bundle-based install flows and expose those names clearly in usage output.
- Treat destructive tooling as opt-in and confirm before deletion or cleanup.

## File layout
- `bash/`: helper installer entrypoints and docs
- `tools/`: installer controllers and shared runtime/helpers
- `<tool>/`: per-tool modules at repo root containing `install.sh`, `uninstall.sh`, optional `install.windows.ps1`, and optional `bash.sh`
- `helm/`: Helm-related helper scripts
- `Makefile`: shared build and test entry points used by both local runs and Jenkins
- `README.md`: top-level docs for repo usage

## Comment and documentation conventions
- Use the project header format shown in existing scripts.
- Keep comments short and purpose-oriented.
- Update documentation when bundle names, tool names, or helper behavior change.

## Shell guidelines
- Use `set -euo pipefail` where appropriate.
- Validate user input and provide helpful usage text.
- Check for command availability before installation or execution.
- Prefer idempotent installation logic so rerunning scripts does not duplicate profile entries or reinstall packages unnecessarily.

## AI / automation guidance
- Keep changes consistent with the current repo patterns.
- Do not add hidden magic; prefer discoverable names and straightforward behavior.
- Update both bundle definitions and user-facing usage output when adding or changing install options.
- Prefer adding new CI and validation behavior to `Makefile` targets first, then have `Jenkinsfile` call those targets.
- Keep `build` for fast validation and `test` for installer smoke checks, including install and uninstall dry-run coverage.
- Preserve compatibility with macOS and Debian-based Linux unless specifically directed otherwise.
