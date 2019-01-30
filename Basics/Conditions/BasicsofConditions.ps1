<#
.SYNOPSIS
  Basics of Conditions
.DESCRIPTION
  Several examples showing the basics of conditional statements and how to use them.
.NOTES  
File Name  : BasicssofVariables.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

# =======================================================
#   If
# =======================================================

<#
$number = 5

if ($number -lt 10)
{
  Write-Host "`$number was less than 10."
}

if ($number -gt 30)
{
  Write-Hosst "`$number was greater than 30."
}
#>

# =======================================================
#   If Else
# =======================================================

$number = 0 #8, 15, 35

if ($number -lt 10)
{
  Write-Host "`$number was less than 10."
} elseif ($number -gt 30)
{
  Write-Host "`$number was greater than 30."
}
else {
  Write-Host "`$number was not less than 10 and not greater than 30."
}