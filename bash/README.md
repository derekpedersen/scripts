# Bashful

> A small collection of useful Bash functions and shortcuts for Git, Docker, and Kubernetes.

**Bashful** is a collection of practical Bash helpers for everyday development. It keeps commonly used commands close at hand without requiring you to remember long command-line incantations.

The goal is simple: **less typing, fewer mistakes, faster workflows.**

## What's Included

| Area          | What you'll find                                                  |
| ------------- | ----------------------------------------------------------------- |
| 🐙 Git        | Branches, status, logs, cleanup, repository navigation            |
| 🐳 Docker     | Containers, Compose, logs, shells, disk cleanup                   |
| ☸️ Kubernetes | Contexts, namespaces, pods, logs, debugging, rollouts             |
| 🛠️ Bash      | Small utilities for navigation, processes, ports, and development |

## Quick Start

The preferred method is to install the auto-loader into your shell profile. This keeps the helpers available in every new terminal session without manually sourcing files.

From this repo, run:

```bash
bash ./bash/install.sh
```

Or install directly from GitHub:

```bash
tmpdir="$(mktemp -d)" && curl -fsSL https://codeload.github.com/derekpedersen/scripts/tar.gz/refs/heads/main | tar -xz -C "$tmpdir" && bash "$tmpdir/scripts-main/bash/install.sh"; rc=$?; rm -rf "$tmpdir"; exit $rc
```

The installer is interactive and file-aware. It scans the helper folder for `.bash` files and asks which ones you want enabled, such as:

- `git.bash`
- `docker.bash`
- `kubernetes.bash`

If a new helper file is later added under this folder, rerunning the installer will detect it and prompt you to include it.

It automatically configures the correct profile for your shell:

- `.zshrc` for Zsh
- `.bashrc` for Bash on Ubuntu, Debian, Mint, and most Linux systems
- `.bash_profile` for macOS Bash login shells

After installation, reload your shell:

```bash
source ~/.bashrc
```

If you use Bash login shells on macOS, use:

```bash
source ~/.bash_profile
```

Once loaded, the selected helpers are automatically sourced for you.

## Docker

Bashful provides shortcuts for common Docker workflows.

### Containers

```bash
dps                 # Running containers
dpsa                # All containers
dlogs CONTAINER     # Follow container logs
dsh CONTAINER       # Shell into a container
```

### Docker Compose

```bash
dc up
dcdown
dcup
```

### Cleanup

Docker cleanup helpers are intentionally explicit and destructive commands prompt for confirmation.

```bash
docker-clean-disk-usage
docker-clean-containers
docker-clean-dangling-images
docker-clean-unused-images
docker-clean-networks
docker-clean-volumes
docker-clean-build-cache
docker-clean-old
docker-clean-all
```

For example:

```text
$ docker-clean-old

This will remove Docker containers, images, and build cache unused for 7+ days.
Continue? [y/N]
```

`docker-clean-all` performs an aggressive cleanup of unused Docker resources, including volumes.

## Kubernetes

Kubernetes helpers focus on the commands you tend to type repeatedly while developing and troubleshooting.

### Contexts & Namespaces

```bash
kctx                # Current context
kctxs               # List contexts
kuse production     # Switch context
kns                 # Current namespace
kuse-ns staging     # Switch namespace
```

### Pods

```bash
kpods               # Pods in current namespace
kpodsa              # Pods in all namespaces
kwatch              # Watch pods
kbad                # Find problematic pods
kcrash              # Find CrashLoopBackOff pods
kpending            # Find pending pods
krestarts            # Find pods with restarts
```

### Logs & Shells

```bash
klogs POD
klogsf POD
klogsp POD

kexec POD
kexecbash POD
```

### Deployments

```bash
kdep
krestart API
krollout API
khistory API
krollback API
kscale API 3
```

### Debugging

```bash
kevents
kerrors
khealth
kdebug
```

For interactive workflows, Bashful can optionally use [`fzf`](https://github.com/junegunn/fzf):

```bash
kpod
kpod-shell
kpod-logs
```

These let you select a pod interactively instead of copying and pasting pod names.

## Git

Git helpers make common repository operations a little quicker.

```bash
gs                  # Short status
gl                  # Pretty commit log
git-current-branch  # Current branch
git-recent-branches # Recently updated branches
croot               # Jump to repository root
```

Clean up local branches that have already been merged:

```bash
git-clean-merged
```

## Philosophy

Bashful follows a few simple principles:

### Keep commands discoverable

Functions should have names that are easy to guess.

```bash
kpods
klogs
kdep
knodes
```

are preferable to cryptic aliases that require memorization.

### Don't hide destructive operations

Commands that delete data should make that obvious and, where appropriate, ask for confirmation.

```bash
docker-clean-volumes
docker-clean-all
git-clean-merged
```

### Prefer functions over aliases

Aliases are great for simple substitutions:

```bash
alias k='kubectl'
alias ll='ls -lah'
```

Functions are better when arguments, validation, or logic are involved.

### Stay dependency-light

Most helpers use only Bash and the CLI tools they wrap.

Optional tools such as `fzf` are detected rather than required for the entire collection.

## Directory Structure

A typical Bashful repository looks like:

```text
bashful/
├── README.md
├── git.sh
├── docker.sh
├── kubernetes.sh
└── bash.sh
```

Additional helper files can be added as the collection grows.

## Shell Compatibility

Bashful is designed for **Bash**.

It is primarily intended for:

* macOS
* Linux
* WSL
* Developer containers / remote Linux environments

Some commands depend on tools being installed separately, such as:

* `git`
* `docker`
* `kubectl`
* `fzf` (optional)

## Safety

Bashful includes commands capable of deleting local data.

In particular:

```bash
docker-clean-volumes
docker-clean-all
```

can permanently remove Docker data.

Always understand what a cleanup command does before confirming it.

When in doubt, inspect disk usage first:

```bash
docker-clean-disk-usage
```

## Customization

Bashful is intentionally just Bash.

Fork it, remove commands you don't use, change aliases, add your own functions, and adapt it to your workflow.

For example, you might add project-specific helpers:

```bash
project-dev() {
    docker compose up --build
}
```

or Kubernetes shortcuts for your organization's deployment workflow.

## Contributing

Contributions are welcome.

Good additions are:

* Frequently repeated commands
* Small workflow improvements
* Safe debugging helpers
* Cross-platform Bash utilities
* Functions with clear, memorable names

Avoid adding large frameworks or dependencies unless there is a compelling reason.

If a command can be expressed clearly with a small Bash function, that's usually the Bashful way.

## License

MIT License

---

**Bashful** — because your terminal shouldn't make you type the same thing twice.
