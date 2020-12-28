#! /bin/bash
echo -n 'Username: '
read username
echo -n 'Password: '
read -s pass
# u=${1:-$username}
# p=${1:-$pass}
curl -d "action=login&username=${username}&password=${pass}&ac_id=1&ajax=1" "https://login.ecnu.edu.cn/include/auth_action.php"
