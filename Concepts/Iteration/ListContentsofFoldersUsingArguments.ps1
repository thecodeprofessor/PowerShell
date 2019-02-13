<#
.SYNOPSIS
List Contents of a Variety of Folders using Arguments
.DESCRIPTION
An example of how to use a foreach loop to list the contents of a variety of folders using arguments.
.NOTES  
File Name  : ListContentsofFoldersUsingArguments.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$directories = $args

foreach ($directory in $directories)
{
	Get-ChildItem $directory | Where-Object length -gt 1000 | Sort-Object -property name
}
