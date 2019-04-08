<#
.SYNOPSIS
Set Automatic Start Action
.DESCRIPTION
An example of how to use PowerShell to modify the automatic start action of Hyper-V VMs.
.NOTES  
File Name  : SetAutomaticStartAction.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$hosts = "localhost","loopback"

#View the current status of all VMs.
Get-VM -ComputerName $hosts -Name * | Select-Object VMname, AutomaticStartAction, AutomaticStartDelay

#Available options are Start, StartIfRunning, and Nothing

#Get-VM -ComputerName $hosts -Name * | Set-VM –AutomaticStartAction StartIfRunning
#Get-VM -ComputerName $hosts -Name * | Set-VM –AutomaticStartDelay 120

Get-VM -ComputerName $hosts -Name * | Set-VM –AutomaticStartAction Nothing