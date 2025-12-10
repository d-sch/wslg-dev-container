#!/bin/bash

set -e
# if directory 'ide/cursor' not exists, exit with error message
if [ ! -d "ide/cursor" ]; then
    echo "ERROR: 'ide/cursor' directory does not exist. Please run './install.sh cursor' first." >&2
    exit 1
fi

# Start Cursor in its dedicated container. Fails if container already running.
CONTAINER=dev-cursor
OVERRIDE=docker-compose.cursor.override.yml

# Anchored container name check
if docker ps -q --filter "name=^/${CONTAINER}$" | grep -q .; then
    echo "Container ${CONTAINER} is already running; aborting. Stop it first to restart."
    exit 1
fi

docker compose -f docker-compose.yml -f ${OVERRIDE} up -d

sleep 5

docker compose -f docker-compose.yml -f ${OVERRIDE} exec -d -u ${USER} dev /bin/bash -c "sleep 5 && ( /opt/cursor/AppRun )"
