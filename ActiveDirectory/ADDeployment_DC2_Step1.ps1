<#
.SYNOPSIS
Active Directory Add a New Domain Forest - DC2 - Step 1
.DESCRIPTION
An example of how to deploy a new domain forest.
.NOTES  
File Name  : ADDeployment_DC2_Step1.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

New-Item -Path 'C:\Logs' -ItemType Directory

Get-NetAdapter | Get-NetIPAddress | Remove-NetIPAddress
Get-NetAdapter | Remove-NetRoute
Get-NetAdapter | New-NetIPAddress -IPAddress '192.168.100.6' -PrefixLength '24' -DefaultGateway '192.168.100.1'
Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses ('192.168.100.5')

Rename-Computer -NewName 'dc2' -force

Add-WindowsFeature -Name "AD-Domain-Services" -IncludeAllSubFeature -IncludeManagementTools  -LogPath 'C:\Logs\ad-domain-services.txt'
Add-WindowsFeature -Name "DNS" -IncludeAllSubFeature -IncludeManagementTools -LogPath 'C:\Logs\dns.txt'
Add-WindowsFeature -Name "gpmc" -IncludeAllSubFeature -IncludeManagementTools -LogPath 'C:\Logs\gpmc.txt'
Add-WindowsFeature -Name 'RSAT-AD-Tools' -LogPath 'C:\Logs\RSAT-AD-Tools.txt'

Restart-Computer
