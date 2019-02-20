<#
.SYNOPSIS
  Choosing a Function With Read-Host
.DESCRIPTION
  Several examples showing how to get input from the user and use it to run a function.
.NOTES  
File Name  : ChoosingaFunctionWithReadHost.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

function Get-Menu {
    Write-Host "`nPlease choose one of the following options:" -ForegroundColor Green
    Write-Host "1) Display a list of files and folders."
    Write-Host "2) Display information about my computer.`n"
    Write-Host "3) Tell me a joke."

    $selection = Read-Host "Type 1, 2, 3, or q to quit."

    switch ($selection) {
        "1" { 
            Get-ListofFilesandFolders
            break;
        }
        "2" { 
            Get-ComputerInformation
            break;
        }
        "3" { 
            Write-Host "$(Get-Joke)" -ForegroundColor Blue
            break;
        }
        "q" { 
            Write-Host "Bye!" -ForegroundColor Green
            break;
        }
        Default {
            Get-Menu
        }
    }
}

function Get-ListofFilesandFolders
{
    Write-Host "`nHere is a list of files and folders:" -ForegroundColor Blue
    Get-ChildItem "C:\" | Format-Table
}

function Get-ComputerInformation
{
    $systemInfo = systeminfo
    $memory = (($systemInfo | Select-String 'Total Physical Memory:') -Replace 'Total Physical Memory:','').Trim()
    $bootTime = (($systemInfo | Select-String 'System Boot Time:').ToString() -Replace 'System Boot Time:','').Trim()

    Write-Host "`nHere are some fun facts about your computer:" -ForegroundColor Blue
    Write-Host "You have $memory of memory in your computer." -ForegroundColor Yellow
    Write-Host "$bootTime is when you turned your computer." -ForegroundColor Yellow
}

function Get-Joke
{ 
    $jokes = @(
        "I'd tell you a joke about UDP, but you probably wouldn't get it.",
        "I was telling my workmates a TCP joke the other day; I had to keep repeating it slower and slower until they got it.",
        "A TCP packet walks into a bar and says, ""I'd like a beer."" The bartender replies, ""You want a beer?"" The TCP packet replies, ""Yes, I'd like a beer.""",
        "What's the best thing about telling UDP jokes?... You don't care when nobody gets them.",
        "An SQL statement walks into a bar and sees two tables. It approaches, and asks: may I join you?",
        "I tried to come up with an IPv4 joke, but the good ones were all already exhausted...",
        "What does networking seal say? Arp! Arp! Arp!",
        "How many programmers does it take to screw in a lightbulb? None. That's a hardware issue."
    )

    return $jokes | Get-Random
}

Get-Menu