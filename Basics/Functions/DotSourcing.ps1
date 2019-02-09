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

#Replace the paths below with the proper full path to the BasicsofFunctions.ps1 and notice that you can now call
#functions that are a part of BasicsofFunctions.ps1 from within this script.

. "C:\PowerShellScripts\Basics\Functions\BasicsofFunctions.ps1"

Write-Host "Your Random greeting is: $(Get-RandomGreeting)"


#Try this in a regular PowerShell console window:

#PS C:\> . .\PowerShellScripts\Basics\Functions\BasicsofFunctions.ps1
#Your greeting is: Hello, sunshine!
#Your Random greeting is: I come in peace!
#PS C:\> Get-RandomGreeting
#Hey there, freshman!
#PS C:\>
#You can now use the functions located inside the BasicsofFunctions.ps1 within your PowerShell console window.