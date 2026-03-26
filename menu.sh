#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
chmod +x "$BASE_DIR"/scripts/*.sh

while true; do

    clear

    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${RED}[STATUS] Docker not installed${NC}"
    elif ! docker info >/dev/null 2>&1; then
        echo -e "${YELLOW}[STATUS] Docker daemon not running${NC}"
    else
        RUNNING=$(docker compose -f "$BASE_DIR/docker/docker-compose.yml" ps --status running --services 2>/dev/null | wc -l | xargs)
        if [ "$RUNNING" -gt 0 ]; then
            echo -e "${GREEN}[STATUS] Lab running ($RUNNING containers)${NC}"
        else
            echo -e "${YELLOW}[STATUS] Lab stopped${NC}"
        fi
    fi

    echo

    echo -e "${GREEN}===============================${NC}"
    echo -e "${GREEN}   HACKING LAB CONTROL PANEL${NC}"
    echo -e "${GREEN}===============================${NC}"
    echo
    echo "1) Revisar configuración"
    echo "2) Build containers"
    echo "3) Start lab"
    echo "4) Stop lab"
    echo "5) Reset lab"
    echo "6) Docker disk usage"
    echo "7) Clean Docker build cache"
    echo "8) View running containers"
    echo "0) Exit"
    echo

    read -p "Select option: " option

    if ! [[ "$option" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid input${NC}"
        sleep 1
        continue
    fi

    case $option in
        1)
        "$BASE_DIR/scripts/check_config.sh"
        ;;
        2)
        "$BASE_DIR/scripts/build.sh"
        ;;

        3)
        "$BASE_DIR/scripts/start.sh"
        ;;

        4)
        "$BASE_DIR/scripts/stop.sh"
        ;;

        5)
        echo
        read -p "⚠️ Esto borrará TODO el lab. ¿Continuar? (y/n): " confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            "$BASE_DIR/scripts/reset.sh"
        else
            echo "Cancelado."
        fi
        ;;

        6)
        echo
        echo "[*] Docker disk usage:"
        docker system df
        ;;

        7)
        echo
        echo "[*] Cleaning Docker build cache..."
        docker builder prune -f
        echo "[*] Cache cleaned."
        ;;

        8)
        echo
        docker compose -f "$BASE_DIR/docker/docker-compose.yml" ps
        ;;

        0)
        echo "Exiting..."
        exit 0
        ;;

        *)
        echo -e "${RED}Invalid option${NC}"

        sleep 1
        ;;
    esac
    echo
    read -p "Presiona Enter para continuar..."
done