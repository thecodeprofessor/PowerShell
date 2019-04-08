#Requires -RunAsAdministrator

<#
.SYNOPSIS
New VM
.DESCRIPTION
An example of how to use PowerShell to deploy a new Windows 10 VM.
.NOTES  
File Name  : NewVM.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>


$name = "NewVM"
$path = "C:\Data\Virtual Machines\"
$memorySize = 8 #Size in GB
$switchName = "Default Switch"
$physicalNetworkAdapterName = "LAN"
$vhdPath = "C:\Data\Virtual Machines\BaseImages\Server 2019 Base Image\Virtual Hard Disks\Server 2019 Base Image.vhdx"

$vmPath = (Join-Path -Path $path -ChildPath "\$name\")
$diskPath = (Join-Path -Path $vmPath -ChildPath "\Virtual Hard Disks\")

#Find network adapters in case an external switch needs to be created -notmatch "virtual" 
$networkAdapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.NdisPhysicalMedium -eq 14 -and $_.Name -match $physicalNetworkAdapterName}

if (!$networkAdapter) {
    Write-Host "Could not locate a physical network adapter."
    exit
}

while ($null -ne $networkAdapter -and $networkAdapter.Length -gt 1) {
    Write-Host "Found multiple network adapters, please choose one:"
    $counter = 1
    foreach ($netAdapter in $networkAdapter) {
        Write-Host "`t $counter) $($netAdapter.Name) - $($netAdapter.InterfaceDescription)"
        $counter++;
    }
    [int]$selection = Read-Host "Please type the number of the adapter you would like to use"
    $selectedNetworkAdapter = $networkAdapter[($selection - 1)]
    if ($null -ne $selectedNetworkAdapter) {
        $networkAdapter = $selectedNetworkAdapter
    }
}

#Find existing VM and delete it if it exists.
$vm = Get-VM -Name $name -ErrorAction SilentlyContinue
if ($vm) {
    $vmDisk = get-vhd -id $vm.id
    while ($vm -and $vm.State -eq 'Running') {
        Stop-VM -Name $name -TurnOff -ErrorAction SilentlyContinue
        Start-Sleep -s 1
    }
    Remove-VM -Name $name -Force -ErrorAction SilentlyContinue
    Remove-Item $vmDisk.Path -Force -ErrorAction SilentlyContinue
}

Remove-Item -Recurse -Force $vmPath -ErrorAction SilentlyContinue
mkdir $diskPath -ErrorAction SilentlyContinue

#Find or create the switch. If external is selected, make sure its name is set to "External" and rename it if needed.
$vmSwitch = $null
if ($switchName -eq "External") {
    $vmSwitch = Get-VMSwitch -SwitchType External -ErrorAction SilentlyContinue
    if (!$vmSwitch) {
        $vmSwitch = New-VMSwitch -Name External -NetAdapterName $networkAdapter.Name -ErrorAction Stop
    }
    elseif ($vmSwitch.Name -ne $switchName) {
        $vmSwitch.Name = $switchName
    }
}
else {
    $vmSwitch = Get-VMSwitch -Name $switchName
    if (!$vmSwitch) {
        $vmSwitch = New-VMSwitch -Name $switchName -SwitchType Internal -ErrorAction Stop
    }
}

Copy-Item $vhdPath -Destination (Join-Path -Path $diskPath -ChildPath "$name.vhdx")

$vm = New-VM -VMName $name -MemoryStartupBytes ($memorySize * 1GB) -Generation 1 -Path $path -SwitchName $switchName -VHDPath (Join-Path -Path $diskPath -ChildPath "$name.vhdx") -Force

Set-VMBios -VMName $name -StartupOrder @("IDE", "CD", "Floppy", "LegacyNetworkAdapter")
Set-VMProcessor -Count 4
Set-VMMemory -DynamicMemoryEnabled $true -MinimumBytes ($memorySize * 2GB)
Set-VM -AutomaticCheckpointsEnabled $False
