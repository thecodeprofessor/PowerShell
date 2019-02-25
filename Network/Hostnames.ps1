<#
.SYNOPSIS
Hostnames
.DESCRIPTION
Examples of how to work with hostnames using DNS / WMI / CIM.
.NOTES  
File Name  : Hostnames.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

#Example 1:
#Get the hostname of the current computer using an environment variable.
Write-Host "Example 1: " -ForegroundColor Green

Write-Host "`tThe hostname of this computer is: $env:computername" -ForegroundColor Blue


#Example 2:
#Use DNS to do a reverse lookup on an IP address.
Write-Host "Example 2: " -ForegroundColor Green

$hostByIPAddress = ([system.net.dns]::GetHostByAddress("127.0.0.1")).hostname
Write-Host "`tHost from IP address: $hostByIPAddress" -ForegroundColor Blue


#Example 3:
#Use WMI to get the hostname of a remote computer and use DNS to get the IP address of that remote computer.
Write-Host "Example 3: " -ForegroundColor Green

$computer = "localhost"

$computerInformation = Get-WMIObject -class "Win32_Computersystem" -namespace "root\CIMV2" -ComputerName $computer
Write-Host "`tComputer Name Using WMI: $($computerInformation.Name)" -ForegroundColor Blue

$ipAddress = [System.Net.Dns]::GetHostAddresses($computerInformation.Name) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -Expand IPAddressToString
Write-Host "`tIP Address Using DNS and Hostname: $ipAddress" -ForegroundColor Blue