# Hyper-V packer templates

This project aims to expose a simple, configurable and tailored packer template for building Vagrant base boxes for Hyper-V. 

## Why another template project
There are many templates, and existing Vagrant boxes available so why bother re-inventing the wheel? Well in my experience all the projects I looked at either tried to do too much or had Hyper-V as a second class citizen. Further more if I wanted to configure the build boxes I had to fully understand the project and where it's configuration is hidden.

So the goals for this project are simple:
1. Hyper-V must be the main supported builder.
1. Limit the number of supported OS's to enable a clean project without a large amount of if/else style configuration.
1. Make anything that a user might want to modify configurable within a build process without the need to resort to modifing templates or internal OS installation files etc.

## Prerequisites
1. Packer
1. PowerShell - for our build scripts
1. Hyper-V
    1. Windows 10 build 17063 or greater is required for enhanced mode support. See https://blogs.technet.microsoft.com/virtualization/2018/02/28/sneak-peek-taking-a-spin-with-enhanced-linux-vms/

## Usage

### Ubuntu 20.04 x64
A PowerShell build script has been created to handle build and configuration for the vagrant boxes.

From a PowerShell command prompt in the project root:
```
get-help .\build.ps1 -detailed
```
This will show all the configuration options available. 

A default build can be run like this:
```
.\build.ps1
```

### Windows 10 x64
A PowerShell build script has been created to handle build and configuration for the vagrant boxes.

From a PowerShell command prompt in the project root:
```
get-help .\build-windows.ps1 -detailed
```
This will show all the configuration options available. 

A default build can be run like this:
```
.\build-windows.ps1
```

## Supported packer boxes
In keeping with my project goals above, Ubuntu 20.04 x64 and Windows 10 x64 are the only supported box OS's at this stage.

## Troubleshooting
The build script has a -debug option which sets some packer options to aid in debugging faulty templates. Start with the generated log file: packer-log.txt
