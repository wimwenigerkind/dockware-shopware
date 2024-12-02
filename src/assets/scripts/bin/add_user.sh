#!/bin/bash

SSH_USER=${1:?Error: SSH_USER argument is required}
SSH_PWD=${2:?Error: SSH_PWD argument is required}


# create a custom ssh user for our provided settings
sudo adduser --disabled-password --uid 8888 --gecos "" --ingroup www-data $SSH_USER
sudo usermod -a -G sudo $SSH_USER
sudo usermod -m -d /var/www $SSH_USER | true

sudo echo "${SSH_USER}:${SSH_PWD}" | sudo chpasswd
sudo sed -i "s/${SSH_USER}:x:8888:33:/${SSH_USER}:x:33:33:/g" /etc/passwd

# add sudo without password
# write user to file cause we loos the var as we executing as root and get a new shell
sudo echo "${SSH_USER}" >> /tmp/user.name
sudo -u root sh -c 'echo "Defaults:$(cat /tmp/user.name) !requiretty" >> /etc/sudoers'
sudo rm -rf /tmp/user.name

# disable original ssh access
sudo usermod -s /bin/false dockware

# allow ssh in sshd_config
sudo sed -i "s/AllowUsers dockware/AllowUsers ${SSH_USER}/g" /etc/ssh/sshd_config
