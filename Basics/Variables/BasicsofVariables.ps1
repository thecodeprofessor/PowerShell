<#
.SYNOPSIS
Basics of Variables
.DESCRIPTION
Several examples showing the basics of variables and how to use them.
.NOTES  
File Name  : BasicssofVariables.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$string = "This is a sentence."
$number = 5
$location = Get-ChildItem ~ #try replacing ~ with any directory path.

Write-Host $string
Write-Host $number
Write-Host $location