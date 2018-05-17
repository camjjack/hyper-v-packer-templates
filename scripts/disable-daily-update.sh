#!/bin/dash -ex

echo "==> Disabling apt daily services"
systemctl disable apt-daily.service
systemctl disable apt-daily.timer