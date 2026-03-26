#!/bin/bash

set -e

# Logging helpers
log_info() { echo "[INFO] $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }
log_ok() { echo "[OK] $1"; }

# Configurable retries
MAX_RETRIES=20
SLEEP_SECONDS=2

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

log_info "Starting build process..."

log_info "Checking Docker..."

if ! command -v docker &> /dev/null
then
    log_error "Docker is not installed."
    exit 1
fi

log_info "Checking Docker Compose..."

if ! docker compose version &> /dev/null
then
    log_error "Docker Compose is not available."
    exit 1
fi

log_info "Checking Docker daemon..."

if ! docker info &> /dev/null
then
    log_warn "Docker daemon is not running."

    # Preferir Colima si está instalado
    if command -v colima &> /dev/null; then
        log_info "Colima detected. Starting Colima..."
        colima start

    # Si no existe Colima y estamos en macOS, intentar Docker Desktop
    elif [ "$(uname)" = "Darwin" ]; then
        log_info "Colima not found. Attempting to start Docker Desktop..."
        open -a Docker 2>/dev/null
    fi

    log_info "Waiting for Docker daemon..."

    # esperar hasta que docker responda
    for ((i=1; i<=MAX_RETRIES; i++)); do
        if docker info &> /dev/null; then
            log_ok "Docker daemon is running."
            break
        fi
        sleep "$SLEEP_SECONDS"
    done

    if ! docker info &> /dev/null; then
        log_error "Docker daemon could not be started."
        exit 1
    fi
fi

# Export paths for shared config files so docker compose can resolve them
export TMUX_CONF="$BASE_DIR/config/tmux.conf"
export VIMRC="$BASE_DIR/config/vimrc"

# Validate that the files actually exist
if [ ! -f "$TMUX_CONF" ]; then
    log_error "tmux.conf not found at $TMUX_CONF"
    exit 1
fi

if [ ! -f "$VIMRC" ]; then
    log_error "vimrc not found at $VIMRC"
    exit 1
fi

log_info "Validating docker-compose.yml..."
docker compose -f "$BASE_DIR/docker/docker-compose.yml" config > /dev/null

log_info "Building containers..."

docker compose -f "$BASE_DIR/docker/docker-compose.yml" build

if [ $? -ne 0 ]; then
    log_error "Build failed."
    exit 1
fi

log_ok "Containers built successfully."