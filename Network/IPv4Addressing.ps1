<#
.SYNOPSIS
IPv4 Addressing
.DESCRIPTION
Several functions that can be used with IPv4.
.NOTES  
File Name  : IPv4Addressing.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$addressValidator = "\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\z"

function Convert-IPv4Touint32([string]$address) {
    if ($address -match $addressValidator) {
        $shift = 24
        foreach ($octet in [uint32[]]$address.Split(".")) {
            
            $uAddress += $octet -shl $shift
            $shift -= 8
        }

        return [uint32]$uAddress
    }
}

function Convert-uint32ToBinary([uint32]$int) {
    return [Convert]::ToString([uint32]$int, 2).PadLeft(32, '0')
}

function Convert-IPv4ToBinary([string]$address) {
    Convert-uint32ToBinary (Convert-IPv4Touint32 $address)
}

function Convert-BinaryToIPv4([string]$binary) {
    if ([string]$binary.length -eq 32) {
        $address = @()
        foreach ($octet in $binary -split '(\w{8})' | Where-Object {$_}) {
            $address += [convert]::ToInt32($octet, 2)
        }

        return [string]::Join(".", $address)
    }
}

function Convert-CIDRToBinary([int]$cidr) {
    if ($cidr -ge 0 -and $cidr -le 32) {
        return "".PadLeft(32 - $cidr, '0').PadLeft(32, '1')
    }
}

function Convert-CIDRToIPv4([int]$cidr) {
    if ($cidr -ge 0 -and $cidr -le 32) {
        return Convert-BinaryToIPv4 (Convert-CIDRToBinary $cidr)
    }
}

function Get-Subnet([string]$address, [int]$cidr) {
    if ($address -match $addressValidator -and $cidr -ge 0 -and $cidr -le 32) {
        [string]$mask = Convert-CIDRToIPv4 $cidr
        [uint32]$addressuInt32 = Convert-IPv4Touint32 $address
        [uint32]$maskuInt32 = Convert-IPv4Touint32 $mask
        [uint32]$networkuInt32 = $addressuInt32 -band $maskuInt32
        [uint32]$wildcarduInt32 = -bnot $maskuInt32 -shl 32 - $wildcarduInt32.length
        [uint32]$broadcastuInt32 = $networkuInt32 -bxor $wildcarduInt32 
        [uint32]$firstHostuInt32 = $networkuInt32 + 1
        [uint32]$lastHostuInt32 = $broadcastuInt32 - 1

        return [PSCustomObject]@{
            Address            = $address
            CIDR               = $cidr
            Mask               = $mask
            Broadcast          = Convert-BinaryToIPv4 (Convert-uint32ToBinary $broadcastuInt32)
            Network            = Convert-BinaryToIPv4 (Convert-uint32ToBinary $networkuInt32)
            Wildcard           = Convert-BinaryToIPv4 (Convert-uint32ToBinary $wildcarduInt32)
            FirstHost          = Convert-BinaryToIPv4 (Convert-uint32ToBinary $firstHostuInt32)
            LastHost           = Convert-BinaryToIPv4 (Convert-uint32ToBinary $lastHostuInt32)
        }
    }
}

function Get-LocalSubnets
{
    $subnets = @()
    foreach ($address in (Get-NetIPAddress -AddressFamily "IPv4")) {
        $subnets += Get-Subnet $address.IPAddress $address.PrefixLength
    }
    
    return $subnets
}

#An example of how to get the details about all subnets currently connected to the local computer.
#Get-LocalSubnets | Format-Table
