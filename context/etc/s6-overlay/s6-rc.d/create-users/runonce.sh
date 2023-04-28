#!/bin/bash

test -f /etc/users.list || exit 0

while read id username hash groups; do
        # Skip, if user already exists
        grep ^$username /etc/passwd && continue
        if [ $hash ]; then
                if [ -d "/home/$username" ]; then
                        # Create user without home
                        useradd -u $id -s /bin/bash $username
                else
                        # Create user with user home
                        useradd -u $id -m -d /home/dev -s /bin/bash $username
                fi
                # Set password
                echo "$username:$hash" | /usr/sbin/chpasswd -e
        else
                # Create group
                addgroup --gid $id $username
        fi
        # Add supplemental groups
        if [ $groups ]; then
                usermod -aG $groups $username
        fi
done < /etc/users.list