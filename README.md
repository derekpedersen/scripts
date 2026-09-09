# Scripts

Reusable shell helpers, DevOps bootstrap scripts, and small operational tooling for local development.

## What this repo contains

- [bash.README.md](bash.README.md) for shell helper usage and conventions
- [tools](tools) for OS-aware developer tool installation
- [services](services) for isolated local Docker Compose service stacks
- [helm](helm) for Helm chart version stamping helpers
- [Makefile](Makefile) for shared build/test orchestration
- [Jenkinsfile](Jenkinsfile) for CI entry points that call the shared Makefile targets

## Repository map

### Bash helpers

- [bash.install.sh](bash.install.sh): interactive helper loader that writes a managed source block to your shell profile
- [bash.uninstall.sh](bash.uninstall.sh): managed helper uninstaller
- [bash.README.md](bash.README.md): detailed helper documentation
- [git/bash.sh](git/bash.sh): git workflow and cleanup helpers
- [docker/bash.sh](docker/bash.sh): Docker and cleanup helpers
- [kubectl/bash.sh](kubectl/bash.sh): kubectl and troubleshooting helpers
- [aws/bash.sh](aws/bash.sh): AWS CLI helpers
- [gcloud/bash.sh](gcloud/bash.sh): Google Cloud helpers
- [az/bash.sh](az/bash.sh): Azure CLI helpers
- [doctl/bash.sh](doctl/bash.sh): DigitalOcean helpers
- [cloud/bash.sh](cloud/bash.sh): multi-cloud status helper

### Tool installer

- [tools/install.sh](tools/install.sh): main installer controller
- [tools/common.sh](tools/common.sh): bundle definitions, aliases, and identity helpers (git, gpg, ssh)
- [tools/module-runtime.sh](tools/module-runtime.sh): shared module dispatcher runtime used by per-tool installers
- [git/install.sh](git/install.sh): example per-tool installer module
- [git/install.windows.ps1](git/install.windows.ps1): example Windows wrapper for a module install

### Local services

- [services/docker-compose.yml](services/docker-compose.yml): isolated local stack for PostgreSQL, Redis, RabbitMQ, and MongoDB
- [services/local-dev.sh](services/local-dev.sh): interactive preset-based launcher for starting and stopping the local stack
- [services/README.md](services/README.md): stack usage notes and port references

### Helm

- [helm/set-version.sh](helm/set-version.sh): sets version and appVersion in .helm/Chart.yaml from timestamp and current git commit

### Guidance and automation

- [AGENTS.md](AGENTS.md): repository agent guidance
- [.github/copilot-instructions.md](.github/copilot-instructions.md): Copilot-specific conventions

## Quick start

### Install Bash helpers

From this repo:

```bash
bash ./bash.install.sh
```

One-liner from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/derekpedersen/scripts/main/bash.install.sh | bash
```

The installer concatenates the selected helper files into a single managed file (`~/.scripts-bash-helpers`) and sources it from your shell profile. The profile only references that stable file, so helpers keep working even if the repo clone or bootstrap temp directory is removed. Rerun the installer to update the helpers.

Optional overrides for testing another branch or fork, or changing the managed helpers file:

```bash
SCRIPTS_REF=feature/my-branch SCRIPTS_REPO=derekpedersen/scripts curl -fsSL https://raw.githubusercontent.com/derekpedersen/scripts/main/bash.install.sh | bash
SCRIPTS_HELPERS_FILE=~/.my-helpers curl -fsSL https://raw.githubusercontent.com/derekpedersen/scripts/main/bash.install.sh | bash
```

### Install developer tools

From this repo:

```bash
bash ./tools/install.sh default
```

Native Windows 11+ support is included. Use either Git Bash/MSYS, PowerShell with the bundled wrapper, or WSL/Linux paths as appropriate:

```powershell
pwsh ./tools/install.ps1 default
```

```bash
bash ./tools/install.sh default
```

One-liner from GitHub (replace default with full, dev, services, or cloud):

```bash
curl -fsSL https://raw.githubusercontent.com/derekpedersen/scripts/main/tools/install.sh | bash -s -- default
```

Optional override for testing another branch or fork during bootstrap:

```bash
SCRIPTS_REF=feature/my-branch SCRIPTS_REPO=derekpedersen/scripts curl -fsSL https://raw.githubusercontent.com/derekpedersen/scripts/main/tools/install.sh | bash -s -- default
```

### Uninstall Bash helpers

```bash
bash ./bash.uninstall.sh
```

This removes the managed source block from your shell profile and deletes the generated helper file (`~/.scripts-bash-helpers`).

### Uninstall developer tools

```bash
bash ./tools/uninstall.sh default
bash ./tools/uninstall.sh kubectl docker
bash ./tools/uninstall.sh services --dry-run
```

Windows examples:

```powershell
pwsh ./tools/uninstall.ps1 default
pwsh ./tools/uninstall.ps1 docker vscode --dry-run
```

The uninstall flow mirrors the install pattern: it is explicit, target-based, and safe by default.

## Tool installer bundles

- default: core developer setup
- full: default plus broader dev, cloud tooling, and local services
- dev: alias of full
- services: local data/service stack
- cloud: cloud CLIs and JSON/YAML helpers

Bundle quick examples:

```bash
bash ./tools/install.sh default
bash ./tools/install.sh full
bash ./tools/install.sh dev
bash ./tools/install.sh services
bash ./tools/install.sh cloud
```

Dry run example:

```bash
bash ./tools/install.sh full --dry-run
```

Identity setup examples:

```bash
GIT_USER_NAME='Jane Doe' GIT_USER_EMAIL='jane@example.com' bash ./tools/install.sh git-config
GIT_USER_NAME='Jane Doe' GIT_USER_EMAIL='jane@example.com' GPG_KEY_ID='ABC123DEF456' bash ./tools/install.sh gpg git-signing
SSH_KEY_EMAIL='jane@example.com' bash ./tools/install.sh ssh-key
bash ./tools/install.sh identity
```

## Supported tool names

Canonical module names:

- git
- gpg
- curl
- wget
- unzip
- python3
- nvm
- node
- golang
- kubectl
- helm
- docker
- dotnetcore
- vscode
- gcloud
- aws
- eksctl
- az
- doctl
- jq
- yq
- postgres
- redis
- mysql
- clickhouse
- mongodb
- rabbitmq
- elasticsearch
- kafka
- git-config
- git-signing
- ssh-key
- identity

Legacy alias names (still supported):

- kubernetes-cli -> kubectl
- google-cloud -> gcloud
- awscli -> aws
- azure -> az
- azure-cli -> az
- digitalocean -> doctl
- doks -> doctl
- dotnet -> dotnetcore
- code -> vscode

Use canonical module names in scripts and examples.

## Helm helper usage

Run from repo root:

```bash
bash ./helm/set-version.sh
```

This updates .helm/Chart.yaml fields:

- version to current timestamp format YYYY.MM.DD.HHMM
- appVersion to the current git commit SHA

## CI behavior


The shared CI entry points are:

- `make build` for syntax checks and Helm version stamping validation
- `make test` for installer smoke tests, including install and uninstall dry-run coverage

[Jenkinsfile](Jenkinsfile) now calls those same targets so local runs and CI stay aligned.

Build/test coverage includes:

- syntax of files in [bash](bash)
- syntax of files in [tools](tools)
- syntax of files in [helm](helm)
- Helm `set-version.sh` behavior against a temporary fixture
- installer smoke tests for default, services, and cloud bundles using dry-run mode
- uninstaller smoke tests for default, services, and cloud bundles using dry-run mode
