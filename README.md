# Scripts

Reusable shell helpers, DevOps bootstrap scripts, and small operational tooling for local development.

## What this repo contains

- [bash](bash) for shell helper functions and aliases
- [tools](tools) for OS-aware developer tool installation
- [helm](helm) for Helm chart version stamping helpers
- [Jenkinsfile](Jenkinsfile) for CI validation of script syntax and installer smoke checks

## Repository map

### Bash helpers

- [bash/install.sh](bash/install.sh): interactive helper loader that writes a managed source block to your shell profile
- [bash/README.md](bash/README.md): detailed helper documentation
- [bash/git.bash](bash/git.bash): git workflow and cleanup helpers
- [bash/docker.bash](bash/docker.bash): Docker and cleanup helpers
- [bash/kubernetes.bash](bash/kubernetes.bash): kubectl and troubleshooting helpers
- [bash/aws.bash](bash/aws.bash): AWS CLI helpers
- [bash/gcloud.bash](bash/gcloud.bash): Google Cloud helpers
- [bash/azure.bash](bash/azure.bash): Azure CLI helpers
- [bash/doctl.bash](bash/doctl.bash): DigitalOcean helpers
- [bash/cloud.bash](bash/cloud.bash): multi-cloud status helper

### Tool installer

- [tools/install.sh](tools/install.sh): main installer controller
- [tools/common.sh](tools/common.sh): bundle definitions and identity helpers (git, gpg, ssh)
- [tools/macos.sh](tools/macos.sh): macOS installation logic
- [tools/linux.sh](tools/linux.sh): Debian-based Linux installation logic

### Helm

- [helm/set-version.sh](helm/set-version.sh): sets version and appVersion in .helm/Chart.yaml from timestamp and current git commit

### Guidance and automation

- [AGENTS.md](AGENTS.md): repository agent guidance
- [.github/copilot-instructions.md](.github/copilot-instructions.md): Copilot-specific conventions

## Quick start

### Install Bash helpers

From this repo:

```bash
bash ./bash/install.sh
```

One-liner from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/derekpedersen/scripts/main/bash/install.sh | bash
```

Optional override for testing another branch or fork during bootstrap:

```bash
SCRIPTS_REF=feature/my-branch SCRIPTS_REPO=derekpedersen/scripts curl -fsSL https://raw.githubusercontent.com/derekpedersen/scripts/main/bash/install.sh | bash
```

### Install developer tools

From this repo:

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

- git
- gpg
- nvm
- node
- helm
- kubectl
- kubernetes-cli
- golang
- docker
- gcloud
- google-cloud
- aws
- awscli
- eksctl
- az
- azure
- azure-cli
- doctl
- digitalocean
- doks
- dotnet
- dotnetcore
- vscode
- code
- curl
- unzip
- wget
- python3
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

## Helm helper usage

Run from repo root:

```bash
bash ./helm/set-version.sh
```

This updates .helm/Chart.yaml fields:

- version to current timestamp format YYYY.MM.DD.HHMM
- appVersion to the current git commit SHA

## CI behavior

[Jenkinsfile](Jenkinsfile) validates:

- syntax of files in [bash](bash)
- syntax of files in [tools](tools)
- syntax of files in [helm](helm)
- installer smoke tests for default, services, and cloud bundles using dry-run mode
