$chocoExePath = 'C:\ProgramData\Chocolatey\bin'

if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower())) {
  Write-Output "Chocolatey found in PATH, skipping install..."
  exit 0
}

# Add to system PATH
$systemPath = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine)
$systemPath += ';' + $chocoExePath
[Environment]::SetEnvironmentVariable("PATH", $systemPath, [System.EnvironmentVariableTarget]::Machine)

# Update local process' path
$userPath = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::User)
if($userPath) {
  $env:Path = $systemPath + ";" + $userPath
} else {
  $env:Path = $systemPath
}

# Run the installer
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower())) {
  Write-Output "Chocolatey installed correctly"
  exit 0
}
