#!/bin/bash
set -e

IDE_CONTAINERS=(dev-cursor dev-vscode dev-intellij)

printf "%-15s %-10s %-20s\n" "CONTAINER" "STATUS" "UP SINCE"
for c in "${IDE_CONTAINERS[@]}"; do
  if docker ps -a --format '{{.Names}} {{.Status}}' | grep -q "^${c} "; then
    info=$(docker ps -a --filter "name=^/${c}$" --format '{{.Names}} {{.Status}}')
    name=$(echo "$info" | awk '{print $1}')
    status=$(echo "$info" | cut -d' ' -f2-)
    printf "%-15s %-10s %-20s\n" "$name" "$status" ""
  else
    printf "%-15s %-10s %-20s\n" "$c" "not started" ""
  fi
done
