#!/bin/bash
# Note: start.sh will be overwritten by install_code.sh or install_intellij.sh

# Check if service dev is up and running. If not, start it
if [ "$(docker ps -q -f name=dev)" ]; then
    echo "devcontainer is already running"
else
    docker compose up -d
fi

docker compose exec -d -u ${USER} dev /opt/code/code