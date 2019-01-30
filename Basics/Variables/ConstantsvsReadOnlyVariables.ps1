<#
.SYNOPSIS
Constants vs ReadOnly Variables
.DESCRIPTION
Several examples the difference between constants and read only variables.
.NOTES  
File Name  : ConstantsvsReadOnlyVariables.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

#Try uncommenting and running each line one at a time in order. Notice what happens.

#New-Variable -Name 'readOnlyVariable' -Value 'You can only change this if you use the force.' -Option ReadOnly
#New-Variable -Name 'constantVariable' -Value 'You can not change this.' -Option Constant

#Write-Host $readOnlyVariable
#Write-Host $constantVariable

#Set-Variable -Name 'readOnlyVariable'  -Value 'Can I change it?'
#Set-Variable -Name 'constantVariable' -Value 'Can I change this one?'

#Write-Host $readOnlyVariable
#Write-Host $constantVariable

#Set-Variable -Name 'readOnlyVariable'  -Value 'I can change it if I force it.' -Force
#Set-Variable -Name 'constantVariable' -Value 'I could not change it.' -Force

#Write-Host $readOnlyVariable
#Write-Host $constantVariable