#!/bin/bash

test -f /etc/users.list || exit 0

while read id username home hash groups; do
        # Skip, if user already exists
        grep ^$username /etc/passwd && continue
        if [ $hash ]; then
                # $home is empty, if user should be created without home directory
                if [ -z $home ]; then
                        # Create user without home
                        echo "add user without home"
                        echo "useradd -u $id -s /bin/bash $username"
                        useradd -u $id -s /bin/bash $username
                else
                        # Create user with user home directory
                        echo "add user with home"
                        echo "useradd -u $id -m -d $home -s /bin/bash $username"
                        useradd -u $id -m -d $home -s /bin/bash $username
                fi
                # Set password
                echo "$username:$hash" | /usr/sbin/chpasswd -e
        else
                # Create group
                echo "create group"
                echo "addgroup --gid $id $username"
                addgroup --gid $id $username
        fi
        # Add supplemental groups
        if [ $groups ]; then
                echo "add supplemental groups"
                echo "usermod -aG $groups $username"
                usermod -aG $groups $username
        fi
done < /etc/users.list