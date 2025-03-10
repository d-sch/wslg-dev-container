#!/bin/bash

#if not exists, create devcontainer/home directory
if [ ! -d "devcontainer/home" ]; then
    mkdir -p devcontainer/home/$USER
fi

cp context/etc/users.list.template context/etc/users.list
# Add current user to the users.list file
# id username home hash groups
echo "$(id -u) $(id -un) ${PWD}/devcontainer/home/$(id -un) $(echo $(openssl passwd -1 $USER)) docker,video" >> context/etc/users.list

docker compose build

echo "devcontainer is ready to use"