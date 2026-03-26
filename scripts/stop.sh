

#!/bin/bash

set -e

# Logging helpers
log_info() { echo "[INFO] $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }
log_ok() { echo "[OK] $1"; }

# Retry config
MAX_RETRIES=20
SLEEP_SECONDS=2

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log_info "Stopping lab..."

log_info "Checking Docker..."
if ! command -v docker >/dev/null 2>&1; then
    log_error "Docker is not installed."
    exit 1
fi

log_info "Checking Docker Compose..."
if ! docker compose version >/dev/null 2>&1; then
    log_error "Docker Compose is not available."
    exit 1
fi

log_info "Checking Docker daemon..."
if ! docker info >/dev/null 2>&1; then
    log_warn "Docker daemon is not running. Nothing to stop."
    exit 0
fi

log_info "Stopping containers..."
docker compose \
  --env-file "$BASE_DIR/.env" \
  -f "$BASE_DIR/docker/docker-compose.yml" \
  down

log_info "Waiting for containers to stop..."
for ((i=1; i<=MAX_RETRIES; i++)); do
    RUNNING=$(docker compose -f "$BASE_DIR/docker/docker-compose.yml" ps --status running --services | wc -l)
    if [ "$RUNNING" -eq 0 ]; then
        log_ok "All containers stopped."
        break
    fi
    sleep "$SLEEP_SECONDS"
done

if [ "$RUNNING" -ne 0 ]; then
    log_warn "Some containers may still be running."
fi

log_ok "Lab stopped successfully."