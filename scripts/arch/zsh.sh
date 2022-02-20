#!/usr/bin/env bash

SSH_USER=${SSH_USERNAME:-vagrant}

pacman -Sy --noconfirm zsh zsh-completions grml-zsh-config alacritty
CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo -u ${SSH_USER} chsh -s /bin/zsh
sudo -u ${SSH_USER} mkdir -p /home/${SSH_USER}/.config/alacritty
sudo -u ${SSH_USER} cat > /home/${SSH_USER}/.config/alacritty/alacritty.yml <<EOF
shell:
  program: /bin/zsh
  args:
    - --login
EOF
