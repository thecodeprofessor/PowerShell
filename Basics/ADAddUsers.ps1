<#
.SYNOPSIS
Active Directory Add Users
.DESCRIPTION
Several examples showing how to generate an LDF or PS1 file to import new users into Active Directory.
.NOTES  
File Name  : ADAddUsers.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

Write-Host "Welcome to the Active Directory Add Users Script`n`n"

#Write-Host "Would you like to import from a CSV or enter the names manually?`n"
#$type = Read-Host "Enter c for csv, m for manual, or q to quit."

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

function Format-LDF($users) {
    $dnProperties = $("CN", "OU", "DC")

    foreach ($user in $users) {
        $ldf = ""
        $dn = ""

        foreach ($property in $user.PsObject.Properties) {
            foreach ($value in $property.Value) {
                if (($dnProperties -contains $property.Name.Trim())) {
                    $dn += "$($property.Name.Trim())=$($value.Trim()),"
                }
                else {
                    $ldf += "$($property.Name.Trim()): $($value.Trim())`n"
                }
            }
        }

        if (![string]::IsNullOrEmpty($dn)) {
            $ldf = "dn: $($dn.Substring(0,$dn.Length-1))`n" + $ldf
        }
        $output += "$ldf`n"
    }
    return $output.Trim()
}

function Format-PowerShell($users) {
    foreach ($user in $users) {
        $dc = ""
        foreach ($value in $user.DC) {
            $dc += "DC=$($value.Trim()),"
        }
        $output += "New-ADUser -Name `"$($user.name)`" -SamAccountName `"$($user.sAMAccountName)`" -UserPrincipalName `"$($user.sAMAccountName)@$($user.DC.Trim() -join '.')`" -Path `"OU=$($user.OU),$($dc.Substring(0,$dc.Length-1))`" -Enabled $true`n"
    }
    return $output.Trim()
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

function New-RandomUsers($domain, $ou, $accountcontrol = '514', [int]$count = 1) {
    $randomUsers = Get-RandomUsers($count)

    $users = @()

    foreach ($randomUser in $randomUsers) {
        $users += New-User $domain $ou $accountcontrol ((Get-Culture).TextInfo).ToTitleCase("$($randomUser.name.first) $($randomUser.name.last)") $randomUser.login.username
    }

    return $users
}
function New-User($domain, $ou, $accountcontrol = '514', $name, $username) {
    if ($domain -match '.') {
        $domain = $domain.split('.')
    }

    if ($null -eq $username) {
        $username = $name.ToLower()
        $username = $username.Replace('[^a-zA-Z]', '')
        $username = $username -replace " ", "."
    }

    return [PSCustomObject]@{
        CN               = $name
        OU               = $ou
        DC               = $domain
        changetype       = 'add'
        objectClass      = 'user'
        name             = $name
        sAMAccountName   = $username
        dnAccountControl = $accountcontrol
    }
}

function Get-ManualEntry {
    $number = Get-Response @("How many users would you like") PositiveInteger
    $domain = Get-Response @("What is your AD domain name") String 4
    $ou = Get-Response @("Which OU would you like to add the users to") String 4
    $accountcontrol = '514'

    $users = @()

    for ($i = 0; $i -lt ($number); $i++) {
        $name = Get-Response @("What is the $(Convert-IntegerToEnglish ($i+1)) user's full name") String 3

        $users += New-User $domain $ou $accountcontrol $name
    }

    return $users
}

function Convert-IntegerToEnglish([int]$number)
{
    switch ($number) {
        1 { 
            return '1st'
        }
        2 { 
            return '2nd'
        }
        3 { 
            return '3rd'
        }
        Default {
            return "$($number)th"
        }
    }
}
function Get-RandomEntry {
    $number = Get-Response @("How many users would you like") PositiveInteger
    $domain = Get-Response @("What is your AD domain name") String 4
    $ou = Get-Response @("Which OU would you like to add the users to") String 4

    return New-RandomUsers $domain $ou '514' $number
}
function Get-Started {
    $type = Get-Response @("Would you like to import a CSV file, manually enter the names, or generate random names?", "Type i for import, m for manual, r for random, or q to quit.") List @("i", "m", "r", "q")

    $users = @()

    switch ($type) {
        'i' { 
            Write-Host "You write this code... I am too tired. :) Try the other two choices."
            exit;
        }
        'm' { 
            $users = Get-ManualEntry
            break;
        }
        'r' { 
            $users = Get-RandomEntry
            break;
        } 'q' { 
            exit;
        }
    }

    if ($users.length -gt 0)
    {
        $type = Get-Response @("Would you like to use PowerShell or LDF?", "Type p for powershell or l for LDF.") List @("p", "l")

        switch ($type) {
            'p' { 
                    $file = Get-Response @("Where would you like to save the file?", "Type a path / the filename and .ps1 extension") String 5
                    Format-PowerShell $users | Out-File -FilePath $file
                    break;
            }
            'l' { 
                $file = Get-Response @("Where would you like to save the file?", "Type a path / the filename and .ldf extension") String 5
                Format-LDF $users | Out-File -FilePath $file
                break;
            }
        }
    }
    else {
        Write-Host "Sorry, an error occured."
    }
}

Get-Started

<#
$Users = @()

$users = New-RandomUsers '4042.local' 'Test OU' '514' 2 
$Users += New-User '4042.local' 'Test OU' '514' 'Nathan Abourbih' 'nathan.abourbih'

$temp = Format-LDF $users
Write-Host "$($temp)"

$Users = @()
$Users += New-User 'Test OU' 'Nathan Abourbih' '4042.local'
$Users += New-User 'Test OU' 'Bob' '4042.local'
$Users += New-User 'Test OU' 'Joe' '4042.local'
$ldfUser = Format-LDF $Users

    Write-Host "$($ldfUser)"

    Get-RandomUser
#>
#    if ($num -ge 500 -and $num -le 549) {
#$command = "ldifde -i -f newdn.ldf -s BigServer"
