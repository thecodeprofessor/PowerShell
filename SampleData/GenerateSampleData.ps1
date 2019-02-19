<#
.SYNOPSIS
Generate Sample Data
.DESCRIPTION
An example of how to use randomuser.me and baconipsum.com to generate sample data files that you can use for testing.
.NOTES  
File Name  : GenerateSampleData.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>
function Get-LorumIpsumParagraphs([int]$paragraphs = 1) {
    $body = @{
        type   = 'meat-and-filler'
        paras  = $paragraphs
        format = 'text'
    }
    $lorumIpsum = Invoke-WebRequest -Uri 'https://baconipsum.com/api/' -Body $body -Method Get | Select-Object -Expand Content

    return $lorumIpsum
}

function Get-LorumIpsumDocuments([int]$count = 10, [int]$minimumParagraphs = 2, [int]$maximumParagraphs = 30) {
    $documents = @()

    for ($i = 0; $i -lt $count; $i++) {
        [int]$paragraphs = Get-Random -Minimum $minimumParagraphs -Maximum $maximumParagraphs

        $documents += [PSCustomObject]@{
            paragraphs = $paragraphs
            content    = Get-LorumIpsumParagraphs $paragraphs
        }
        
    }

    return $documents
}

function Get-RandomUsers([int]$count = 1) {
    $body = @{
        nat      = 'us'
        results  = $count
    }

    $randomUsers = Invoke-WebRequest -Uri 'https://randomuser.me/api/' -Body $body -Method Get | ConvertFrom-Json
    
    return $randomUsers.results
}

function Get-RandomItem ([string[]] $items)
{ 
    return [string]($items | Get-Random)
}

function New-SampleData([int]$maximum = 100, $path) {
    New-Item -Path "$path\Json\" -ItemType Directory -ErrorAction 0 | Out-Null
    New-Item -Path "$path\Csv\" -ItemType Directory -ErrorAction 0 | Out-Null
    New-Item -Path "$path\Html\" -ItemType Directory -ErrorAction 0 | Out-Null
    New-Item -Path "$path\Text\" -ItemType Directory -ErrorAction 0 | Out-Null
    New-Item -Path "$path\Paragraphs\" -ItemType Directory -ErrorAction 0 | Out-Null
    New-Item -Path "$path\Pictures\" -ItemType Directory -ErrorAction 0 | Out-Null

    if (!(Test-Path -Path "$path\RandomUserMeCache.json")) {
        Get-RandomUsers(($maximum * 5)) | ConvertTo-Json | Out-File -FilePath "$path\RandomUserMeCache.json"
    }

    if (!(Test-Path -Path "$path\BaconIpsumComCache.json")) {
        Get-LorumIpsumDocuments | ConvertTo-Json | Out-File -FilePath "$path\BaconIpsumComCache.json"
    }
    
    $randomUsers = Get-Content "$path\RandomUserMeCache.json" | Out-String | ConvertFrom-Json
    $randomDocuments = Get-Content "$path\BaconIpsumComCache.json" | Out-String | ConvertFrom-Json  

    $lists = @()

    $users = @()
    $people = @()
    $addresses = @()
    $accounts = @()
    $phones = @()
    $coordinates = @()
    $emails = @()
    $strings = @()
    $numbers = @()
    $computers = @()

    $counter = 1

    foreach ($randomUser in $randomUsers) {

        [string]$pictureFilename = $randomUser.picture.medium.Substring($randomUser.picture.medium.LastIndexOf("/") + 1)

        if (!(Test-Path -Path "$path\Pictures\$pictureFilename"))
        {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($randomUser.picture.medium, "$path\Pictures\$pictureFilename")
        }

        [int]$randomNumber = Get-Random -Minimum 1 -Maximum 11

        $title = ((Get-Culture).TextInfo).ToTitleCase($randomUser.name.title)
        $firstName = ((Get-Culture).TextInfo).ToTitleCase($randomUser.name.first)
        $lastName = ((Get-Culture).TextInfo).ToTitleCase($randomUser.name.last)
        $address = ((Get-Culture).TextInfo).ToTitleCase($randomUser.location.street)
        $city = ((Get-Culture).TextInfo).ToTitleCase($randomUser.location.city)
        $state = ((Get-Culture).TextInfo).ToTitleCase($randomUser.location.state)

        switch ($randomNumber) {
            1 { 
                if ($users.Length -lt $maximum) {
                    $users += $randomUser
                }
            }
            2 { 
                if ($people.Length -lt $maximum) {
                    $people += [PSCustomObject]@{
                        title    = $title
                        first    = $firstName
                        last     = $lastName
                        gender   = $randomUser.gender
                        email    = $randomUser.email
                        phone    = $randomUser.phone
                        address  = $address
                        city     = $city
                        state    = $state
                        postcode = $randomUser.location.postcode
                        picture  = $pictureFilename
                    }
                }
            }
            3 { 
                if ($addresses.Length -lt $maximum) {
                    $addresses += [PSCustomObject]@{
                        name     = "$firstName $lastName"
                        address  = $address
                        city     = $city
                        state    = $state
                        postcode = $randomUser.location.postcode
                    }
                }
            }
            4 { 
                if ($accounts.Length -lt $maximum) {
                    $accounts += [PSCustomObject]@{
                        first    = $firstName
                        last     = $lastName
                        email    = $randomUser.email
                        username = $randomUser.login.username
                        password = $randomUser.login.password
                        picture  = $pictureFilename
                    }
                }
            }
            5 { 
                if ($phones.Length -lt $maximum) {
                    $phones += $randomUser.phone
                }
            }
            6 { 
                if ($coordinates.Length -lt $maximum) {
                    $coordinate = $randomUser.location.coordinates.Replace("@", "").Replace(";", ",").Replace("=", ":") | Out-String | ConvertFrom-Json -ErrorAction 0
                    $coordinates += [PSCustomObject]@{
                        latitude  = $coordinate.latitude
                        longitude = $coordinate.longitude
                    }
                }
            }
            7 { 
                if ($emails.Length -lt $maximum) {
                    $emails += $randomUser.email
                }
            }
            8 { 
                if ($strings.Length -lt $maximum) {
                    $strings += "$($randomUser.login.md5)"
                }
            }
            9 { 
                if ($numbers.Length -lt $maximum) {
                    $numbers += $counter
                }
            }
            10 { 
                if ($computers.Length -lt $maximum) {
                    if ($computers.Length -lt 3)
                    {
                        $computer = $randomUser.location.city.Substring(0,2).ToUpper()
                    }
                    else {
                        $computer = (Get-RandomItem $computers).Substring(0,2).ToUpper()
                    }

                    $computer += "-"

                    if ((@($computers) -like "$($computer)SRV*").Count -gt 0)
                    {
                        $computer += "WKS"
                    }
                    else {
                        $computer += "SRV"
                    }

                    $computer += "-"
                    $computer += ($counter).ToString().PadLeft(3,'0')

                    $computers += $computer
                }
            }
            Default {}
        }
        $counter++
    }

    $lists += [PSCustomObject]@{
        Users       = $randomUsers
        People      = $people
        Addresses   = $addresses
        Accounts    = $accounts
        Phones      = $phones
        Coordinates = $coordinates
        Emails      = $emails
        Strings     = $strings
        Numbers     = $numbers
        Computers   = $computers
    }

    foreach ($list in $lists) {
        $list.PSObject.Properties | ForEach-Object {
            $_.Value | ConvertTo-Json | Out-File -FilePath "$path\Json\$($_.Name).json" -ErrorAction SilentlyContinue
            if (!($_.Name -eq "Users"))
            {
                $_.Value | ConvertTo-Csv | Out-File -FilePath "$path\Csv\$($_.Name).csv" -ErrorAction SilentlyContinue
                $_.Value | Format-Table | Out-File -FilePath "$path\Text\$($_.Name).txt" -ErrorAction SilentlyContinue

                if ($_.Name -eq "People" -or $_.Name -eq "Accounts")
                {
                    $html = $_.Value | Select-Object *, @{Expression={"<img src='../Pictures/$($_.picture)'>"};Name="Image"} | ConvertTo-Html
                    Add-Type -AssemblyName System.Web
                    [System.Web.HttpUtility]::HtmlDecode($html)| Out-File -FilePath "$path\Html\$($_.Name).html" -ErrorAction SilentlyContinue
                }
                else
                {
                    $_.Value | ConvertTo-Html | Out-File -FilePath "$path\Html\$($_.Name).html" -ErrorAction SilentlyContinue
                }
            }
        }
    }
    
    for ($i = 0; $i -lt $randomDocuments.Count; $i++) {
        $filename = ([string]($i + 1)).PadLeft(2,'0')
        $randomDocuments[$i].content | Format-Table | Out-File -FilePath "$path\Paragraphs\Sample$filename.txt" -ErrorAction SilentlyContinue
    }
}

$path = "$(Split-Path -Path $MyInvocation.MyCommand.Path)"

New-SampleData 100 $path