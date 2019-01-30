<#
.SYNOPSIS
List Contents of a Variety of Folders
.DESCRIPTION
An example of how to use a foreach loop to list the contents of a variety of folders.
.NOTES  
File Name  : ListContentsofFolders.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$directories = "c:\windows\system32", "c:\windows\system32\drivers\etc", "c:\windows"

foreach ($directory in $directories)
{
	Get-ChildItem $directory | Where-Object length -gt 1000 | Sort-Object -property name
}
