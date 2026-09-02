# Scripts

Repository to hold all my helper scripts.

## Bash

- [bash/README.md](bash/README.md) — Bash helpers and shortcuts for Git, Docker, and Kubernetes
- [bash/git.bash](bash/git.bash)
- [bash/docker.bash](bash/docker.bash)
- [bash/kubernetes.bash](bash/kubernetes.bash)

## Tools

- [tools/install.sh](tools/install.sh) — installs common development tools on macOS or Debian-based Linux

Supported tool names:

- `git`
- `nvm`
- `helm`
- `kubectl` / `kubernetes-cli`
- `golang`
- `docker`
- `dotnet` / `dotnetcore`
- `vscode`
- `curl`
- `unzip`
- `wget`
- `python3`

Examples:

```bash
bash ./tools/install.sh default
bash ./tools/install.sh full
bash ./tools/install.sh dev
bash ./tools/install.sh git nvm kubectl helm docker dotnetcore vscode
```

The default bundle installs the core dev setup in dependency-safe order, with `kubectl` before `helm` and `nvm` preferred for Node.

## Helm

- [helm/set-version.sh](helm/set-version.sh)
