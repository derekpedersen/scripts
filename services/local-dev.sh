#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Local dev service stack
# ============================================================
#
# Purpose:
#   Start a local Docker Compose environment with isolated database and
#   messaging services for local development.
#
# Notes:
#   This stack intentionally uses non-standard ports so it can coexist with
#   common local services that already use 5432, 6379, 5672, and 27017.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

usage() {
  cat <<'EOF'
Usage: local-dev.sh [command]

Commands:
  up                Start the interactive service selector
  start             Start the interactive service selector
  status            Show running containers for this stack
  down              Stop and remove the stack
  logs [service]    Tail logs for a service or all services
  help              Show this help text

Presets:
  everything        postgres + redis + rabbitmq + mongodb
  data-cache        postgres + mongodb + redis
  queue-cache       rabbitmq + redis
  lamp              postgres + redis
  lemp              postgres + redis
  mern              mongodb + redis
  mevn              mongodb + redis
  jamstack          postgres + redis
  serverless        postgres + redis + rabbitmq
  xampp             postgres + redis
  custom            Choose individual services interactively
  exit              Cancel without starting anything

Service ports:
  postgres  => localhost:5433
  redis     => localhost:6380
  rabbitmq  => localhost:5673, management UI localhost:15673
  mongodb   => localhost:27018
EOF
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is required to run this local development stack." >&2
    exit 1
  fi

  if ! docker compose version >/dev/null 2>&1; then
    echo "Docker Compose is required to run this local development stack." >&2
    exit 1
  fi
}

compose_cmd() {
  docker compose -f "$COMPOSE_FILE" "$@"
}

service_names() {
  case "$1" in
    postgres) echo "postgres" ;;
    redis) echo "redis" ;;
    rabbitmq) echo "rabbitmq" ;;
    mongodb) echo "mongodb" ;;
    *) echo "" ;;
  esac
}

preset_services() {
  case "$1" in
    everything) echo "postgres redis rabbitmq mongodb" ;;
    data-cache) echo "postgres mongodb redis" ;;
    queue-cache) echo "rabbitmq redis" ;;
    lamp) echo "postgres redis" ;;
    lemp) echo "postgres redis" ;;
    mern) echo "mongodb redis" ;;
    mevn) echo "mongodb redis" ;;
    jamstack) echo "postgres redis" ;;
    serverless) echo "postgres redis rabbitmq" ;;
    xampp) echo "postgres redis" ;;
    *) echo "" ;;
  esac
}

get_yes_no() {
  local prompt="$1"
  local answer=""

  while true; do
    read -r -p "$prompt [y/N]: " answer
    case "$answer" in
      Y|y|YES|yes)
        return 0
        ;;
      N|n|""|NO|no)
        return 1
        ;;
      *)
        echo "Please answer yes or no."
        ;;
    esac
  done
}

custom_select() {
  local -a services=(postgres redis rabbitmq mongodb elasticsearch)
  local -a selected=()
  local service
  local input=""
  local choice

  echo "Choose one or more services by number."
  echo "Examples: 1 3 5   or   all"
  for idx in "${!services[@]}"; do
    service="${services[$idx]}"
    printf '  %d) %s\n' "$((idx + 1))" "$service"
  done

  while true; do
    read -r -p "Enter selection: " input
    input="${input,,}"

    if [[ -z "$input" ]]; then
      echo "No service selected."
      return 0
    fi

    if [[ "$input" == "all" ]]; then
      printf '%s\n' "${services[@]}"
      return 0
    fi

    selected=()
    valid=true
    for choice in $input; do
      case "$choice" in
        1) selected+=("postgres") ;;
        2) selected+=("redis") ;;
        3) selected+=("rabbitmq") ;;
        4) selected+=("mongodb") ;;
        5) selected+=("elasticsearch") ;;
        *)
          echo "Invalid selection: $choice"
          valid=false
          break
          ;;
      esac
    done

    if [[ "$valid" == true ]]; then
      if [[ ${#selected[@]} -eq 0 ]]; then
        echo "No services selected."
        return 0
      fi
      printf '%s\n' "${selected[@]}"
      return 0
    fi
  done
}

select_preset() {
  cat <<'EOF'
Choose a local stack preset:
  1) everything
  2) data-cache
  3) queue-cache
  4) lamp
  5) lemp
  6) mern
  7) mevn
  8) jamstack
  9) serverless
 10) xampp
 11) custom
 12) exit
EOF

  local choice=""
  while true; do
    read -r -p "Select a preset [1-12]: " choice
    case "$choice" in
      1|everything) echo "everything"; return 0 ;;
      2|data-cache) echo "data-cache"; return 0 ;;
      3|queue-cache) echo "queue-cache"; return 0 ;;
      4|lamp) echo "lamp"; return 0 ;;
      5|lemp) echo "lemp"; return 0 ;;
      6|mern) echo "mern"; return 0 ;;
      7|mevn) echo "mevn"; return 0 ;;
      8|jamstack) echo "jamstack"; return 0 ;;
      9|serverless) echo "serverless"; return 0 ;;
      10|xampp) echo "xampp"; return 0 ;;
      11|custom) echo "custom"; return 0 ;;
      12|exit|quit|q) echo "exit"; return 0 ;;
      *) echo "Invalid selection. Please choose a number from 1 to 12." ;;
    esac
  done
}

start_services() {
  local preset="$1"
  local -a services=()
  local item

  if [[ "$preset" == "custom" ]]; then
    local custom_services
    custom_services="$(custom_select)"
    if [[ -z "$custom_services" ]]; then
      echo "No services selected. Nothing to start."
      return 0
    fi
    for item in $custom_services; do
      services+=("$item")
    done
  else
    local preset_list
    preset_list="$(preset_services "$preset")"
    if [[ -z "$preset_list" ]]; then
      echo "No services available for preset: $preset"
      return 1
    fi
    for item in $preset_list; do
      services+=("$item")
    done
  fi

  if [[ ${#services[@]} -eq 0 ]]; then
    echo "No services selected. Nothing to start."
    return 0
  fi

  echo "Starting services: ${services[*]}"
  compose_cmd up -d "${services[@]}"

  echo ""
  echo "Stack running. Useful endpoints:"
  echo "  postgres => localhost:5433"
  echo "  redis    => localhost:6380"
  echo "  rabbitmq => localhost:5673 (management UI: 15673)"
  echo "  mongodb  => localhost:27018"
}

case "${1:-up}" in
  up|start)
    require_docker
    selected="$(select_preset)"
    if [[ "$selected" == "exit" ]]; then
      echo "Cancelled."
      exit 0
    fi
    start_services "$selected"
    ;;
  status)
    require_docker
    compose_cmd ps
    ;;
  down|stop)
    require_docker
    compose_cmd down
    ;;
  logs)
    require_docker
    if [[ -n "${2:-}" ]]; then
      compose_cmd logs -f "$2"
    else
      compose_cmd logs -f
    fi
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    usage
    exit 1
    ;;
 esac
