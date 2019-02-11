<#
.SYNOPSIS
Waiting for a Job to Complete
.DESCRIPTION
An example of how to start a background job that takes a while and then wait for it to complete.
.NOTES  
File Name  : WaitingforaJobToComplete.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

#Step 1: Create a script block to run.
$longJobScriptBlock = {
    Start-Sleep -s 10 #We use this command to simulate a command that takes a while to run. Wait for 10 seconds.
    Get-ChildItem C:\
}

#Step 2: Start the job and store it in a variable.
$longJob = Start-Job -Name "LongJob" -ScriptBlock $longJobScriptBlock  #Store the script block in a variable instead of writing it in-line.

#Step 3: Run a loop every second and check if the job is complete.
do
{
    Write-Host "`n [$(Get-Date -Format 'hh:mm:ss tt')] Long Job State is... $($longJob.State)" -ForegroundColor Blue
    Start-Sleep -s 1

} while ($longJob.State -ne "Completed")

Write-Host "`n Long job state is completed!" -ForegroundColor Green


#Step 4: Capture the result of the job to a new variable.
$longJobResult = Receive-Job -Name "LongJob"


Write-Host "`n Press enter to see the result of our long job.`n " -ForegroundColor Yellow
pause
$longJobResult