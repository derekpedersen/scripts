# ─────────────────────────────────────────────
# Docker cleanup helpers
# ─────────────────────────────────────────────

# Show Docker disk usage
docker-clean-disk-usage() {
    docker system df
}

# Remove stopped containers
docker-clean-containers() {
    echo "This will remove all stopped Docker containers."
    read -r -p "Continue? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }

    docker container prune -f
}

# Remove dangling images
docker-clean-dangling-images() {
    echo "This will remove all dangling Docker images."
    read -r -p "Continue? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }

    docker image prune -f
}

# Remove all unused images
docker-clean-unused-images() {
    echo "This will remove ALL unused Docker images."
    read -r -p "Continue? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }

    docker image prune -a -f
}

# Remove unused networks
docker-clean-networks() {
    echo "This will remove all unused Docker networks."
    read -r -p "Continue? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }

    docker network prune -f
}

# Remove unused volumes
docker-clean-volumes() {
    echo "WARNING: This will permanently delete unused Docker volumes and their data."
    read -r -p "Continue? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }

    docker volume prune -f
}

# Remove build cache
docker-clean-build-cache() {
    echo "This will remove unused Docker build cache."
    read -r -p "Continue? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }

    docker builder prune -f
}

# Remove Docker objects unused for 7+ days
docker-clean-old() {
    echo "This will remove Docker containers, images, and build cache unused for 7+ days."
    read -r -p "Continue? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }

    docker container prune -f --filter "until=168h"
    docker image prune -a -f --filter "until=168h"
    docker builder prune -f --filter "until=168h"
}

# Aggressive cleanup
docker-clean-all() {
    echo "WARNING: This will remove ALL unused Docker containers, networks,"
    echo "images, build cache, AND volumes."
    echo "Volume data may be permanently lost."
    echo
    read -r -p "Are you sure? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }

    docker system prune -a --volumes -f
}