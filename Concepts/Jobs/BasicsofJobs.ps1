<#
.SYNOPSIS
Basics of Jobs
.DESCRIPTION
Several examples showing the basics of jobs and how to use them to run one or more commands in the background.
.NOTES  
File Name  : BasicssofJobs.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

#Uncomment each line below and execute it one line at a time.

#Step 1: Start the job.

Start-Job -ScriptBlock {Get-Process}

#Notice that the job is created and assigned a name. Jobs are named Job1, Job2, and so on.


#Step 2: Get the job.
#Getting the job allows you to see its status.
#Make sure to change Job1 to the name of the job shown after step 1.

#Get-Job -Name Job1


#Step 3: Receive the job.
#When you see the State change to Completed, you can receive the job to get the output.
#Make sure to change Job1 to the name of the job shown after step 1.
#You can only receive the job once because it clears the job and its output.

#Receive-Job Job1


#Step 4: 
#Try that again but instead of running Receive-Job alone, store the result of Receive-Job
#into a variable and then inspect the contents of that variable.
#You can use this technique to store the output for a longer period of time.

#$jobResult = Receive-Job Job3
#$jobResult

#Did the name of the job change? Make sure to use the proper job name.

#Notes:
#Wildcard Characters:
#You can also use wildcard characters to with the commands above. Example: job*

#Storing the result of a job in a variable:
#The result is deserialized and you can see this by running the command #jobResult | Get-Member.
#This means that it is not the original command and not all of the standard members are available.
#Think of it as the basic results from running that command.




