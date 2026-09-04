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
DEFAULT_ENV_NAME="${LOCALDEV_ENV_NAME:-default}"
CURRENT_ENV_NAME="$DEFAULT_ENV_NAME"
ENV_FILE="$SCRIPT_DIR/.env.${CURRENT_ENV_NAME}"

usage() {
  cat <<'EOF'
Usage: local-dev.sh [command] [environment-name]

Commands:
  up [name]         Start the interactive service selector or create a named environment
  start [name]      Alias for up
  status [name]     Show running containers for a specific environment
  down [name]       Stop and remove a specific environment
  logs [name] [service]  Tail logs for one service or all services in that environment
  help              Show this help text

Environment behavior:
  If no environment name is provided, the script uses LOCALDEV_ENV_NAME or default.
  Each environment gets its own port set to avoid collisions with other local stacks.

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
  observability     postgres + redis + rabbitmq + prometheus + grafana
  custom            Choose individual services interactively
  exit              Cancel without starting anything

Service ports are assigned dynamically per environment and are written to .env.<name>.
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

is_port_bound() {
  if command -v lsof >/dev/null 2>&1; then
    if lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1; then
      return 0
    fi
  fi

  if command -v nc >/dev/null 2>&1; then
    if nc -z "127.0.0.1" "$1" >/dev/null 2>&1; then
      return 0
    fi
  fi

  return 1
}

get_next_free_port() {
  local preferred_port="$1"
  local candidate="$preferred_port"
  local max_probe="$((preferred_port + 200))"

  while (( candidate <= max_probe )); do
    if ! is_port_bound "$candidate"; then
      echo "$candidate"
      return 0
    fi
    candidate=$((candidate + 1))
  done

  echo "$preferred_port"
  return 1
}

compute_port_base() {
  local env_name="${1:-default}"

  if [[ -n "${LOCALDEV_PORT_BASE:-}" ]]; then
    echo "$LOCALDEV_PORT_BASE"
    return 0
  fi

  if [[ "$env_name" == "default" ]]; then
    echo "0"
    return 0
  fi

  local hash_value
  hash_value="$(printf '%s' "$env_name" | cksum | awk '{print $1}')"
  echo $((10000 + (hash_value % 2000)))
}

write_env_file() {
  local env_name="${1:-default}"
  local env_file="$SCRIPT_DIR/.env.${env_name}"
  local base_port
  base_port="$(compute_port_base "$env_name")"
  local postgres_port redis_port rabbitmq_port rabbitmq_management_port mongodb_port elasticsearch_port elasticsearch_transport_port prometheus_port grafana_port

  postgres_port="$(get_next_free_port "$((5433 + base_port))")"
  redis_port="$(get_next_free_port "$((6380 + base_port))")"
  rabbitmq_port="$(get_next_free_port "$((5673 + base_port))")"
  rabbitmq_management_port="$(get_next_free_port "$((15673 + base_port))")"
  mongodb_port="$(get_next_free_port "$((27018 + base_port))")"
  elasticsearch_port="$(get_next_free_port "$((9201 + base_port))")"
  elasticsearch_transport_port="$(get_next_free_port "$((9301 + base_port))")"
  prometheus_port="$(get_next_free_port "$((9091 + base_port))")"
  grafana_port="$(get_next_free_port "$((3001 + base_port))")"

  cat >"$env_file" <<EOF
COMPOSE_CONTAINER_PREFIX=local-dev-${env_name}
POSTGRES_PORT=${postgres_port}
REDIS_PORT=${redis_port}
RABBITMQ_PORT=${rabbitmq_port}
RABBITMQ_MANAGEMENT_PORT=${rabbitmq_management_port}
MONGODB_PORT=${mongodb_port}
ELASTICSEARCH_PORT=${elasticsearch_port}
ELASTICSEARCH_TRANSPORT_PORT=${elasticsearch_transport_port}
PROMETHEUS_PORT=${prometheus_port}
GRAFANA_PORT=${grafana_port}
EOF

  echo "$env_file"
}

compose_cmd() {
  docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" -p "local-dev-${CURRENT_ENV_NAME}" "$@"
}

service_names() {
  case "$1" in
    postgres) echo "postgres" ;;
    redis) echo "redis" ;;
    rabbitmq) echo "rabbitmq" ;;
    mongodb) echo "mongodb" ;;
    elasticsearch) echo "elasticsearch" ;;
    prometheus) echo "prometheus" ;;
    grafana) echo "grafana" ;;
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
    observability) echo "postgres redis rabbitmq prometheus grafana" ;;
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
  local -a services=(postgres redis rabbitmq mongodb elasticsearch prometheus grafana)
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
        6) selected+=("prometheus") ;;
        7) selected+=("grafana") ;;
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
 11) observability
 12) custom
 13) exit
EOF

  local choice=""
  while true; do
    read -r -p "Select a preset [1-13]: " choice
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
      11|observability) echo "observability"; return 0 ;;
      12|custom) echo "custom"; return 0 ;;
      13|exit|quit|q) echo "exit"; return 0 ;;
      *) echo "Invalid selection. Please choose a number from 1 to 13." ;;
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

  ENV_FILE="$(write_env_file "$CURRENT_ENV_NAME")"
  echo "Using environment name: ${CURRENT_ENV_NAME}"
  echo "Using env file: ${ENV_FILE}"
  echo "Starting services: ${services[*]}"
  compose_cmd up -d "${services[@]}"

  echo ""
  echo "Stack running. Useful endpoints:"
  echo "  postgres      => localhost:$(grep '^POSTGRES_PORT=' "$ENV_FILE" | cut -d= -f2)"
  echo "  redis         => localhost:$(grep '^REDIS_PORT=' "$ENV_FILE" | cut -d= -f2)"
  echo "  rabbitmq      => localhost:$(grep '^RABBITMQ_PORT=' "$ENV_FILE" | cut -d= -f2) (management UI: $(grep '^RABBITMQ_MANAGEMENT_PORT=' "$ENV_FILE" | cut -d= -f2))"
  echo "  mongodb       => localhost:$(grep '^MONGODB_PORT=' "$ENV_FILE" | cut -d= -f2)"
  echo "  elasticsearch => localhost:$(grep '^ELASTICSEARCH_PORT=' "$ENV_FILE" | cut -d= -f2)"
  echo "  prometheus    => localhost:$(grep '^PROMETHEUS_PORT=' "$ENV_FILE" | cut -d= -f2)"
  echo "  grafana       => localhost:$(grep '^GRAFANA_PORT=' "$ENV_FILE" | cut -d= -f2)"
}

case "${1:-up}" in
  up|start)
    require_docker
    if [[ -n "${2:-}" ]]; then
      CURRENT_ENV_NAME="${2}"
    else
      CURRENT_ENV_NAME="${LOCALDEV_ENV_NAME:-default}"
    fi
    ENV_FILE="$SCRIPT_DIR/.env.${CURRENT_ENV_NAME}"

    selected="$(select_preset)"
    if [[ "$selected" == "exit" ]]; then
      echo "Cancelled."
      exit 0
    fi
    start_services "$selected"
    ;;
  status)
    require_docker
    CURRENT_ENV_NAME="${2:-${LOCALDEV_ENV_NAME:-default}}"
    ENV_FILE="$SCRIPT_DIR/.env.${CURRENT_ENV_NAME}"
    if [[ ! -f "$ENV_FILE" ]]; then
      echo "Environment '${CURRENT_ENV_NAME}' has not been created yet. Run the stack first."
      exit 1
    fi
    compose_cmd ps
    ;;
  down|stop)
    require_docker
    CURRENT_ENV_NAME="${2:-${LOCALDEV_ENV_NAME:-default}}"
    ENV_FILE="$SCRIPT_DIR/.env.${CURRENT_ENV_NAME}"
    if [[ ! -f "$ENV_FILE" ]]; then
      echo "Environment '${CURRENT_ENV_NAME}' has not been created yet. Nothing to stop."
      exit 0
    fi
    compose_cmd down
    ;;
  logs)
    require_docker
    CURRENT_ENV_NAME="${2:-${LOCALDEV_ENV_NAME:-default}}"
    ENV_FILE="$SCRIPT_DIR/.env.${CURRENT_ENV_NAME}"
    if [[ ! -f "$ENV_FILE" ]]; then
      echo "Environment '${CURRENT_ENV_NAME}' has not been created yet."
      exit 1
    fi
    if [[ -n "${3:-}" ]]; then
      compose_cmd logs -f "$3"
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
