<#
.SYNOPSIS
    Makes an iso image from a set of files.
.DESCRIPTION
    Makes an iso image from a set of files or folders.
.PARAMETER Source
    Collection of comma seperated files/folders to add to the iso image
.PARAMETER OutPath
    The Path to save the new iso image.
.PARAMETER Force
    Overwrite the OutPath if it already exists.
.PARAMETER Title
    Name for the created iso.
#>
param(
      [Parameter(Position = 0)]
      [string[]]$Source,
      [string]$OutPath,
      [switch]$Force,
      [string]$Title = (Get-Date).ToString("yyyyMMdd-HHmmss.ffff"))

      ($cp = new-object System.CodeDom.Compiler.CompilerParameters).CompilerOptions = '/unsafe'
    if (!('ISOFile' -as [type])) {
      Add-Type -CompilerParameters $cp -TypeDefinition @"
public class ISOFile
{
  public unsafe static void Create(string Path, object Stream, int BlockSize, int TotalBlocks)
  {
    int bytes = 0;
    byte[] buf = new byte[BlockSize];
    var ptr = (System.IntPtr)(&bytes);
    var o = System.IO.File.OpenWrite(Path);
    var i = Stream as System.Runtime.InteropServices.ComTypes.IStream;

    if (o != null) {
      while (TotalBlocks-- > 0) {
        i.Read(buf, BlockSize, ptr); o.Write(buf, 0, bytes);
      }
      o.Flush(); o.Close();
    }
  }
}
"@
    }

$Image = New-Object -ComObject IMAPI2FS.MsftFileSystemImage
$Image.VolumeName = $Title
$Image.FileSystemsToCreate = 3 # ISO9660 + Joliet
If(!(test-path $OutPath)) {
    $OutFile = New-Item -Path $OutPath -ItemType File -Force
} else {
    $OutFile = New-Item -Path $OutPath -ItemType File -Force:$Force
}

foreach($itemStr in $Source) {
    $item = Get-Item -LiteralPath $itemStr
    try {
        $Image.Root.AddTree($item.FullName, $true)
    } catch {
        Write-Error -Message $_.Exception.Message.Trim()
    }
}
$Result = $Image.CreateResultImage()
[ISOFile]::Create($OutFile.FullName,$Result.ImageStream,$Result.BlockSize,$Result.TotalBlocks)
Write-Verbose -Message "Target image ($($OutFile.FullName)) has been created"
$OutFile
