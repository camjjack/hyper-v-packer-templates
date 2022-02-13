#!/usr/bin/env bash
SSH_USER=${SSH_USERNAME:-vagrant}

# Install xrdp
# sudo -u ${SSH_USER} curl -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/xrdp.tar.gz
# sudo -u ${SSH_USER} tar -xvf xrdp.tar.gz
# pushd xrdp
# sudo -u ${SSH_USER} makepkg -crsi --noconfirm
# popd
sudo -u ${SSH_USER} pikaur -Syu --noconfirm xrdp xorgxrdp --mflags=--skippgpcheck
# # Install xorgxrdp
# gpg --keyserver keyserver.ubuntu.com --receive-keys 03993B4065E7193B
# sudo -u ${SSH_USER} curl -L -O https://aur.archlinux.org/cgit/aur.git/snapshot/xorgxrdp.tar.gz
# sudo -u ${SSH_USER} tar -xvf xorgxrdp.tar.gz
# pushd xorgxrdp
# sudo -u ${SSH_USER} makepkg -crsi --noconfirm
# popd

# Configure the installed XRDP ini files.
# use vsock transport.
sed -i_orig -e 's/port=3389/port=vsock:\/\/-1:3389/g' /etc/xrdp/xrdp.ini
# use rdp security.
sed -i_orig -e 's/security_layer=negotiate/security_layer=rdp/g' /etc/xrdp/xrdp.ini
# remove encryption validation.
sed -i_orig -e 's/crypt_level=high/crypt_level=none/g' /etc/xrdp/xrdp.ini
# disable bitmap compression since its local its much faster
sed -i_orig -e 's/bitmap_compression=true/bitmap_compression=false/g' /etc/xrdp/xrdp.ini
# rename the redirected drives to 'shared-drives'
sed -i_orig -e 's/FuseMountName=thinclient_drives/FuseMountName=shared-drives/g' /etc/xrdp/sesman.ini

# Change the allowed_users
echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

#Ensure hv_sock gets loaded
if [ ! -e /etc/modules-load.d/hv_sock.conf ]; then
	echo "hv_sock" > /etc/modules-load.d/hv_sock.conf
fi

# Adapt the xrdp pam config
cat > /etc/pam.d/xrdp-sesman <<EOF
#%PAM-1.0
auth        include     system-remote-login
account     include     system-remote-login
password    include     system-remote-login
session     include     system-remote-login
EOF

/usr/bin/systemctl enable --now xrdp xrdp-sesman
sudo -u ${SSH_USER} pulseaudio --start