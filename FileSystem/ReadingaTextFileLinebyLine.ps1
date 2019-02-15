<#
.SYNOPSIS
Reading a Text File Line by Line
.DESCRIPTION
An example of reading a text file 1 line at a time.
.NOTES  
File Name  : ReadingaTextFileLinebyLine.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$file = "$(Split-Path -Path $MyInvocation.MyCommand.Path)\ReadingaTextFileLinebyLine_Sample1.txt"
$items = @()
$regex = "^(?!\s*$).+" #Match any string that contains at least one non-space character.

#Store the entire text file, one line at a time in the array $items.
foreach($line in Get-Content $file) {
    if($line -match $regex){
        $items += $line
    }
}

#Iterate through the $items and display them one at a time.
foreach ($item in $items)
{
    Write-Host "$item"
}