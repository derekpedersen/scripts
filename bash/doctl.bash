#!/usr/bin/env bash

# DigitalOcean CLI helpers.

do-current-account() {
  doctl account get
}

do-kubernetes() {
  doctl k8s cluster list --format 'Name,Region,Status,ID' "$@"
}

do-droplets() {
  doctl compute droplet list --format 'ID,Name,Status,Public IPv4,Region' "$@"
}

do-regions() {
  doctl compute region list --format 'Name,Slug' "$@"
}

do-kubeconfig() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: do-kubeconfig <cluster-name>"
    return 1
  fi

  doctl kubernetes cluster kubeconfig save "$1"
}
