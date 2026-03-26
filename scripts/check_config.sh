#!/bin/bash

CONFIG_DIR="config"

TMUX_CONF="$CONFIG_DIR/tmux.conf"
VIMRC="$CONFIG_DIR/vimrc"

echo "[*] Checking configuration files..."

if [ ! -f "$TMUX_CONF" ]; then
    echo "[ERROR] Missing $TMUX_CONF"
    exit 1
fi

if [ ! -f "$VIMRC" ]; then
    echo "[ERROR] Missing $VIMRC"
    exit 1
fi

echo "[OK] Configuration files found."