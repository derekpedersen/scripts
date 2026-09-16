# Scripts

Reusable shell helpers, DevOps bootstrap scripts, and small operational tooling for local development.

## What this repo contains

- [.bash/README.md](.bash/README.md) for shell helper usage and conventions
- [.tools/README.md](.tools/README.md) for the installer/runtime layer and bundle-based orchestration
- [.services](.services) for isolated local Docker Compose service stacks
- [Makefile](Makefile) for shared build/test orchestration
- [Jenkinsfile](Jenkinsfile) for CI entry points that call the shared Makefile targets

This repo intentionally separates concerns into three domains:

| Domain | Location | Purpose |
| --- | --- | --- |
| Bash helpers | [.bash](.bash) | Shell bootstrap, helper installation, and shared bash snippets used across tool modules. |
| Installer/runtime | [.tools](.tools) | Bundle orchestration, install/uninstall controllers, OS-specific logic, and shared runtime behavior. |
| Local service stack | [.services](.services) | Docker Compose-based local dev services such as PostgreSQL, Redis, RabbitMQ, MongoDB, Grafana, and Prometheus. |

The repo-root tool folders are intentionally atomized and individual: each package such as [docker](docker), [kubectl](kubectl), [aws](aws), [gcloud](gcloud), and [git](git) owns its own install/uninstall flow plus any optional bash helpers or Windows shims.

## Folder catalog

| Folder | Abbrev. | Full name | What it is | Link |
| --- | --- | --- | --- | --- |
| [.bash](.bash) | Bash | Bash helper loader | Shell helper install/uninstall flow and shared bash snippets for local workflows. | [.bash/README.md](.bash/README.md) |
| [.github](.github) | GitHub | GitHub repo config | Repository automation, automation rules, and GitHub-specific guidance for contributors and Copilot. | [GitHub Docs](https://docs.github.com/) |
| [.services](.services) | SVC | Local service stack | Docker Compose stack for PostgreSQL, Redis, RabbitMQ, MongoDB, and observability containers. | [.services/README.md](.services/README.md) |
| [.tools](.tools) | Tools | Tool installer runtime | Bundle-based installer, OS-specific logic, and shared runtime for developer tooling. | [.tools/README.md](.tools/README.md) |
| [aws](aws) | AWS | Amazon Web Services CLI | AWS CLI and AWS-specific helper scripts. | [AWS CLI](https://aws.amazon.com/cli/) |
| [az](az) | Azure | Azure CLI | Microsoft Azure command-line tooling and convenience helpers. | [Azure CLI](https://learn.microsoft.com/cli/azure/) |
| [clickhouse](clickhouse) | CH | ClickHouse | ClickHouse database installer and setup helpers. | [ClickHouse](https://clickhouse.com/) |
| [cloud](cloud) | Cloud | Multi-cloud helpers | Shared cloud-oriented bash helpers for multi-cloud status and context checks. | [Cloud computing](https://en.wikipedia.org/wiki/Cloud_computing) |
| [curl](curl) | Curl | cURL | HTTP client for transfers from the shell. | [curl](https://curl.se/) |
| [docker](docker) | Docker | Docker | Docker CLI helpers and container workflow support. | [Docker](https://www.docker.com/) |
| [doctl](doctl) | DOCTL | DigitalOcean CLI | DigitalOcean command-line interface and convenience commands. | [doctl](https://docs.digitalocean.com/reference/doctl/) |
| [dotnetcore](dotnetcore) | .NET | .NET SDK | .NET runtime and SDK bootstrap helpers. | [.NET](https://dotnet.microsoft.com/) |
| [eksctl](eksctl) | EKSCTL | Amazon EKS CLI | CLI for creating and managing Amazon EKS clusters. | [eksctl](https://eksctl.io/) |
| [elasticsearch](elasticsearch) | ES | Elasticsearch | Elasticsearch install and operational helpers. | [Elasticsearch](https://www.elastic.co/elasticsearch/) |
| [gcloud](gcloud) | GCP | Google Cloud SDK | Google Cloud CLI and helpers for GCP developer workflows. | [Google Cloud SDK](https://cloud.google.com/sdk) |
| [git](git) | Git | Git | Git aliases, workflow helpers, and repo automation commands. | [Git](https://git-scm.com/) |
| [git-config](git-config) | GitCfg | Git config setup | Idempotent Git identity and configuration bootstrap. | [Git configuration](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration) |
| [git-signing](git-signing) | GitSig | Git signing setup | GPG-based signing setup for Git commit and tag verification. | [Signing commits](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work) |
| [golang](golang) | Go | Go toolchain | Go language install and environment bootstrap. | [Go](https://go.dev/) |
| [gpg](gpg) | GPG | GNU Privacy Guard | GPG key generation and signing setup. | [GnuPG](https://gnupg.org/) |
| [helm](helm) | Helm | Helm package manager | Helm chart helpers, release shortcuts, and version stamping tools. | [Helm](https://helm.sh/) |
| [identity](identity) | ID | Identity setup | Combined identity/bootstrap helpers for Git, SSH, and GPG setup. | [Identity management](https://en.wikipedia.org/wiki/Identity_management) |
| [jq](jq) | jq | jq JSON processor | Lightweight JSON parsing and filtering from the shell. | [jq](https://jqlang.github.io/jq/) |
| [kafka](kafka) | Kafka | Apache Kafka | Kafka broker install and local data platform helpers. | [Kafka](https://kafka.apache.org/) |
| [kubectl](kubectl) | kubectl | Kubernetes CLI | Kubernetes administration and cluster troubleshooting helpers. | [kubectl](https://kubernetes.io/docs/reference/kubectl/) |
| [mongodb](mongodb) | MongoDB | MongoDB | MongoDB database metadata and local developer setup. | [MongoDB](https://www.mongodb.com/) |
| [mysql](mysql) | MySQL | MySQL | MySQL database install and config workflow for local apps. | [MySQL](https://www.mysql.com/) |
| [node](node) | Node | Node.js | Node.js runtime and package-manager bootstrap helpers. | [Node.js](https://nodejs.org/) |
| [nvm](nvm) | NVM | Node Version Manager | Node version switching and environment management. | [nvm](https://github.com/nvm-sh/nvm) |
| [postgres](postgres) | PG | PostgreSQL | PostgreSQL database install and local stack support. | [PostgreSQL](https://www.postgresql.org/) |
| [python3](python3) | Py3 | Python 3 | Python 3 runtime setup and related developer helpers. | [Python](https://www.python.org/) |
| [rabbitmq](rabbitmq) | RabbitMQ | RabbitMQ | AMQP broker install and local messaging toolkit support. | [RabbitMQ](https://www.rabbitmq.com/) |
| [redis](redis) | Redis | Redis | In-memory data store and cache setup for local apps. | [Redis](https://redis.io/) |
| [ssh-key](ssh-key) | SSH | SSH key bootstrap | SSH key generation and installation for remote auth. | [OpenSSH](https://www.openssh.com/) |
| [unzip](unzip) | Unzip | Unzip utility | Zip extraction helper and wrappers for local tooling. | [Info-ZIP UnZip](https://www.info-zip.org/UnZip.html) |
| [vscode](vscode) | VS Code | Visual Studio Code | Editor bootstrap and local environment setup for VS Code. | [VS Code](https://code.visualstudio.com/) |
| [wget](wget) | Wget | GNU Wget | Command-line downloader for HTTP and HTTPS fetches. | [GNU Wget](https://www.gnu.org/software/wget/) |
| [yq](yq) | yq | yq YAML processor | YAML processing and transformation helpers. | [yq](https://mikefarah.gitbook.io/yq/) |

## Local services

- [.services/docker-compose.yml](.services/docker-compose.yml): isolated local stack for PostgreSQL, Redis, RabbitMQ, MongoDB, and optional observability services
- [.services/local-dev.sh](.services/local-dev.sh): interactive preset-based launcher for starting and stopping the local stack
- [.services/grafana](.services/grafana): Grafana provisioning config for the local observability stack
- [.services/prometheus](.services/prometheus): Prometheus config for the local observability stack
- [.services/README.md](.services/README.md): stack usage notes and port references

### Guidance and automation

- [AGENTS.md](AGENTS.md): repository agent guidance
- [.github/copilot-instructions.md](.github/copilot-instructions.md): Copilot-specific conventions

## Quick start

### Install Bash helpers

From this repo:

```bash
bash ./.bash/install.sh
```

One-liner from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/derekpedersen/scripts/main/.bash/install.sh | bash
```

The installer concatenates the selected helper files into a single managed file (`~/.scripts-bash-helpers`) and sources it from your shell profile. The profile only references that stable file, so helpers keep working even if the repo clone or bootstrap temp directory is removed. Rerun the installer to update the helpers.

Optional overrides for testing another branch or fork, or changing the managed helpers file:

```bash
SCRIPTS_REF=feature/my-branch SCRIPTS_REPO=derekpedersen/scripts curl -fsSL https://raw.githubusercontent.com/derekpedersen/scripts/main/.bash/install.sh | bash
SCRIPTS_HELPERS_FILE=~/.my-helpers curl -fsSL https://raw.githubusercontent.com/derekpedersen/scripts/main/.bash/install.sh | bash
```

### Install developer tools

From this repo:

```bash
bash ./.tools/install.sh default
```

Native Windows 11+ support is included. Use either Git Bash/MSYS, PowerShell with the bundled wrapper, or WSL/Linux paths as appropriate:

```powershell
pwsh ./.tools/install.ps1 default
```

```bash
bash ./.tools/install.sh default
```

One-liner from GitHub (replace default with full, dev, services, or cloud):

```bash
curl -fsSL https://raw.githubusercontent.com/derekpedersen/scripts/main/.tools/install.sh | bash -s -- default
```

Optional override for testing another branch or fork during bootstrap:

```bash
SCRIPTS_REF=feature/my-branch SCRIPTS_REPO=derekpedersen/scripts curl -fsSL https://raw.githubusercontent.com/derekpedersen/scripts/main/.tools/install.sh | bash -s -- default
```

### Uninstall Bash helpers

```bash
bash ./.bash/uninstall.sh
```

This removes the managed source block from your shell profile and deletes the generated helper file (`~/.scripts-bash-helpers`).

### Uninstall developer tools

```bash
bash ./.tools/uninstall.sh default
bash ./.tools/uninstall.sh kubectl docker
bash ./.tools/uninstall.sh services --dry-run
```

Windows examples:

```powershell
pwsh ./.tools/uninstall.ps1 default
pwsh ./.tools/uninstall.ps1 docker vscode --dry-run
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
bash ./.tools/install.sh default
bash ./.tools/install.sh full
bash ./.tools/install.sh dev
bash ./.tools/install.sh services
bash ./.tools/install.sh cloud
```

Dry run example:

```bash
bash ./.tools/install.sh full --dry-run
```

Identity setup examples:

```bash
GIT_USER_NAME='Jane Doe' GIT_USER_EMAIL='jane@example.com' bash ./.tools/install.sh git-config
GIT_USER_NAME='Jane Doe' GIT_USER_EMAIL='jane@example.com' GPG_KEY_ID='ABC123DEF456' bash ./.tools/install.sh gpg git-signing
SSH_KEY_EMAIL='jane@example.com' bash ./.tools/install.sh ssh-key
bash ./.tools/install.sh identity
```

## CI behavior


The shared CI entry points are:

- `make build` for syntax checks and Helm version stamping validation
- `make test` for installer smoke tests, including install and uninstall dry-run coverage

[Jenkinsfile](Jenkinsfile) now calls those same targets so local runs and CI stay aligned.

Build/test coverage includes:

- syntax of files in [.bash](.bash)
- syntax of files in [.tools](.tools)
- installer smoke tests for default, services, and cloud bundles using dry-run mode
- uninstaller smoke tests for default, services, and cloud bundles using dry-run mode
