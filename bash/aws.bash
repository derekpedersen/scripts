#!/usr/bin/env bash

# AWS helper functions for everyday CLI usage.

aws-current-profile() {
  if [[ -n "${AWS_PROFILE:-}" ]]; then
    echo "$AWS_PROFILE"
  else
    echo "default"
  fi
}

aws-set-profile() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: aws-set-profile <profile>"
    return 1
  fi

  export AWS_PROFILE="$1"
  echo "AWS profile set to: $AWS_PROFILE"
}

aws-set-region() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: aws-set-region <region>"
    return 1
  fi

  export AWS_DEFAULT_REGION="$1"
  echo "AWS default region set to: $AWS_DEFAULT_REGION"
}

aws-ec2-list() {
  aws ec2 describe-instances --output table "$@"
}

aws-eks-list() {
  aws eks list-clusters --output table "$@"
}

aws-s3-list() {
  aws s3 ls "$@"
}

aws-s3-buckets() {
  aws s3api list-buckets --query 'Buckets[].Name' --output table "$@"
}

aws-logs() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: aws-logs <log-group> [aws logs options]"
    return 1
  fi

  aws logs tail "$@" --follow
}

aws-ecr-login() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: aws-ecr-login <account-id> [region]"
    return 1
  fi

  local account_id="$1"
  local region="${2:-us-east-1}"
  aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$account_id.dkr.ecr.$region.amazonaws.com"
}

aws-eks-context() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: aws-eks-context <cluster-name> [region]"
    return 1
  fi

  local cluster_name="$1"
  local region="${2:-${AWS_DEFAULT_REGION:-us-east-1}}"
  aws eks update-kubeconfig --name "$cluster_name" --region "$region"
}

aws-ssm-shell() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: aws-ssm-shell <instance-id>"
    return 1
  fi

  aws ssm start-session --target "$1"
}
