#!/usr/bin/env bash
SSH_USER=${SSH_USERNAME:-vagrant}

# Install pikaur
sudo -u ${SSH_USER} curl -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/pikaur.tar.gz
sudo -u ${SSH_USER} tar -xvf pikaur.tar.gz
pushd pikaur
sudo -u ${SSH_USER} makepkg -crsi --noconfirm
popd
