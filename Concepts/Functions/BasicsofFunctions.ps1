<#
.SYNOPSIS
Basics of Functions
.DESCRIPTION
Several examples showing the basics of functions and how to use them.
.NOTES  
File Name  : BasicssofFunctions.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>
function Get-Greeting
{ 
    return "Hello, sunshine!" 
}

Write-Host "Your greeting is: $(Get-Greeting)"

function Get-RandomGreeting
{ 
    $greetings = @(
        "Hi!",
        "Howdy, partner!",
        "Peek-a-boo!",
        "What's up?",
        "Hey there, freshman!",
        "Hi, mister!",
        "I come in peace!",
        "Put that cookie down!",
        "Welcome!"
    )

    return $greetings | Get-Random
}

Write-Host "Your Random greeting is: $(Get-RandomGreeting)"