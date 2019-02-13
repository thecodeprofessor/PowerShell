<#
.SYNOPSIS
Secret Password Game Optimized
.DESCRIPTION
Another example of how to use a do until loop and a conditional statement to check inputted text. This example is cleaned up from the first to remove unneeded variables.
.NOTES  
File Name  : SecretPasswordGameOptimized.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$secretPassword = "happy"

Do {
    if ((Read-Host "`n Type The Secret Password") -eq $secretPassword) {
        Write-Host "`n You Are Right!" -ForegroundColor Green
        #try using nothing, break, or exit here. Notice what changes after answering correctly.
    }
    else {
        Write-Host "`n Wrong!" -ForegroundColor Red
    }
} Until ((Read-Host "`n Do you want another guess? (y/n)") -like "n")

Write-Host "`n Thanks for Playing!`n" -ForegroundColor Blue