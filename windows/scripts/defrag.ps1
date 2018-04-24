Write-Output -InputObject "Starting defrag via Optimize-Volume"
Optimize-Volume -DriveLetter C
Write-Output -InputObject "Finished defrag"