#!/usr/bin/env bash

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

log_info "Starting lab..."

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
    log_warn "Docker daemon is not running. Attempting to wait..."
    for ((i=1; i<=MAX_RETRIES; i++)); do
        if docker info >/dev/null 2>&1; then
            log_ok "Docker daemon is running."
            break
        fi
        sleep "$SLEEP_SECONDS"
    done
    if ! docker info >/dev/null 2>&1; then
        log_error "Docker daemon could not be reached."
        exit 1
    fi
fi

log_info "Validating docker-compose.yml..."
docker compose -f "$BASE_DIR/docker/docker-compose.yml" config > /dev/null

log_info "Starting containers..."
docker compose \
  --env-file "$BASE_DIR/.env" \
  -f "$BASE_DIR/docker/docker-compose.yml" \
  up -d

log_info "Waiting for containers to be ready..."
for ((i=1; i<=MAX_RETRIES; i++)); do
    RUNNING=$(docker compose -f "$BASE_DIR/docker/docker-compose.yml" ps --status running --services | wc -l)
    TOTAL=$(docker compose -f "$BASE_DIR/docker/docker-compose.yml" config --services | wc -l)
    if [ "$RUNNING" -ge "$TOTAL" ]; then
        log_ok "All containers are running."
        break
    fi
    sleep "$SLEEP_SECONDS"
done

echo
log_ok "Lab started successfully."
echo
log_info "GUI available at:"
echo "http://localhost:6080"