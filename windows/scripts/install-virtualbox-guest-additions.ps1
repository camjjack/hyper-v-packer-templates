$ErrorActionPreference = 'Stop'

Write-Output "Installing Virtualbox Guest Additions"
$image = Mount-DiskImage -PassThru -ImagePath "C:\Users\vagrant\VBoxGuestAdditions.iso"
$drive = ($image | get-volume ).DriveLetter
$drive_path = "$($drive):\"

Write-Output "Checking for Certificates in vBox ISO"
if(test-path $drive_path -Filter *.cer)
{
  Get-ChildItem "$($drive_path)\cert" -Filter *.cer | ForEach-Object { certutil -addstore -f "TrustedPublisher" $_.FullName }
}
Start-Process -FilePath "$($drive_path)\VBoxWindowsAdditions.exe" -ArgumentList "/S" -Wait