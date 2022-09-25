<#
.SYNOPSIS
    Builds Packer Ubuntu LTS boxes for Hyper-V
.DESCRIPTION
    Wrapper around packer and some build configurations to automate the building process for three boxes.
      1) Base Ubuntu LTS server
      2) Ubuntu LTS Desktop
      3) Ubuntu LTS Desktop with enhanced session support, see: https://github.com/Microsoft/linux-vm-tools/wiki/Onboarding:-Ubuntu
      4) Base Arch Linux
      5) Arch Linux with xorg and enhanced session support
    Also provides command line configuration for these builds.
.PARAMETER outputDir
    The base name for the output directories.
.PARAMETER vmNamePrefix
    The base name for vm's that are created.
.PARAMETER cpus
    The number of cpus to allocate to the VM. Default: 2
.PARAMETER ramSize
    The ammount of RAM in bytes to allocate to the VM. Default: 4096
.PARAMETER diskSize
    The size of the hard disk drive in bytes used in the VM. Default: 200000
.PARAMETER username
    The username for the VM. For simplicity the password will be set as the username. Default: vagrant
.PARAMETER dontBuildDesktop
    Instructs the build process to just build a server os not the desktop boxes.
.PARAMETER dontBuildArch
    Instructs the build process to not build the arch boxes.
.PARAMETER dontBuildVyos
    Instructs the build process to not build the VyOS box.
.PARAMETER clean
    Cleans up all the artifacts of the build process.
.PARAMETER force
    Default behaivor is to skip any step that had been successfully completed before. Force will ensure all steps are run. Internally this
    is achieved by performing a clean before building.
.PARAMETER debug
    Causes packer to be run with debug settings. Useful if the scripts are not working and you need to debug in flight. Also turns of verbose logging.
.PARAMETER verbose
    Causes packer to be run with logging. Log will be written to 'packer-log.txt'
.PARAMETER vagrantAdd
    If set will add the build box files to vagrant. WARNING: current behaivior is to -force add these boxes as its assumed these boxes were not created corectly the first time and you are running it again.
#>
param([string]$outputDir = "output",
    [string]$vmNamePrefix = "ubuntu",
    [string]$cpus = "2",
    [string]$ramSize = "4096",
    [string]$diskSize = "200000",
    [string]$username = "vagrant",
    [switch]$dontBuildDesktop = $false,
    [switch]$dontBuildArch = $false,
    [switch]$dontBuildVyos = $false,
    [switch]$clean = $false,
    [switch]$force = $false,
    [switch]$debug = $false,
    [switch]$verbose = $false,
    [switch]$vagrantAdd = $false)

#### Configuration
$packer_exe = 'packer.exe'
$vagrant_exe = 'vagrant.exe'
$box_out_dir = 'dist'

# Vm names and locations based on the prefixes given as a parameter.
$base_out_location = './{0}/{1}' -f $outputDir, $vmNamePrefix
$desktop_out_location = '{0}-desktop/' -f $base_out_location
$desktop_vm_name = '{0}-desktop' -f $vmNamePrefix
$desktop_hvsocket_out_location = '{0}-desktop-hvsocket' -f $base_out_location
$enhanced_out_location = './{0}-enhanced/' -f $base_out_location
$enhanced_vm_name = '{0}-enhanced' -f $vmNamePrefix

# Box file location based on the names given as a paramter
$base_box_location = './{0}/hyperv-iso-{1}.box' -f $box_out_dir, $vmNamePrefix
$desktop_box_location = './{0}/hyperv-vmcx-{1}-desktop.box' -f $box_out_dir, $vmNamePrefix
$enhanced_box_location = './{0}/hyperv-vmcx-{1}-enhanced.box' -f $box_out_dir, $vmNamePrefix
$arch_box_location = './{0}/hyperv-iso-arch.box' -f $box_out_dir
$arch_desktop_box_location = './{0}/hyperv-vmcx-arch-desktop.box' -f $box_out_dir
$vyos_box_location = './{0}/hyperv-iso-vyos.box' -f $box_out_dir

#### End configuration

# base parameter arguments to be used for all packer build commands
$base_args = @('-var "cpu={0}"' -f $cpus)
$base_args += '-var "ram_size={0}"' -f $ramSize
$base_args += '-var "disk_size={0}"' -f $diskSize
$base_args += '-var "username={0}"' -f $username
$base_args += '-var "box_out_dir={0}"' -f $box_out_dir
if ($debug) {
    $base_args += '--debug'
    $base_args += '--on-error=ask'
}
if ($debug -or $verbose) {
    $env:PACKER_LOG = 1
    $env:PACKER_LOG_PATH = 'packer-log.txt'
}

# base parameter arguments to be used for all vagrant add commands
$vagrant_add_args = @('box')
$vagrant_add_args += 'add'

if ($Clean -or $force) {
    Write-Output -InputObject "Removing existing box files"
    $output_boxs = '{0}/hyperv-*.box' -f $box_out_dir
    Get-ChildItem $output_boxs -Recurse | Remove-Item -Recurse -Force
    Write-Output -InputObject "Removing existing build artivacts"
    $output_dirs = '{0}*' -f $outputDir
    Get-ChildItem $output_dirs -Recurse | Remove-Item -Recurse -Force
    Remove-Item -Path $output_dirs -Recurse -Force
    if ($Clean) {
        exit 0
    }
}

if (-not (Test-Path $base_box_location)) {
    Write-Output -InputObject "Starting packer build for Ubuntu server"
    $server_args = @('build')
    $server_args += '-var "vm_name={0}"' -f $vmNamePrefix
    $server_args += '-var "output_name={0}"' -f $vmNamePrefix
    $server_args += '-var "output_directory={0}"' -f $base_out_location
    $server_args += '--only=hyperv-iso.ubuntu'

    $server_args += $base_args
    $server_args += '.'

    $build_server = Start-Process -FilePath $packer_exe -ArgumentList $server_args -NoNewWindow -PassThru -Wait

    if ($build_server.ExitCode -ne 0) {
        Write-Error -Message "Failed to build server image with packer"
        exit 1
    }
}
else {
    Write-Output -InputObject "Skipping build for Ubuntu server"
}

if ($dontBuildDesktop) {
    Write-Output -InputObject "Not building desktop images. We are done"
    exit 0
}

if (-not (Test-Path $desktop_box_location)) {
    Write-Output -InputObject "Starting packer build for Ubuntu desktop"
    $desktop_args = @('build')
    # VM name has to match that of the existing vmcx. We could import, rename and export like we do for the enhanced box below, but that seems
    # like a lot of time for little gain assuming that you'll want to use the enhanced one anyway for its awesomness
    $desktop_args += '-var "vm_name={0}"' -f $desktop_vm_name
    $desktop_args += '-var "output_name={0}"' -f $desktop_vm_name
    $desktop_args += '-var "output_directory={0}"' -f $desktop_out_location
    $desktop_args += '-var "input_directory={0}"' -f $base_out_location
    $desktop_args += '--only=*hyperv-vmcx.ubuntu-desktop'
    $desktop_args += $base_args
    $desktop_args += '.'

    $build_desktop = Start-Process -FilePath $packer_exe -ArgumentList $desktop_args -NoNewWindow -PassThru -Wait

    if ($build_desktop.ExitCode -ne 0) {
        Write-Error -Message "Failed to build desktop image with packer"
        exit 1
    }
}
else {
    Write-Output -InputObject "Skipping build for Ubuntu desktop"
}

$version = [environment]::OSVersion.Version
if ($version.Major -ilt 10 -or $version.Build -ilt 17063) {
    Write-Output -InputObject "Host is not on Build 17063 or greater so skipping enhanced mode build"
    exit 0
}

if (-not (Test-Path $enhanced_box_location)) {
    $input_dir = Join-Path -Path $desktop_hvsocket_out_location -ChildPath $enhanced_vm_name
    if (-not (Test-Path $input_dir)) {
        Write-Output -InputObject "Changing desktop vm to use hvsocket for enhanced session transport"
        & "./setup-enhanced-transport-type.ps1" -Path $desktop_out_location -OutPath $desktop_hvsocket_out_location -VmName $desktop_vm_name -OutVmName $enhanced_vm_name
        if (-not $?) {
            Write-Error -Message "setup-enhanced-transport-type failed"
            exit 1
        }
    }

    Write-Output -InputObject "Starting packer build for Ubuntu enhanced desktop"
    $enhanced_args = @('build')
    $enhanced_args += '-var "vm_name={0}"' -f $enhanced_vm_name
    $enhanced_args += '-var "output_name={0}"' -f $enhanced_vm_name
    $enhanced_args += '-var "output_directory={0}"' -f $enhanced_out_location
    $enhanced_args += '-var "input_directory={0}"' -f $input_dir
    $enhanced_args += '--only=*hyperv-vmcx.ubuntu-enhanced'
    $enhanced_args += $base_args
    $enhanced_args += '.'

    $build_enhanced = Start-Process -FilePath $packer_exe -ArgumentList $enhanced_args -NoNewWindow -PassThru -Wait

    if ($build_enhanced.ExitCode -ne 0) {
        Write-Error -Message "Failed to build enhanced image with packer"
        exit 1
    }

}
else {
    Write-Output -InputObject "Skipping build for Ubuntu enhanced desktop"
}

if ($vagrantAdd) {
    $enhanced_vagrant_args = $vagrant_add_args
    $enhanced_vagrant_args += '--name "{0}" --provider hyperv --force' -f $vmNamePrefix
    $enhanced_vagrant_args += '{0}\hyperv-vmcx-{1}.box' -f $box_out_dir, $enhanced_vm_name

    $add_server = Start-Process -FilePath $vagrant_exe -ArgumentList $enhanced_vagrant_args -NoNewWindow -PassThru -Wait

    if ($add_server.ExitCode -ne 0) {
        Write-Error -Message "Failed to add generated enhanced box file to Vagrant"
        exit 1
    }
}

if ($dontBuildArch) {
    Write-Output -InputObject "Not building Arch images. We are done"
    exit 0
}

if (-not (Test-Path $arch_box_location)) {
    Write-Output -InputObject "Starting packer build for Arch"
    $arch_args = @('build')
    $arch_args += '--only=hyperv-iso.arch'

    $arch_args += $base_args
    $arch_args += '.'

    $build_arch = Start-Process -FilePath $packer_exe -ArgumentList $arch_args -NoNewWindow -PassThru -Wait

    if ($build_arch.ExitCode -ne 0) {
        Write-Error -Message "Failed to build Arch image with packer"
        exit 1
    }
}
else {
    Write-Output -InputObject "Skipping build for Arch"
}

if (-not (Test-Path $arch_desktop_box_location)) {
    
    $version = [environment]::OSVersion.Version
    if ($version.Major -ilt 10 -or $version.Build -ilt 17063) {
        Write-Output -InputObject "Host is not on Build 17063 or greater so skipping enhanced mode build"
    }
    else {
        Write-Output -InputObject "Starting packer build for Arch desktop"
        $desktop_args = @('build')
        # VM name has to match that of the existing vmcx. We could import, rename and export like we do for the enhanced box below, but that seems
        # like a lot of time for little gain assuming that you'll want to use the enhanced one anyway for its awesomness
        $desktop_args += '--only=hyperv-vmcx.arch-desktop'
        $desktop_args += $base_args
        $desktop_args += '.'

        $build_desktop = Start-Process -FilePath $packer_exe -ArgumentList $desktop_args -NoNewWindow -PassThru -Wait

        if ($build_desktop.ExitCode -ne 0) {
            Write-Error -Message "Failed to build desktop image with packer"
            exit 1
        }
    }
    
    if ($vagrantAdd) {
        $arch_desktop_vagrant_args = $vagrant_add_args
        $arch_desktop_vagrant_args += '--name "{0}" --provider hyperv --force {1}' -f $vmNamePrefix, $arch_desktop_box_location

        $add_arch = Start-Process -FilePath $vagrant_exe -ArgumentList $arch_desktop_vagrant_args -NoNewWindow -PassThru -Wait

        if ($add_arch.ExitCode -ne 0) {
            Write-Error -Message "Failed to add generated arch dekstop box file to Vagrant"
            exit 1
        }
    }
}



if ($dontBuildVyos) {
    Write-Output -InputObject "Not building VyOS image. We are done"
    exit 0
}

if (-not (Test-Path $vyos_box_location)) {
    Write-Output -InputObject "Starting packer build for VyOS"
    $vyos_args = @('build')
    $vyos_args += '--only=hyperv-iso.vyos'

    $vyos_args += $base_args
    $ip = Get-NetIPAddress -AddressFamily IPV4 -InterfaceAlias "vEthernet (WSL)"
    if ($ip.IPAddress) {
        $ip_parts = $ip.IPAddress.Split('.')
        $base_ip = $ip_parts[0] + '.' + $ip_parts[1] + '.' + ([Int]$ip_parts[2] + 1) + '.'
        $vyos_args += '-var "vyos_ip={0}1"' -f $base_ip
        $vyos_args += '-var "vyos_host_ip={0}"' -f $ip.IPAddress
        $vyos_args += '-var "vyos_subnet_range={0}.{1}.{2}.0/20"' -f $ip_parts[0], $ip_parts[1], $ip_parts[2]
        $vyos_args += '-var "vyos_dhcp_start={0}10"' -f $base_ip
        $vyos_args += '-var "vyos_dhcp_start={0}200"' -f $base_ip
    }
    $vyos_args += '.'
    $build_vyos = Start-Process -FilePath $packer_exe -ArgumentList $vyos_args -NoNewWindow -PassThru -Wait

    if ($build_vyos.ExitCode -ne 0) {
        Write-Error -Message "Failed to build VyOS image with packer"
        exit 1
    }
}
else {
    Write-Output -InputObject "Skipping build for VyOS"
}