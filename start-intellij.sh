#!/bin/bash

set -e
# if directory 'ide/idea' not exists, exit with error message
if [ ! -d "ide/idea" ]; then
    echo "ERROR: 'ide/idea' directory does not exist. Please run './install.sh intellij' first." >&2
    exit 1
fi

# Start IntelliJ in its dedicated container. Fails if container already running.
CONTAINER=dev-intellij
OVERRIDE=docker-compose.idea.override.yml

# Anchored container name check
if docker ps -q --filter "name=^/${CONTAINER}$" | grep -q .; then
    echo "Container ${CONTAINER} is already running; aborting. Stop it first to restart."
    exit 1
fi

docker compose -f docker-compose.yml -f ${OVERRIDE} up -d

sleep 5

docker compose -f docker-compose.yml -f ${OVERRIDE} exec -d -u ${USER} dev /opt/idea/bin/idea
