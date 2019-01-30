<#
.SYNOPSIS
  xpanding Strings and Literal Strings
.DESCRIPTION
Several examples of how to use strings in PowerShell.
.NOTES  
File Name  : ExpandingStringsAndLiteralStrings.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$firstName = "Vincent"
$lastName = "Smith"
$age = 25

Write-Host "Your friend's name is $firstName $lastName and their age is $age." #try adding a backtick just to the left of $firstName like this... `$firstName.
Write-Host 'Your friend''s name is $firstName $lastName and their age is $age.'

Write-Host "The value of $(5+2) is 7."
Write-Host 'The value of $(5+2) is 7.'

