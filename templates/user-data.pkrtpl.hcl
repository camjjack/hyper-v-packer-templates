#cloud-config
autoinstall:
    version: 1
    locale: ${locale}
    keyboard:
        layout: ${keyboard_layout}
    storage:
        layout:
            name: lvm
    early-commands:
        - systemctl stop ssh # otherwise packer tries to connect and exceed max attempts
    identity:
        hostname: ${hostname}
        username: ${username}
        password: ${password}
    ssh:
        install-server: yes
    packages:
        - build-essential
        - ntp
        - linux-virtual
        - linux-tools-virtual
        - linux-cloud-tools-virtual
