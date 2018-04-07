<#
.SYNOPSIS
    Copies a Hyper-V vmcx and sets EnhancedSessionTransportType to HvSocket on the new vmcx
.DESCRIPTION
    Copies a Hyper-V vmcx and sets EnhancedSessionTransportType to HvSocket on the new vmcx. 
    Used to enable enhacned session on Ubuntu 16.04+ with Windows Insider builds. see: https://blogs.technet.microsoft.com/virtualization/2018/02/28/sneak-peek-taking-a-spin-with-enhanced-linux-vms/
.PARAMETER Path
    The Path that contains the the base virtual machine to copy.
.PARAMETER OutPath
    The Path to save the new virtual machine.
.PARAMETER vmName
    The name for the base virtual machine. Used to identify the virtual machine once imported into Hyper-V
.PARAMETER OutVmName
    The name for the resultant virtual machine.
#>
param([string]$Path,
      [string]$OutPath,
      [string]$VmName,
      [string]$OutVmName)

$vmcx_path = Join-Path -Path $Path -ChildPath "Virtual Machines\*.vmcx"
$vmcx = Get-Item -Path $vmcx_path

$VirtualHarddisksPath = Join-Path -Path $OutPath -ChildPath 'Virtual Hard Disks'

Write-Output -InputObject "Importing Desktop VM"
Import-VM -Path $vmcx -VirtualMachinePath $OutPath -VhdDestinationPath $VirtualHarddisksPath -Copy
if (-not $?) {
    Write-Error -Message "Failed to Import Desktop VM"
    exit 1
}

if (-$?) {
    Write-Output -InputObject "Importing suceeded"
}

Write-Output -InputObject "Renaming VM to -enhanced"
Rename-VM -VMName $VmName -NewName $OutVmName
if (-not $?) {
    Write-Error -Message "Failed to change name of imported VM"
    exit 1
}

Write-Output -InputObject "Changing Enhanced Session Transport Type"
Set-VM -VMName $OutVmName -EnhancedSessionTransportType HvSocket
if (-not $?) {
    Write-Error -Message "Failed to Set Enhanced Session Transport Type on Imported VM"
    exit 1
}
Write-Output -InputObject "Exporting modified VM"
Export-VM -Name $OutVmName -Path $OutPath
if (-not $?) {
    Write-Error -Message "Failed to Export hvsocket VM"
    exit 1
}
Write-Output -InputObject "Removing modified VM"
Remove-VM -Name $OutVmName -Force
if (-not $?) {
    Write-Error -Message "Failed to Remove hvsocket VM"
    exit 1
}