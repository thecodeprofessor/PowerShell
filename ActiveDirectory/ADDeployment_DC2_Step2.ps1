<#
.SYNOPSIS
Active Directory Add a New Domain Forest - DC1 - Step 1
.DESCRIPTION
An example of how to deploy a new domain forest.
.NOTES  
File Name  : ADDeployment_DC2_Step2.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

#Important note, the username and password are stored here for this example. It is not appropriate to store your credentials in plain text for a production environment.
$username = 'anecdote.local\Administrator'
$password = 'Pa$$w0rd' | ConvertTo-SecureString -asPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

Import-Module ADDSDeployment

Install-ADDSDomainController -DatabasePath 'C:\Windows\NTDS' -DomainName 'anecdote.local' -Credential $credential -LogPath 'C:\Windows\NTDS' -ReplicationSourceDC 'dc1.anecdote.local' -SysvolPath 'C:\Windows\SYSVOL' -SafeModeAdministratorPassword $password -Force

Restart-Computer