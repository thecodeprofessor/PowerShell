<#
.SYNOPSIS
Active Directory Add a New Domain Forest - DC1 - Step 2
.DESCRIPTION
An example of how to deploy a new domain forest.
.NOTES  
File Name  : ADDeployment_DC1_Step2.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

#Important note, the username and password are stored here for this example. It is not appropriate to store your credentials in plain text for a production environment.
$username = 'anecdote.local\Administrator'
$password = 'Pa$$w0rd' | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

Import-Module ADDSDeployment

Install-ADDSForest -CreateDnsDelegation: $false -DatabasePath 'C:\Windows\NTDS' -DomainMode 'Win2012' -DomainName 'anecdote.local' -DomainNetbiosName 'anecdote' -ForestMode 'Win2012' -InstallDns -LogPath "C:\Windows\NTDS" -SysvolPath 'C:\Windows\SYSVOL' -SafeModeAdministratorPassword $password -Force

Restart-Computer
