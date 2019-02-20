<#
.SYNOPSIS
Creating File Shares
.DESCRIPTION
An example of using a foreach loop to create a series of windows SMB shares.
.NOTES  
File Name  : IteratingThroughFileAccess.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

[string]$path = "C:\Shares"
[string[]]$users = @("John Doe", "Jane Smith", "Bob Johnson")

foreach ($user in $users) {
    $folder = $user -replace " ", ""
    $folder = $folder.ToLower()
    New-Item -Path "$path\$folder" -ItemType directory -ErrorAction 0 | Out-Null

    New-SmbShare -Name "$folder" -Path "$path\$folder" -FullAccess "Everyone" -ErrorAction 0 | Out-Null
      Write-Host "$folder"
}

