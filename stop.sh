#!/bin/bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <cursor|vscode|intellij>"
  exit 2
fi

case "$1" in
  cursor) OVERRIDE=docker-compose.cursor.override.yml; CONTAINER=dev-cursor ;; 
  vscode) ;&
  code) OVERRIDE=docker-compose.vscode.override.yml; CONTAINER=dev-vscode ;; 
  idea ) ;&
  intellij) OVERRIDE=docker-compose.idea.override.yml; CONTAINER=dev-intellij ;; 
  *) echo "Unknown IDE: $1"; exit 2 ;;
esac

if [ "$(docker ps -q -f name=${CONTAINER})" ]; then
  echo "Stopping ${CONTAINER} via docker compose"
  CONTAINER_NAME=${CONTAINER} docker compose -f docker-compose.yml -f ${OVERRIDE} down
else
  echo "Container ${CONTAINER} is not running"
fi