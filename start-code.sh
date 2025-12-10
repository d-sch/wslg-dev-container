#!/bin/bash

set -e

# if directory 'ide/code' not exists, exit with error message
if [ ! -d "ide/code" ]; then
    echo "ERROR: 'ide/code' directory does not exist. Please run './install.sh code' first." >&2
    exit 1
fi

# Start VS Code in its dedicated container. Fails if container already running.
CONTAINER=dev-vscode
OVERRIDE=docker-compose.vscode.override.yml

# Anchored container name check (avoid substring matches)
if docker ps -q --filter "name=^/${CONTAINER}$" | grep -q .; then
    echo "Container ${CONTAINER} is already running; aborting. Stop it first to restart."
    exit 1
fi

docker compose -f docker-compose.yml -f ${OVERRIDE} up -d

sleep 5

docker compose -f docker-compose.yml -f ${OVERRIDE} exec -d -u ${USER} dev /opt/code/code
