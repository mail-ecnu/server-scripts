install:
	install -p -D -m 0700 add_user.sh /var/scripts/add_user.sh
	install -p -D -m 0700 del_user.sh /var/scripts/del_user.sh
	install -p -D -m 0700 reset_user.sh /var/scripts/reset_user.sh
	install -p -D -m 0755 login.sh /var/scripts/login.sh
	install -d -m 0755 /var/scripts/ports/
	install -d -m 0777 /var/scripts/passwd/
	if [ ! -e /var/scripts/next-port ]; then echo "10010" | tee /var/scripts/next-port ; fi


