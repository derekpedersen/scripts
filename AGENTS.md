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
- `bash/`: shell helper scripts and aliases, usually ending in `.bash`
- `tools/`: installer controller and OS-specific install logic
- `helm/`: Helm-related helper scripts
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
- Preserve compatibility with macOS and Debian-based Linux unless specifically directed otherwise.
