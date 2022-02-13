#!/bin/dash -ex

SSH_USER=${SSH_USERNAME:-vagrant}
echo "==> SSH_USER set to ${SSH_USER}"

echo "==> Installing ubuntu-desktop"
apt-get install -y ubuntu-desktop

echo "==> Disabling initial setup wizard"
apt-get purge -y gnome-initial-setup

echo "==> Configuring gdm for automatic login"
GDM_CUSTOM_CONFIG=/etc/gdm3/custom.conf
echo "[daemon]" >> $GDM_CUSTOM_CONFIG
echo "# Enabling automatic login" >> $GDM_CUSTOM_CONFIG
echo "AutomaticLoginEnable=True" >> $GDM_CUSTOM_CONFIG
echo "AutomaticLoginEnable=${SSH_USER}" >> $GDM_CUSTOM_CONFIG
