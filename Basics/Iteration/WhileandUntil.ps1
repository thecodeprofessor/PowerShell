<#
.SYNOPSIS
Loops and Iteration Using While and Until
.DESCRIPTION
Several examples showing the basics of loops using while and until.
.NOTES  
File Name  : LoopsandIteration.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>


Write-Host "`nWhile: This will run a statement zero or more times." -ForegroundColor Green
$counter = 0 #Try changing the counter.
While ($counter -lt 3) #try changing the condition.
{  
    Write-Host "`$counter equals $counter" #Try removing the backtick character.
    $counter++
}


Write-Host "`nDo While: This will run a statement one or more times." -ForegroundColor Yellow
$counter = 0 #Try changing the counter.
do
{  
    Write-Host "`$counter equals $counter" #Try changing this sentence.
    $counter++
} While ($counter -lt 3) #try changing the condition. Notice that the condition is at the end.


Write-Host "`nDo Until: Runs a statement one or more times until something not while something." -ForegroundColor Blue
$counter = 0
do
{
    Write-Host "`$counter equals $counter"
    $counter++
} Until($counter -gt 3) #Notice the use of gt instead of lt. Try ge (greater than or equal)


#While vs Do While vs Do Until...
#Try setting counter to start at 5 for all three and compare the output of each.


