
<#
.SYNOPSIS
Creating Object Arrays
.DESCRIPTION
An example of how to create a an array of custom objects.
.NOTES  
File Name  : CreatingArraysofObjects.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

function New-Person ($firstName, $lastName)
{
    $person = [PSCustomObject]@{
        FirstName               = $firstName
        LastName               = $lastName
    }

    return $person
}

function Get-RandomUsers([int]$count = 1) {
    $body = @{
        nat      = 'us'
        inc      = 'name,login,password'
        results  = $count
        password = 'special,upper,lower,10-16'
    }

    $users = Invoke-WebRequest -Uri 'https://randomuser.me/api/' -Body $body -Method Get | ConvertFrom-Json
    
    return $users.results
}

function New-RandomPeople([int]$count = 1) {
    $randomUsers = Get-RandomUsers($count)

    $people = @()

    foreach ($randomUser in $randomUsers) {
        $people += New-Person ((Get-Culture).TextInfo).ToTitleCase("$($randomUser.name.first)") ((Get-Culture).TextInfo).ToTitleCase("$($randomUser.name.last)")
    }

    return $people
}

#Create a list of 10 random people.
$people = New-RandomPeople 10

#Display the 10 random people on screen using Format-Table
$people | Format-Table

#Display the 10 random people on screen using a foreach loop.
#foreach ($person in $people) {
#    Write-Host "$($person.FirstName) $($person.LastName)"
#}
