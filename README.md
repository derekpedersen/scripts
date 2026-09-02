# Scripts

Repository to hold all my helper scripts.

## Bash

- [bash/README.md](bash/README.md) — Bash helpers and shortcuts for Git, Docker, and Kubernetes
- [bash/git.bash](bash/git.bash)
- [bash/docker.bash](bash/docker.bash)
- [bash/kubernetes.bash](bash/kubernetes.bash)

## Tools

- [tools/install.sh](tools/install.sh) — installs common development tools on macOS or Debian-based Linux

Built-in bundle names:

- `default` — core developer setup
- `full` — default plus broader dev tools and common local services
- `dev` — same as `full`
- `services` — local database/service stack including MongoDB, RabbitMQ, Elasticsearch, and Kafka

Supported tool names:

- `git`
- `nvm`
- `node`
- `helm`
- `kubectl` / `kubernetes-cli`
- `golang`
- `docker`
- `dotnet` / `dotnetcore`
- `vscode` / `code`
- `curl`
- `unzip`
- `wget`
- `python3`
- `postgres`
- `redis`
- `mysql`
- `clickhouse`
- `mongodb`
- `rabbitmq`
- `elasticsearch`
- `kafka`

Examples:

```bash
bash ./tools/install.sh default
bash ./tools/install.sh full
bash ./tools/install.sh dev
bash ./tools/install.sh services
bash ./tools/install.sh git nvm node kubectl helm docker dotnetcore vscode
```

The default bundle installs the core dev setup in dependency-safe order, using `nvm` first and then installing Node LTS through it. The service bundles are intentionally separate so you can install only the local databases and dev services you want.

## Helm

- [helm/set-version.sh](helm/set-version.sh)
