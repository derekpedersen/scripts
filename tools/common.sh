#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Tool bundle definitions
# ============================================================
#
# Purpose:
#   Maintain the canonical install bundles used by the repo's
#   developer bootstrap installer.
#
# Notes:
#   Keep bundle names stable and update the usage text in tools/install.sh
#   whenever adding or changing install options.
# ============================================================

DEFAULT_BUNDLE=(
  git
  curl
  wget
  unzip
  python3
  nvm
  node
  golang
  kubectl
  helm
  docker
  dotnetcore
  vscode
)

FULL_BUNDLE=(
  git
  curl
  wget
  unzip
  python3
  nvm
  node
  golang
  kubectl
  helm
  docker
  dotnetcore
  vscode
  code
  gcloud
  awscli
  eksctl
  az
  doctl
  jq
  yq
  postgres
  redis
  mysql
  clickhouse
  mongodb
  rabbitmq
)

configure_git_identity() {
  local name="${GIT_USER_NAME:-}"
  local email="${GIT_USER_EMAIL:-}"

  if [[ -z "$name" || -z "$email" ]]; then
    echo "Git identity not configured."
    echo "Set GIT_USER_NAME and GIT_USER_EMAIL before running git-config."
    return 1
  fi

  git config --global user.name "$name"
  git config --global user.email "$email"

  echo "Git identity configured:"
  git config --global --get user.name
  git config --global --get user.email
}

configure_git_signing() {
  if ! command -v gpg >/dev/null 2>&1; then
    echo "GPG is not installed yet. Install gpg first or include it in the install command."
    return 1
  fi

  git config --global commit.gpgsign true
  git config --global tag.gpgSign true
  git config --global gpg.program "$(command -v gpg)"

  local signing_key="${GPG_KEY_ID:-}"
  if [[ -z "$signing_key" ]]; then
    signing_key="$(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | awk '/sec/{print $2; exit}' | cut -d/ -f2 || true)"
  fi

  if [[ -n "$signing_key" ]]; then
    git config --global user.signingkey "$signing_key"
  fi

  echo "Git commit signing enabled."
  git config --global --get user.signingkey || true
}

configure_gpg_key() {
  local name="${GIT_USER_NAME:-}"
  local email="${GIT_USER_EMAIL:-}"

  if [[ -z "$name" || -z "$email" ]]; then
    echo "Git identity not configured. Set GIT_USER_NAME and GIT_USER_EMAIL before creating a GPG key."
    return 1
  fi

  if ! command -v gpg >/dev/null 2>&1; then
    echo "GPG is not installed yet. Install it with: bash ./tools/install.sh gpg"
    return 1
  fi

  if gpg --list-secret-keys --with-colons "$email" 2>/dev/null | grep -q '^sec:'; then
    echo "A GPG signing key already exists for $email"
    local existing_key
    existing_key="$(gpg --list-secret-keys --keyid-format LONG "$email" 2>/dev/null | awk '/sec/{print $2; exit}' | cut -d/ -f2 || true)"
    if [[ -n "$existing_key" ]]; then
      export GPG_KEY_ID="$existing_key"
      git config --global user.signingkey "$existing_key"
    fi
    return 0
  fi

  GNUPGHOME="${GNUPGHOME:-$HOME/.gnupg}"
  mkdir -p "$GNUPGHOME"
  chmod 700 "$GNUPGHOME"

  echo "Generating a new GPG signing key for $name <$email>..."
  gpg --batch --pinentry-mode loopback --passphrase '' --quick-generate-key "$name <$email>" ed25519 sign 1y

  local generated_key
  generated_key="$(gpg --list-secret-keys --keyid-format LONG "$email" 2>/dev/null | awk '/sec/{print $2; exit}' | cut -d/ -f2 || true)"

  if [[ -n "$generated_key" ]]; then
    export GPG_KEY_ID="$generated_key"
    git config --global user.signingkey "$generated_key"
    echo "Generated GPG key: $generated_key"
    return 0
  fi

  echo "Unable to determine the generated GPG key ID."
  return 1
}

configure_ssh_key() {
  local key_path="${SSH_KEY_PATH:-$HOME/.ssh/id_ed25519}"
  local email="${SSH_KEY_EMAIL:-${GIT_USER_EMAIL:-}}"
  local comment="${SSH_KEY_COMMENT:-${GIT_USER_NAME:-${USER:-$(whoami)}}@$(hostname)}"

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if [[ -f "$key_path" ]]; then
    echo "SSH key already exists at $key_path"
    return 0
  fi

  if [[ -z "$email" ]]; then
    echo "SSH key not configured. Set SSH_KEY_EMAIL or GIT_USER_EMAIL before running ssh-key."
    return 1
  fi

  ssh-keygen -t ed25519 -C "$email" -f "$key_path" -N "" -q

  if command -v ssh-agent >/dev/null 2>&1; then
    eval "$(ssh-agent -s)" >/dev/null 2>&1 || true
  fi

  if command -v ssh-add >/dev/null 2>&1; then
    ssh-add "$key_path" >/dev/null 2>&1 || true
  fi

  echo "SSH key created at $key_path"
  echo "Public key:"
  cat "$key_path.pub"
}

configure_identity_interactive() {
  local name="${GIT_USER_NAME:-}"
  local email="${GIT_USER_EMAIL:-}"
  local ssh_email="${SSH_KEY_EMAIL:-}"
  local answer=""

  if [[ -z "$name" ]]; then
    read -r -p 'Git user name: ' name
  fi

  if [[ -z "$email" ]]; then
    read -r -p 'Git user email: ' email
  fi

  if [[ -n "$name" && -n "$email" ]]; then
    export GIT_USER_NAME="$name"
    export GIT_USER_EMAIL="$email"
    configure_git_identity || true
  fi

  if ! command -v gpg >/dev/null 2>&1; then
    if [[ -n "${1:-}" ]]; then
      echo "GPG not installed. Run: $0 gpg"
    fi
  else
    read -r -p "Generate a new GPG signing key for ${email:-$name}? [y/N]: " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      configure_gpg_key || true
      configure_git_signing || true
    else
      configure_git_signing || true
    fi
  fi

  if [[ -z "$ssh_email" ]]; then
    read -r -p "SSH key email [default: ${email:-your-email@example.com}]: " ssh_email
  fi

  if [[ -z "$ssh_email" ]]; then
    ssh_email="${email:-}"
  fi

  if [[ -n "$ssh_email" ]]; then
    export SSH_KEY_EMAIL="$ssh_email"
    configure_ssh_key || true
  fi
}

SERVICES_BUNDLE=(
  postgres
  redis
  mysql
  clickhouse
  mongodb
  rabbitmq
  elasticsearch
  kafka
)

CLOUD_BUNDLE=(
  gcloud
  awscli
  eksctl
  doctl
  az
  jq
  yq
)

ensure_root_or_sudo() {
  if [[ "$(id -u)" -eq 0 ]]; then
    SUDO=""
  elif command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    SUDO=""
  fi
}

install_pkg() {
  local pkg="$1"
  if command -v "$pkg" >/dev/null 2>&1; then
    echo "$pkg already installed"
    return
  fi

  if [[ -n "${SUDO:-}" ]]; then
    $SUDO apt-get install -y "$pkg"
  else
    apt-get install -y "$pkg"
  fi
}
