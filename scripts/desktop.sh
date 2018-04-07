#!/bin/dash -ex

SSH_USER=${SSH_USERNAME:-vagrant}
echo "==> SSH_USER set to ${SSH_USER}"

echo "==> Installing ubuntu-desktop"
apt-get install -y ubuntu-desktop

LIGHTDM_CONFIG=/etc/lightdm/lightdm.conf
# GDM_CUSTOM_CONFIG=/etc/gdm/custom.conf

#mkdir -p $(dirname ${GDM_CUSTOM_CONFIG})
#echo "[daemon]" >> $GDM_CUSTOM_CONFIG
#echo "# Enabling automatic login" >> $GDM_CUSTOM_CONFIG
#echo "AutomaticLoginEnable=True" >> $GDM_CUSTOM_CONFIG
#echo "AutomaticLoginEnable=${USERSSH_USERNAME}" >> $GDM_CUSTOM_CONFIG

echo "==> Configuring lightdm autologin"
echo "[SeatDefaults]" >> $LIGHTDM_CONFIG
echo "autologin-user=${SSH_USER}" >> $LIGHTDM_CONFIG


echo "==> Disabling screen blanking"
NODPMS_CONFIG=/etc/xdg/autostart/nodpms.desktop
echo "[Desktop Entry]" >> $NODPMS_CONFIG
echo "Type=Application" >> $NODPMS_CONFIG
echo "Exec=xset -dpms s off s noblank s 0 0 s noexpose" >> $NODPMS_CONFIG
echo "Hidden=false" >> $NODPMS_CONFIG
echo "NoDisplay=false" >> $NODPMS_CONFIG
echo "X-GNOME-Autostart-enabled=true" >> $NODPMS_CONFIG
echo "Name[en_US]=nodpms" >> $NODPMS_CONFIG
echo "Name=nodpms" >> $NODPMS_CONFIG
echo "Comment[en_US]=" >> $NODPMS_CONFIG
echo "Comment=" >> $NODPMS_CONFIG
