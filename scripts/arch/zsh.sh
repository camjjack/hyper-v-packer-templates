#!/usr/bin/env bash

pacman -Sy --noconfirm zsh zsh-completions grml-zsh-config
chsh -s /usr/bin/zsh
