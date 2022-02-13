#!/usr/bin/env bash

SSH_USER=${SSH_USERNAME:-vyos}
SSH_USER_GROUP=${SSH_USER_GROUP:-vyattacfg}
SSH_USER_HOME=${SSH_USER_HOME:-/home/${SSH_USER}}

echo "==> Installing vagrant key"
mkdir -pm 700 $SSH_USER_HOME/.ssh
wget --no-check-certificate https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -O ${SSH_USER_HOME}/.ssh/authorized_keys
chmod 0600 ${SSH_USER_HOME}/.ssh/authorized_keys
chown -R ${SSH_USER}:${SSH_USER_GROUP} ${SSH_USER_HOME}//.ssh
