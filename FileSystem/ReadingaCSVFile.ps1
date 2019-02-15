<#
.SYNOPSIS
Reading a CSV File
.DESCRIPTION
An example of reading a text file 1 line at a time.
.NOTES  
File Name  : ReadingaCSVFile.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$file = "$(Split-Path -Path $MyInvocation.MyCommand.Path)\ReadingaCSVFile_Sample1.csv"

$people = Import-Csv -Path $file

#Iterate through the $people and display them one at a time.
foreach ($person in $people)
{
    Write-Host "$($person.FirstName) $($person.LastName) is $($person.Age) Years Old."
}