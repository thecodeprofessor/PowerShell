<#
.SYNOPSIS
Get Response
.DESCRIPTION
An example of how to use a function to centralize the concept of getting user input.
You can specify a response as a list of valid inputs, an integer , or as a string with a minimum length.
.NOTES  
File Name  : GetResponse.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

Enum ResponseTypes {
    List
    PositiveInteger
    String
}

function Get-Response ($lines, [ResponseTypes]$type, $options) {
    do {
        $count = 0
        foreach ($line in $lines) {
            if (![string]::IsNullOrEmpty($line)) {
                if ($count -eq $lines.length - 1) {
                    $response = Read-Host "$line"
                }
                else {
                    Write-Host "$line"
                }
            }
            $count++
        }

        $validated = $false

        if (![string]::IsNullOrEmpty($response)) {
            if ($type -eq [ResponseTypes]::List -and ($options -contains $response)) {
                $validated = $true
            }
            elseif ($type -eq [ResponseTypes]::String -and $response.length -ge $options) {
                $validated = $true
            }
            elseif ($type -eq [ResponseTypes]::PositiveInteger -and $response -match "^\d+$" -and [int]$response -gt 0) {
                $validated = $true
            }
        }

        if (!$validated) {
            Write-Host "Invalid selection. Please try again.`n"; $response = $null
        }

    } while (!$validated)
    return $response
}

#Example of getting a response from a pre-set list.
$list = Get-Response @(
    "Type the letter of the choice you would like:",
    "`ta) for the first option.",
    "`tb) for the second option.",
    "(enter a or b)") List @("a", "b")

#Example of getting a response that is a valid positive integer.
$number = Get-Response @("Please enter a positive integer") PositiveInteger

#Example of getting a response that is a valid string of at least 4 characters.
$string = Get-Response @("Please type a string of at least 4 characters") String 4