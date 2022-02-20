Write-Host "Install Containers feature"
Enable-WindowsOptionalFeature -Online -FeatureName containers -All -NoRestart
Write-Host "Install Hyper-V feature"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
sc.exe config winrm start= delayed-auto
