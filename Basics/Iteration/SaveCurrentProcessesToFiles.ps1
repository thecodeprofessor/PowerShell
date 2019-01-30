<#
.SYNOPSIS
Save a List of Current Processes To Files
.DESCRIPTION
An example of how to use a foreach loop to list the processes on various computers and save the results to a text file.
.NOTES  
File Name  : SaveCurrentProcessesToFiles.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$computers = "localhost", "loopback", "127.0.0.1"

foreach ($computer in $computers) {
    $newFile = "C:\users\user\" + $computer + "_Processes.txt"
    Write-Host "Testing" $computer "please wait ...";
    Get-WmiObject -computername $computer -class win32_process |
        Select-Object name, processID, Priority, ThreadCount 
    Where-Object {!$_.processID -eq 0} | Sort-Object -property name | 
        Format-Table | Out-File $newFile
}