

#!/bin/bash

set -e

# Logging helpers
log_info() { echo "[INFO] $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }
log_ok() { echo "[OK] $1"; }

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"


log_info "Resetting lab..."

# Check Docker
log_info "Checking Docker..."
if ! command -v docker >/dev/null 2>&1; then
    log_error "Docker is not installed."
    exit 1
fi

# Check Docker Compose
log_info "Checking Docker Compose..."
if ! docker compose version >/dev/null 2>&1; then
    log_error "Docker Compose is not available."
    exit 1
fi

# Check daemon
log_info "Checking Docker daemon..."
if ! docker info >/dev/null 2>&1; then
    log_warn "Docker daemon is not running. Nothing to reset."
    exit 0
fi

# Stop and remove containers
log_info "Stopping and removing containers..."
docker compose \
  --env-file "$BASE_DIR/.env" \
  -f "$BASE_DIR/docker/docker-compose.yml" \
  down --remove-orphans

log_warn "Hard reset: removing volumes and pruning system..."

# Ensure everything is fully stopped with volumes removed
docker compose \
  --env-file "$BASE_DIR/.env" \
  -f "$BASE_DIR/docker/docker-compose.yml" \
  down --volumes --remove-orphans

log_info "Pruning Docker system (images, cache, unused volumes)..."
docker system prune -af
docker volume prune -f

log_ok "Lab reset completed."