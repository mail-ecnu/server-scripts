#!/bin/bash
### reset user
echo "=====Welcome!"


echo "we need to get sudo permission first. Enter the password for admin below."
sudo ls

read -p "Enter your username: " USERNAME

if [[ -z "$USERNAME" ]]; then
    echo "Please give me a username"
    exit 1
fi

if [ ! -f /var/scripts/ports/$USERNAME ]; then
    echo "User does not exists"
    exit 1
fi

# <<<<
printf "Allocating container for \e[96;1m$USERNAME\e[0m...\n"

# config the container
lxc init template ${USERNAME} -p default

# allocate ssh port
printf "Allocating ssh port... "
PORT=$(cat /var/scripts/ports/$USERNAME)
printf "\e[96;1m$PORT\e[0m\n"

lxc config device add ${USERNAME} sshproxy proxy listen=tcp:0.0.0.0:$PORT connect=tcp:127.0.0.1:22

# map uid
# lxc config device add $USERNAME door disk source=/home/$USERNAME path=/root/door
printf "uid $(id $USERNAME -u) 1000\ngid $(id $USERNAME -g) 1000" | lxc config set $USERNAME raw.idmap -

echo "Login this host via \`ssh <username>@<host-ip>\` to manage your container."
# >>>>

echo "Done!"

read -p "Press any key to continue..." -n 1 -r

