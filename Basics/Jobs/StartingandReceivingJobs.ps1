<#
.SYNOPSIS
Starting and Receiving Jobs
.DESCRIPTION
Several examples showing how to start and receive jobs to run one or more commands in the background.
.NOTES  
File Name  : StartingandReceivingJobs.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

#Step 1: Create a script block to run.
$importantJobScriptBlock = {Get-ChildItem C:\}

#Step 2: Start the job.
$importantJob = Start-Job -Name "ImportantJob" -ScriptBlock $importantJobScriptBlock  #Store the script block in a variable instead of writing it in-line.

#Step 3: Try getting the job and outputting the variable that stores it.
Write-Host "`n Example of Get-job Command:" -ForegroundColor Green
Get-Job -Name "ImportantJob"

Write-Host "`n Contents of the `$importantJob variable:" -ForegroundColor Blue
$importantJob #Notice the similarities and differences between this output and the get-Job output.


#Step 4: Capture the result of the job to a new variable.
$importantJobResult = Receive-Job -Name "ImportantJob"

Write-Host "`n Contents of the `$importantJob variable:" -ForegroundColor Yellow
$importantJobResult #Notice that the variable contains the results of running Get-ChildItem.