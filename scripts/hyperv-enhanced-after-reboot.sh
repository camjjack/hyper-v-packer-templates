#!/bin/dash -ex
# Enhanced support - see https://github.com/Microsoft/linux-vm-tools/wiki/Onboarding:-Ubuntu

# Only for desktop installs
dpkg  -l ubuntu-desktop
if [ $? -ge 1 ]; then
  exit
fi

# install.sh needed to reboot half way through. Thats happened now so kick it off again
pushd /tmp/

echo "==> Running linux-vm-tools install again."
./install.sh

popd