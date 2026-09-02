#!/usr/bin/env bash
set -euo pipefail

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
  doctl
  postgres
  redis
  mysql
  clickhouse
  mongodb
  rabbitmq
)

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
