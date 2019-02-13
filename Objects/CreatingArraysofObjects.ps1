
<#
.SYNOPSIS
Creating Object Arrays
.DESCRIPTION
An example of how to create a an array of custom objects.
.NOTES  
File Name  : CreatingArraysofObjects.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

function New-Person ($firstName, $lastName, $favoriteColour = $null)
{
    if ($null -eq $favoriteColour)
    {
        $favoriteColour = Get-FavoriteColour
    }

    $person = [PSCustomObject]@{
        FirstName               = $firstName
        LastName               = $lastName
        FavoriteColour          = $favoriteColour
        EyeColour               = $null
        Height                  = $null
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

function Get-FavoriteColour()
{
    $colour = @(
        "Yellow",
        "Blue",
        "Red",
        "Green",
        "Orange",
        "Purple",
        "Brown"
    )

    return $colour | Get-Random
}

function Get-Height()
{
    #Simulate getting information from another source.
    $height = Get-Random -Minimum 161 -Maximum 174

    return $height
}

#Create a list of 10 random people.
#$people = New-RandomPeople 10


#Add one new person manually
$people = @()
$people += New-Person -firstName "John" -lastName "Smith" -favoriteColour "Aqua"
$people += New-Person -firstName "Jane" -lastName "Doe"
$people += New-Person -firstName "Frank" -lastName "Appleton"

foreach ($person in $people) {
    if ($person.FirstName -eq "John" -and $person.LastName -eq "Smith")
    {
        $person.EyeColour = "Brown"
    } elseif ($person.FirstName -eq "Jane" -and $person.LastName -eq "Doe")
    {
        $person.EyeColour = "Blue"
    } elseif ($person.FirstName -eq "Frank" -and $person.LastName -eq "Appleton")
    {
        $person.EyeColour = "Green"
    }

    $person.Height = Get-Height
}

$people | Format-Table


#Display the people on screen using Format-Table
$people | Format-Table

#Display the people on screen using a foreach loop.
#foreach ($person in $people) {
#    Write-Host "$($person.FirstName) $($person.LastName)"
#}
