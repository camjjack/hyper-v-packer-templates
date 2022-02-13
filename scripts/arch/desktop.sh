#!/usr/bin/env bash

SSH_USER=${SSH_USERNAME:-vagrant}

pacman -Sy --noconfirm xf86-video-fbdev xorg adobe-source-code-pro-fonts ttf-font-awesome lightdm lightdm-gtk-greeter alacritty vim dex pulseaudio feh picom
systemctl enable --now lightdm.service

sudo -u ${SSH_USER} mkdir -p /home/${SSH_USER}/.config/
sudo -u ${SSH_USER} curl -L -o /home/${SSH_USER}/.config/arch.png https://wallpapercave.com/download/arch-linux-wallpaper-NyaITD5

cp /etc/xdg/picom.conf /home/${SSH_USER}/.config/picom.conf
sed -i_orig -e 's/vsync = true/vsync = false/g' /home/${SSH_USER}/.config/picom.conf