#http://support.microsoft.com/kb/2570538
#http://robrelyea.wordpress.com/2007/07/13/may-be-helpful-ngen-exe-executequeueditems/

$base_ngen_location = " %windir%\microsoft.net\framework{0}\{1}\ngen.exe"
$version = "v4.0.30319"
$ngen_location_32 = $base_ngen_location -f "", $version
$ngen_location_64 = $base_ngen_location -f "64", $version

$update_args = @('update', '/force', '/queue')
$executequeueditems_args = @('executequeueditems')

if (Test-Path $ngen_location_32) {
    $result = Start-Process -FilePath $ngen_location_32 -ArgumentList $update_args -NoNewWindow -PassThru -Wait
    f ($result.ExitCode -ne 0) {
        Write-Error -Message "Failed to Run ${ngen_location_32} update"
        exit 1
    }
    $result = Start-Process -FilePath $ngen_location_32 -ArgumentList $executequeueditems_args -NoNewWindow -PassThru -Wait
    f ($result.ExitCode -ne 0) {
        Write-Error -Message "Failed to Run ${ngen_location_32} executequeueditems"
        exit 1
    }
}

if (Test-Path $ngen_location_64) {
    $result = Start-Process -FilePath $ngen_location_64 -ArgumentList $update_args -NoNewWindow -PassThru -Wait
    f ($result.ExitCode -ne 0) {
        Write-Error -Message "Failed to Run ${ngen_location_64} update"
        exit 1
    }
    $result = Start-Process -FilePath $ngen_location_64 -ArgumentList $executequeueditems_args -NoNewWindow -PassThru -Wait
    f ($result.ExitCode -ne 0) {
        Write-Error -Message "Failed to Run ${ngen_location_64} executequeueditems"
        exit 1
    }
}
exit 0
