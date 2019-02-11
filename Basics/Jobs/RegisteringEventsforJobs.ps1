<#
.SYNOPSIS
Registering Events for Jobs
.DESCRIPTION
An example of how to register an event for a job state change.
.NOTES  
File Name  : RegisteringEventsforJobs.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

#Step 1: Create a script block to run.
$longJobScriptBlock = {
    Start-Sleep -s 10 #We use this command to simulate a command that takes a while to run. Wait for 10 seconds.
    Get-ChildItem C:\
}

#Step 2: Start the job and store it in a variable.
$longJob = Start-Job -Name "LongJob" -ScriptBlock $longJobScriptBlock  #Store the script block in a variable instead of writing it in-line.

#Step 3: Create a function that should be called when your job completed.
function Get-LongJobCompleted{

    Write-Host "`n Long job state is completed!" -ForegroundColor Green

    #Step 4: Capture the result of the job to a new variable.
    $longJobResult = Receive-Job -Name "LongJob"
    
    
    Write-Host "`n Press enter to see the result of our long job.`n " -ForegroundColor Yellow
    pause
    $longJobResult
}

#Step 4: Start the job.
$longJobEvent = Register-ObjectEvent $longJob StateChanged -Action {Get-LongJobCompleted}

