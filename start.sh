#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <cursor|vscode|intellij>"
  exit 2
fi

TO=$1

echo "Starting $TO..."
case "$TO" in
  cursor) ./start-cursor.sh ;; 
  vscode) ;&
  code) ./start-code.sh ;;
  intellij) ;&
  idea) ./start-intellij.sh ;;
  *) echo "Unknown IDE: $TO"; exit 2 ;;
esac
