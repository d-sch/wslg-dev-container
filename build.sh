#!/bin/bash

#if not exists, create devcontainer/home directory
if [ ! -d "devcontainer/home" ]; then
    mkdir -p devcontainer/home/$USER
fi

cp context/etc/users.list.template context/etc/users.list
# Add current user to the users.list file
# id username home hash groups
echo "$(id -u) $(id -un) /home/$(id -un) $(echo $(openssl passwd -1 $USER)) docker,video" >> context/etc/users.list

docker compose build
rc=$?
if [ $rc -ne 0 ]; then
    echo "ERROR: 'docker compose build' failed with exit code $rc" >&2
    exit $rc
fi

echo "devcontainer is ready to use"