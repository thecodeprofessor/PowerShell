<#
.SYNOPSIS
DotSourcing
.DESCRIPTION
An example of how to use dot-sourcing. Dot-sourcing is a way that you can reference
code in one script from inside another script. 
.NOTES  
File Name  : DotDourcing.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

#replace the path below with the proper full path to the BasicsofFunctions.ps1 and notice that you can now call
#functions that are a part of BasicsofFunctions.ps1 from within this script.

. "C:\PowerShellScripts\Basics\Functions\BasicsofFunctions.ps1"

Write-Host "Your Random greeting is: $(Get-RandomGreeting)"

