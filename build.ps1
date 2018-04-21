<#
.SYNOPSIS
    Builds Packer Ubuntu 16.04 boxes for Hyper-V
.DESCRIPTION
    Wrapper around packer and some build configurations to automate the building process for three boxes.
      1) Base Ubuntu 16.04 server
      2) Ubuntu 16.04 Desktop
      3) Ubuntu 16.04 Desktop with enhanced session support (Currently equires Windows insider build) see: https://blogs.technet.microsoft.com/virtualization/2018/02/28/sneak-peek-taking-a-spin-with-enhanced-linux-vms/
    Also provides command line configuration for these builds.
.PARAMETER outputNamePrefix
    The base name for the output directories. This is used to pass to following packer builds to generate the desktop and enhanced session boxes.
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
.PARAMETER clean
    Cleans up all the artifacts of the build process.
.PARAMETER force
    Defatult behaivor is to skip any step that had been successfully completed before. Force will ensure all steps are run. Internally this
    is achieved by performing a clean before building.
.PARAMETER debug
    Causes packer to be run with debug settings. Useful if the scripts are not working and you need to debug in flight.
.PARAMETER vagrantAdd
    If set will add the build box files to vagrant. WARNING: current behaivior is to -force add these boxes as its assumed these boxes were not created corectly the first time and you are running it again.
#>
param([string]$outputNamePrefix = "output-ubuntu-16.04",
      [string]$vmNamePrefix = "ubuntu-16.04",
      [string]$cpus = "2",
      [string]$ramSize = "4096",
      [string]$diskSize = "200000",
      [string]$username = "vagrant",
      [switch]$dontBuildDesktop = $false,
      [switch]$clean = $false,
      [switch]$force = $false,
      [switch]$debug = $false)

#### Configuration
$packer_exe = 'packer.exe'
$vagrant_exe = 'vagrant.exe'
$base_json = './hyperv-ubuntu-16.04.json'
$desktop_json = './hyperv-ubuntu-16.04-desktop.json'
$enhanced_json = './hyperv-ubuntu-16.04-enhanced.json'
$box_out_dir = './dist/'

# Vm names and locations based on the prefixes given as a parameter.
$base_out_location = './{0}/' -f $outputNamePrefix
$desktop_out_location = './{0}-desktop/' -f $outputNamePrefix
$desktop_vm_name = '{0}-desktop' -f $vmNamePrefix
$desktop_hvsocket_out_location = '{0}-desktop-hvsocket' -f $outputNamePrefix
$enhanced_out_location = './{0}-enhanced/' -f $outputNamePrefix
$enhanced_vm_name = '{0}-enhanced' -f $vmNamePrefix

# Box file location based on the names given as a paramter
$base_box_location = './{0}/hyperv-{1}.box' -f $box_out_dir, $vmNamePrefix
$desktop_box_location = './{0}/hyperv-{1}-desktop.box' -f $box_out_dir, $vmNamePrefix
$enhanced_box_location = './{0}/hyperv-{1}-enhanced.box' -f $box_out_dir, $vmNamePrefix

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
    $env:PACKER_LOG=1
    $env:PACKER_LOG_PATH=packer-log.txt
}

# base parameter arguments to be used for all vagrant add commands
$vagrant_add_args =  @('box')
$vagrant_add_args += 'add'

if($Clean -or $force) {
    Write-Output -InputObject "Removing existing box files"
    $output_boxs = '{0}/*{1}*.box' -f $box_out_dir, $vmNamePrefix
    Get-ChildItem $output_boxs -Recurse | Remove-Item -Recurse -Force
    Write-Output -InputObject "Removing existing build artivacts"
    $output_dirs = '{0}*' -f $outputNamePrefix
    Get-ChildItem $output_dirs -Recurse | Remove-Item -Recurse -Force
    Remove-Item -Path $output_dirs -Recurse -Force
    if($Clean) {
        exit 0
    }
}

if (-not (Test-Path $base_box_location)) {
    Write-Output -InputObject "Starting packer build for Ubuntu server"
    $server_args = @('build')
    $server_args += '-var "vm_name={0}"' -f $vmNamePrefix
    $server_args += '-var "output_name={0}"' -f $vmNamePrefix
    $server_args += '-var "output_directory={0}"' -f $base_out_location

    $server_args += $base_args
    $server_args += $base_json

    $build_server = Start-Process -FilePath $packer_exe -ArgumentList $server_args -NoNewWindow -PassThru -Wait

    if ($build_server.ExitCode -ne 0) {
        Write-Error -Message "Failed to build server image with packer"
        exit 1
    }

    if ($vagrantAdd) {
        $server_vagrant_args = $base_args
        $server_vagrant_args += '-name "{0}"' -f $vmNamePrefix
        $server_vagrant_args += './{0}/hyperv-{1}.box' -f $box_out_dir, $vmNamePrefix

        $add_server = Start-Process -FilePath $vagrant_exe -ArgumentList $server_vagrant_args -NoNewWindow -PassThru -Wait
    
        if ($add_server.ExitCode -ne 0) {
            Write-Error -Message "Failed to add generated box file to Vagrant"
            exit 1
        }
    }
}

if($dontBuildDesktop) {
    Write-Output -InputObject "Not building desktop images. We are done"
    exit 0
}

if (-not (Test-Path $desktop_box_location)) {
    Write-Output -InputObject "Starting packer build for Ubuntu desktop"
    $desktop_args = @('build')
    # VM name has to match that of the existing vmcx. We could import, rename and export like we do for the enhanced box below, but that seems
    # like a lot of time for little gain assuming that you'll want to use the enhanced one anyway for its awesomness    
    $desktop_args += '-var "vm_name={0}"' -f $vmNamePrefix
    $desktop_args += '-var "output_name={0}"' -f $desktop_vm_name
    $desktop_args += '-var "output_directory={0}"' -f $desktop_out_location
    $desktop_args += '-var "input_directory={0}"' -f $base_out_location
    $desktop_args += $base_args
    $desktop_args += $desktop_json

    $build_desktop = Start-Process -FilePath $packer_exe -ArgumentList $desktop_args -NoNewWindow -PassThru -Wait

    if ($build_desktop.ExitCode -ne 0) {
        Write-Error -Message "Failed to build desktop image with packer"
        exit 1
    }

    if ($vagrantAdd) {
        $desktop_vagrant_args = $base_args
        $desktop_vagrant_args += '-name "{0}"' -f $desktop_vm_name
        $desktop_vagrant_args += './{0}/hyperv-{1}.box' -f $box_out_dir, $desktop_vm_name

        $add_server = Start-Process -FilePath $vagrant_exe -ArgumentList $desktop_vagrant_args -NoNewWindow -PassThru -Wait
    
        if ($add_server.ExitCode -ne 0) {
            Write-Error -Message "Failed to add generated desktop box file to Vagrant"
            exit 1
        }
    }
}

$version = [environment]::OSVersion.Version
if ($version.Major -ilt 10 -or $version.Build -ilt 17063) {
    Write-Output -InputObject "Host is not on Build 17063 or greater so skipping enhanced mode build"
    exit 0
}

if (-not (Test-Path $enhanced_box_location)) {
    $hvsocket_path = 'output-{0}-desktop-hvsocket' -f $vmNamePrefix
    if (-not (Test-Path $hvsocket_path)) {
        Write-Output -InputObject "Changing desktop vm to use hvsocket for enhanced session transport"
        & "./setup-enhanced-transport-type.ps1" -Path $desktop_out_location -OutPath $desktop_hvsocket_out_location -VmName $vmNamePrefix -OutVmName $enhanced_vm_name
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
    $input_dir = Join-Path -Path $desktop_hvsocket_out_location -ChildPath $enhanced_vm_name
    $enhanced_args += '-var "input_directory={0}"' -f $input_dir
    $enhanced_args += $base_args
    $enhanced_args += $enhanced_json

    $build_enhanced = Start-Process -FilePath $packer_exe -ArgumentList $enhanced_args -NoNewWindow -PassThru -Wait

    if ($build_enhanced.ExitCode -ne 0) {
        Write-Error -Message "Failed to build enhanced image with packer"
        exit 1
    }

    if ($vagrantAdd) {
        $enhanced_vagrant_args = $base_args
        $enhanced_vagrant_args += '-name "{0}"' -f $enhanced_vm_name
        $enhanced_vagrant_args += './{0}/hyperv-{1}.box' -f $box_out_dir, $enhanced_vm_name

        $add_server = Start-Process -FilePath $vagrant_exe -ArgumentList $enhanced_vagrant_args -NoNewWindow -PassThru -Wait
    
        if ($add_server.ExitCode -ne 0) {
            Write-Error -Message "Failed to add generated enhanced box file to Vagrant"
            exit 1
        }
    }
}