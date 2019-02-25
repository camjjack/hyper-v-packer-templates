#!/bin/dash -ex
# Enhanced support - see https://github.com/Microsoft/linux-vm-tools/wiki/Onboarding:-Ubuntu

# Only for desktop installs
dpkg  -l ubuntu-desktop
if [ $? -ge 1 ]; then
  exit
fi

# Install git
apt-get install -y wget

# Clone the initialisation repo
echo "==> Getting linx-vm-tools"
pushd /tmp/
wget https://raw.githubusercontent.com/Microsoft/linux-vm-tools/master/ubuntu/18.04/install.sh
chmod +x install.sh
./install.sh

if [ $? -ne 0 ]; then
    echo "Need to reboot to continue install. Doing that now."
    /sbin/shutdown -r now
    exit 0
fi
popd