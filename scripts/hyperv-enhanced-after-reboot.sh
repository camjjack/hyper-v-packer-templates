#!/bin/dash -ex
# Enhanced support - see https://blogs.technet.microsoft.com/virtualization/2018/02/28/sneak-peek-taking-a-spin-with-enhanced-linux-vms/

# Only for desktop installs
dpkg  -l ubuntu-desktop
if [ $? -ge 1 ]; then
  exit
fi

# install.sh needed to reboot half way through. Thats happened now so kick it off again
pushd ~/xrdp-init/ubuntu/18.04/

echo "==> Running xrpd-init install again."
./install.sh

# Setup the user for the enhanced session.

if [ $? -eq 0 ]; then
    echo "==> Running xrpd-init config-user."
    ./config-user.sh
fi
popd