#!/bin/dash -ex

echo "==> Fixing locale"
LOCALE=${LOCALE:-en_US.UTF-8}
localectl set-locale "LANG=${LOCALE}"

echo "Need to reboot to set locale. Doing that now."
/sbin/shutdown -r now 