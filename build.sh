#!/bin/bash -ex
packer build --only=virtualbox-iso --on-error=ask hyperv-ubuntu-16.04.json
packer build --only=virtualbox-iso --on-error=ask hyperv-ubuntu-16.04-desktop.json