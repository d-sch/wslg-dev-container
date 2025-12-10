#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <cursor|vscode|intellij>"
  exit 2
fi

TO=$1

echo "Starting $TO..."
case "$TO" in
  cursor) ./install-cursor.sh ;; 
  vscode) ;&
  code) ./install-code.sh ;;
  intellij) ;&
  idea) ./install-intellij.sh ;;
  *) echo "Unknown IDE: $TO"; exit 2 ;;
esac
