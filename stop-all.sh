#!/bin/bash
set -euo pipefail

for ide in cursor vscode intellij; do
  echo "Attempting to stop $ide"
  ./stop-ide.sh "$ide" || true
done
