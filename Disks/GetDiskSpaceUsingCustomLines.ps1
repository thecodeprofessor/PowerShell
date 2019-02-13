<#
.SYNOPSIS
List Disk Space Using Custom Lines
.DESCRIPTION
An example of using custom lines and widths to have complete control over output.
.NOTES  
File Name  : GetDiskSpaceUsingCustomLines.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$disks = Get-WmiObject Win32_LogicalDisk

$lineWidths = "{0,-12} {1,-12} {2,-12} {3,-12} {4,-12} {5,-12} {6,-12}"

write-output $($lineWidths -f "Letter","Name","Size (GB)","Size (TB)","Free (GB)","Free (TB)","Free (%)")
write-output $($lineWidths -f "------","----","---------","---------","---------","---------","--------")
foreach ($disk in $disks)
{
  write-output $($lineWidths -f $(Write-Host $disk.DeviceID -NoNewLine -ForegroundColor Green),
  $disk.VolumeName,
  [math]::Round($disk.Size / 1GB, 2),
  [math]::Round($disk.Size / 1TB, 2),
  [math]::Round($disk.FreeSpace / 1GB, 2),
  [math]::Round($disk.FreeSpace / 1TB, 2),
  ([math]::Round($disk.FreeSpace / $disk.Size, 2) * 100)
  )
}