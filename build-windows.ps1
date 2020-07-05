<#
.SYNOPSIS
    Builds Packer Windows 10 boxes for Hyper-V
.DESCRIPTION
    Wrapper around packer and some build configurations to automate the building process for Windows 10 boxes.
.PARAMETER outputNamePrefix
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
.PARAMETER clean
    Cleans up all the artifacts of the build process.
.PARAMETER force
    Defatult behaivor is to skip any step that had been successfully completed before. Force will ensure all steps are run. Internally this
    is achieved by performing a clean before building.
.PARAMETER debug
    Causes packer to be run with debug settings. Useful if the scripts are not working and you need to debug in flight.
.PARAMETER verbose
    Turns on packer logging.
.PARAMETER vagrantAdd
    If set will add the build box files to vagrant. WARNING: current behaivior is to -force add these boxes as its assumed these boxes were not created corectly the first time and you are running it again.
#>
param([string]$outputNamePrefix = "output-windows-10",
      [string]$vmNamePrefix = "windows-10",
      [string]$cpus = "2",
      [string]$ramSize = "4096",
      [string]$diskSize = "200000",
      [string]$username = "vagrant",
      [switch]$clean = $false,
      [switch]$force = $false,
      [switch]$debug = $false,
      [switch]$verbose = $false,
      [switch]$vagrantAdd = $false)

#### Configuration
$packer_exe = "packer.exe"
$vagrant_exe = 'vagrant.exe'
$base_json = './hyperv-windows-10.json'
$box_out_dir = './dist/'

# Vm names and locations based on the prefixes given as a parameter.
$base_out_location = './{0}/' -f $outputNamePrefix

# Box file location based on the names given as a paramter
$base_box_location = './{0}/hyperv-{1}.box' -f $box_out_dir, $vmNamePrefix

# base parameter arguments to be used for all packer build commands
$base_args = @('-var "cpu={0}"' -f $cpus)
$base_args += '-var "ram_size={0}"' -f $ramSize
$base_args += '-var "disk_size={0}"' -f $diskSize
$base_args += '-var "username={0}"' -f $username
$base_args += '-var "box_out_dir={0}"' -f $box_out_dir
$base_args += '-var "tmp={0}\{1}"' -f $PSScriptRoot, "tmp"
if ($debug) {
    $base_args += '--debug'
    $base_args += '--on-error=ask'
}

if ($verbose -or $debug) {
    $env:PACKER_LOG=1
    $env:PACKER_LOG_PATH=packer-log.txt
} else {
    $env:PACKER_LOG=0
    $env:PACKER_LOG_PATH=''
}

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

Write-Output "Building floppy iso"
& "./windows/scripts/mkiso.ps1" -Source './windows/answer_files/autounattend.xml', './windows/floppy/' -OutPath './windows/iso/floppy.iso' -Force
if (-not $?) {
    Write-Error -Message "Building floppy iso failed"
    exit 1
} else {
    Write-Output "Sucessfully built floppy iso"
}

if (-not (Test-Path $base_box_location)) {
    Write-Output -InputObject "Starting packer build for Windows 10"
    $win10_args = @('build')
    $win10_args += '-var "vm_name={0}"' -f $vmNamePrefix
    $win10_args += '-var "output_name={0}"' -f $vmNamePrefix
    $win10_args += '-var "output_directory={0}"' -f $base_out_location
    $win10_args += '--only=hyperv-iso'

    $win10_args += $base_args
    $win10_args += $base_json

    $build_server = Start-Process -FilePath $packer_exe -ArgumentList $win10_args -NoNewWindow -PassThru -Wait

    if ($build_server.ExitCode -ne 0) {
        Write-Error -Message "Failed to build Windows 10 with packer"
        exit 1
    }

    if ($vagrantAdd) {
        $win10_vagrant_args = @('box')
        $win10_vagrant_args += 'add'
        if($force) {
            $win10_vagrant_args += '--force'
        }
        $win10_vagrant_args += '--name "{0}"' -f $vmNamePrefix
        $win10_vagrant_args += $base_box_location

        $add_server = Start-Process -FilePath $vagrant_exe -ArgumentList $win10_vagrant_args -NoNewWindow -PassThru -Wait
    
        if ($add_server.ExitCode -ne 0) {
            Write-Error -Message "Failed to add generated box file to Vagrant"
            exit 1
        }
    }
}
