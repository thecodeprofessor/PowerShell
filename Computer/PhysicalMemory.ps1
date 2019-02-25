<#
.SYNOPSIS
Physical Memory
.DESCRIPTION
Examples of how to work with physical memory on a computer using WMI / CIM.
.NOTES  
File Name  : PhysicalMemory.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$computer = "localhost"

#Example 1
#A one line example of how to get the total amount of physical memory on a computer.
#This example uses the Win32_PhysicalMemory WMI class to get details for each bank of memory and
#then uses Measure-Object to calculate the sum of the capacities for each bank of memory inside the computer.

Write-Host "Example 1: " -ForegroundColor Green

$example1 = (Get-WMIObject -class "Win32_PhysicalMemory" -namespace "root\CIMV2" -ComputerName $computer | Measure-Object -Property capacity -Sum | % {[Math]::Round(($_.sum / 1GB),2)})

Write-Host "`t$example1 GB`n" -ForegroundColor Blue


#Example 2
#In most computers, a bank of memory is a single stick of memory.
#This example will use a foreach to show the capacity of each stick of memory inside a computer.

Write-Host "Example 2:" -ForegroundColor Green

$memoryBanks = Get-WMIObject -class "Win32_PhysicalMemory" -namespace "root\CIMV2" -ComputerName $computer

Write-Host "`tComputer $computer has $($memoryBanks.Count) sticks of memory in the following configuration:" -ForegroundColor Blue

$totalCapacity = 0
foreach ($memoryBank in $memoryBanks)
{
    $slot = $memoryBank.BankLabel
    $manufacturer = $memoryBank.Manufacturer
    $capacity = $memoryBank.Capacity
    $capacityGB = [Math]::Round(($capacity / 1GB),2)

    $totalCapacity += $capacity
    
    Write-Host "`t`t$slot [Manufacturer: $manufacturer] : $capacityGB GB" -ForegroundColor Yellow
}

$totalCapacityGB = [Math]::Round(($totalCapacity / 1GB),2)

Write-Host "`t`tTotal: $totalCapacityGB GB" -ForegroundColor Red