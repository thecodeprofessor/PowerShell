<#
.SYNOPSIS
Secret Password Game
.DESCRIPTION
An example of how to use a do until loop and a conditional statement to check inputted text. This example uses variables to help illustrate the flow of information.
.NOTES  
File Name  : SecretPasswordGame.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$secretPassword = "happy"
$playAgain = "y"

Do {
    $guess = Read-Host "`n Type The Secret Password"

    if ($guess -eq $secretPassword) {
        Write-Host "`n You Are Right! $guess is the Secret Password."
        $playAgain = "n"
    }
    else {
        Write-Host "`n Wrong! $guess is NOT the Secret Password."
        $playAgain = Read-Host "`n Do you want another guess? (y/n)"
    }
} Until ($playAgain -eq "n")

Write-Host "`n Thanks for Playing!`n"