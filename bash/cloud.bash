#!/usr/bin/env bash

# Cloud helper bundle that loads the AWS, GCP, Azure, and DigitalOcean helpers.
# This file is a convenience wrapper for multi-cloud environments.

if command -v aws >/dev/null 2>&1; then
  :
fi

# The individual files are auto-sourced by bash/install.sh when enabled.
# This file intentionally keeps the cloud-related shortcuts grouped together.

cloud-status() {
  echo "Cloud tools available:"
  for tool in aws gcloud az doctl; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "  - $tool"
    else
      echo "  - $tool (not installed)"
    fi
  done
}
