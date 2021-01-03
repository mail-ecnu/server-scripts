# MAIL-ECNU Server Script
## Structure
```text
.
├── add_user.sh
├── del_user.sh
├── login.sh
├── next-port
├── passwd
├── ports
└── reset_user.sh

2 directories, 5 files

```
- `passwd` storages whether a user set his password in container. If he/she forgot password, just delete the file in the directory.
- `ports` storages user's ssh port.


## Install
```bash
# git clone https://github.com/mail-ecnu/server-scripts
# make install
```

