<#
.SYNOPSIS
List Disk Space Using Custom Properties
.DESCRIPTION
 An example of using a property list with a name and expression to customize the output of the Format-Table cmdlet.
.NOTES  
File Name  : GetDiskSpaceUsingCustomProperties.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

Write-Host "`nYour computer's disk space is as follows..."  -ForegroundColor Blue

$properties = @(
    @{ Name = "Letter"; Expression = {$_.DeviceID}},
    @{ Name = "Name"; Expression = {$_.VolumeName}},
    @{ Name = "Size (GB)"; Expression = {[math]::Round($_.Size / 1GB, 2) }; Alignment = "right"; },
    @{ Name = "Size (TB)"; Expression = {[math]::Round($_.Size / 1TB, 2) }; Alignment = "right"; },
    @{ Name = "Free (GB)"; Expression = {[math]::Round($_.FreeSpace / 1GB, 2) }; Alignment = "right"; },
    @{ Name = "Free (TB)"; Expression = {[math]::Round($_.FreeSpace / 1TB, 2) }; Alignment = "right"; },
    @{ Name = "Free (%)"; Expression = {([math]::Round($_.FreeSpace / $_.Size, 2) * 100) }; Alignment = "right"; }
)

Get-WmiObject Win32_LogicalDisk | Format-Table -Property $properties -AutoSize