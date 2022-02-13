#!/usr/bin/env bash

PASSWORD=$(/usr/bin/openssl passwd -crypt '${password}')

# Vagrant-specific configuration
/usr/bin/useradd --password $${PASSWORD} --comment 'Vagrant User' --create-home --user-group ${username}
echo -e '${username}\n${username}' | /usr/bin/passwd ${username}
echo -e 'Defaults env_keep += "SSH_AUTH_SOCK"\n${username} ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/10_${username}
chmod 0440 /etc/sudoers.d/10_${username}
systemctl enable --now sshd.service