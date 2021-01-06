#!/bin/bash

IP=$(ifconfig enp134s0f0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')

function do_stop {
    echo "========== Stopping your container..."
    lxc stop $USER
}

function do_passwd {
    echo "========== Changing your password (host only)..."
    passwd $USER
}

function allocate_port {
    echo "========== Preserve a port for your application, e.g. tensorboard, jupyter ..."
    PORT=$(cat /var/scripts/ports/$USER)
    read -p "Enter a port id (you can use 9 port denoted as 1-9): " input_id
    if [[ ! "$input_id" =~ ^[1-9]$ ]]; then
        echo "Wrong id."
        allocate_port
	return
    fi
    read -p "Enter port of your application (e.g. default port of tensorboard is 6006): " input_port
    lxc config device add $USER proxy$input_id proxy listen=tcp:0.0.0.0:$(( $PORT+$input_id )) connect=tcp:127.0.0.1:$input_port
    echo "Done. You can access your application via port $(( $PORT+$input_id )) now."
}

function release_port {
    echo "========== Release a port."
    PORT=$(cat /var/scripts/ports/$USER)
    read -p "Enter the port id you want to release (1-9): " input_id
    if [[ ! "$input_id" =~ ^[1-9]$ ]]; then
        echo "Wrong id."
        release_port
	return
    fi
    lxc config device remove $USER proxy$input_id
    echo "Done."
}

function set_container_passwd {
    lxc exec $USER -- passwd ubuntu
    if [ $? -ne 0 ]; then
	set_container_passwd
	return
    fi
}

function do_start {
    PORT=$(cat /var/scripts/ports/$USER)
    INFO=$(lxc info $USER)
    echo "$INFO" | grep Running > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        echo "========== Starting your container..."
        lxc start $USER

        sleep 3
        echo ""
    else
        echo "It seems that your container is running."
    fi
    if [ ! -f /var/scripts/passwd/$USER ]; then
        echo "Please set your container password."
	set_container_passwd
	touch /var/scripts/passwd/$USER
	echo ""
    	printf "Connect your container directly via \`\e[96;1mssh ubuntu@$IP -p $PORT\e[0m\`.\n"
    fi
    if [ ! -L $HOME/home-in-container ];then
        ln -s /var/lib/lxd/storage-pools/zfs-pool/containers/$USER/rootfs/home/ubuntu $HOME/home-in-container
    fi
}

function print_help {
    echo ""
    printf "Enter menu: \e[96;1mssh -t $USER@$IP menu \e[0m\n"
    echo ""
}

function print_about {
    echo "==========About your container:"
    INFO=$(lxc info $USER)
    PORT=$(cat /var/scripts/ports/$USER)
    echo "$INFO" | grep Running > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        printf "\e[96;1mYour container is not running.\e[0m\n"
        do_start
    else
        printf "\e[96;1mYour container is running.\e[0m\n"
        echo
        echo "username: ubuntu"
        echo "ssh port: $PORT"
        echo
        printf "Connect your container directly via \`\e[96;1mssh ubuntu@$IP -p $PORT\e[0m\`.\n"
        echo "Transfer data to the container directly using scp or sftp with info above."

        printf "File sharing is encouraged, access data at \e[96;1m/mnt/ssd\e[0m.\n"
        printf "\nSee GPU load: \e[96;1mnvidia-smi\e[0m.\n    memory usage: \e[96;1mfree -h\e[0m.\n    disk usage: \e[96;1mdf -h\e[0m.\n "
        echo ""
    fi
}

function menu {
    echo ""
    echo "===== main menu  ====="
    echo "[1] start your container"
    echo "[2] stop your container"
    echo "[3] change your password"
    echo "[4] allocate ports"
    echo "[5] release ports"
    echo "[0] show info"
    echo "[x] exit"
    read -p "Enter your choice: " op
    if   [ "$op" == "1" ];
        then do_start
        read -p "Press any key to continue..." -n 1 -r
        menu
    elif   [ "$op" == "2" ];
       then do_stop
       read -p "Press any key to continue..." -n 1 -r
       menu
    elif [ "$op" == "3" ];
        then do_passwd
        read -p "Press any key to continue..." -n 1 -r
        menu
    elif [ "$op" == "4" ];
        then allocate_port
        read -p "Press any key to continue..." -n 1 -r
        menu
    elif [ "$op" == "5" ];
        then release_port
        read -p "Press any key to continue..." -n 1 -r
        menu
    elif [ "$op" == "0" ];
        then
        lxc info $USER
        read -p "Press any key to continue..." -n 1 -r
        menu
    elif [ "$op" == "x" ];
    then
        echo "========== Have a nice day :-)"
	exit 1
    elif [[ -z "$op" ]];
        then do_start
    else
        echo "========== Unknown command"
        read -p "Press any key to continue..." -n 1 -r
        menu
    fi
}

printf "\n\n Hi, \e[96;1m$USER\e[0m\n"
echo " You're using the GPU Server in MAIL-ECNU."
if [ "$2" == "menu" ] && [[ "$(tty)" == /dev/* ]]; then
    print_about
    menu
else
    print_help
fi

echo "========== Have a nice day :-)"
exit 128
