#!/bin/dash -ex
# Enhanced support - see https://blogs.technet.microsoft.com/virtualization/2018/02/28/sneak-peek-taking-a-spin-with-enhanced-linux-vms/

# Only for desktop installs
dpkg  -l ubuntu-desktop
if [ $? -ge 1 ]; then
  exit
fi

# Install git
apt-get install -y git

# Clone the initialisation repo
echo "==> Cloning xrpd-init"
git clone https://github.com/jterry75/xrdp-init.git ~/xrdp-init
pushd ~/xrdp-init/ubuntu/18.04/

# Set the scripts to be executable
chmod +x install.sh
chmod +x config-user.sh

echo "==> Running xrpd-init"
./install.sh

if [ $? -ne 0 ]; then
    echo "Need to reboot to continue install. Doing that now."
    /sbin/shutdown -r now
    exit 0
fi
popd