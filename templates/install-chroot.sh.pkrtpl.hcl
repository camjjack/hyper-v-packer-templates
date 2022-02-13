#!/usr/bin/env bash

echo "Configuring timezone"
ln -sf /usr/share/zoneinfo/${timezone_region}/${timezone_city} /etc/localtime
hwclock --systohc

echo "Configuring Localisation"
/usr/bin/sed -i 's/#${locale}/${locale}/' /etc/locale.gen
/usr/bin/sed -i 's/#UTF-8/UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=${locale}' > /etc/locale.conf
echo 'KEYMAP=${keymap}' > /etc/vconsole.conf

echo "Configuring hostname"
echo '${hostname}' > /etc/hostname

echo "Configuring network"
/usr/bin/systemctl enable dhcpcd.service

echo "Configuring Initramfs"
/usr/bin/mkinitcpio -p linux

echo "Configuring root password"
/usr/bin/usermod --password ${password} root

echo "Configuring boot loader"
bootctl install
/usr/bin/systemctl enable systemd-boot-update.service
cp /usr/share/systemd/bootctl/loader.conf /boot/loader/loader.conf
echo -e "timeout 4\neditor no" >> /boot/loader/loader.conf
cp /usr/share/systemd/bootctl/arch.conf /boot/loader/entries/arch.conf

uuid=$(blkid -s PARTUUID -o value /dev/sda3)
/usr/bin/sed -i "s/PARTUUID=XXXX rootfstype=XXXX add_efi_memmap/PARTUUID=$uuid rw/" /boot/loader/entries/arch.conf
bootctl update
# bootctl status
# echo "bootctl list"
# bootctl list

echo "Configuring SSH"
# Make sure SSH is allowed
echo "sshd: ALL" > /etc/hosts.allow
# And everything else isn't
echo "ALL: ALL" > /etc/hosts.deny
# Make sure sshd starts on boot
/usr/bin/systemctl enable sshd.service
/usr/bin/sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config

echo "Configuring Hyper-v integration services"
/usr/bin/systemctl enable --now hv_fcopy_daemon.service hv_kvp_daemon.service hv_vss_daemon.service


# echo "Configuring Enhanced session mode" 


echo "Configuring Vagrant User"
PASSWORD=$(/usr/bin/openssl passwd -crypt '${password}')
/usr/bin/useradd --password $${PASSWORD} --comment 'Vagrant User' --create-home --user-group ${username}
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_vagrant
/usr/bin/chmod 0440 /etc/sudoers.d/10_vagrant
/usr/bin/install --directory --owner=${username} --group=vagrant --mode=0700 /home/${username}/.ssh
/usr/bin/curl --output /home/${username}/.ssh/authorized_keys --location https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
/usr/bin/chown ${username}:${username} /home/${username}/.ssh/authorized_keys
/usr/bin/chmod 0600 /home/${username}/.ssh/authorized_keys

echo "Leaving chroot"
exit
