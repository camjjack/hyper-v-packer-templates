$size = 1GB
$root = "C:\"
$filePathTemplate = "{0}scrub{1}.tmp"

Try {
    $count = 0
    Write-Output -InputObject "Starting scrubbing"
    $ZeroArray = new-object byte[]($size)
    $SourceFile = $filePathTemplate -f $root, $count
    $count += 1
    $Stream= [io.File]::OpenWrite($SourceFile)
    $Stream.Write($ZeroArray,0, $ZeroArray.Length)
    $Stream.Close()
    
    $count = 1
    Write-Output -InputObject "Creating many large files filled with 0's"
    while ((Get-WmiObject win32_volume | Where-Object {$_.name -eq "$root"}).Freespace -gt $size) {
        $TargetFile = $filePathTemplate -f $root, $count
        Copy-Item $SourceFile -Destination $TargetFile
        $count += 1
    }
    Write-Output -InputObject "Removing all the files with 0's"
    Remove-Item "$($root)scrub*.tmp"
  }
Catch {
    Write-Error -Message "Reclaim Failed. Cleaning up..."
    Remove-Item "$($root)scrub*.tmp"
    Exit 1
  }

