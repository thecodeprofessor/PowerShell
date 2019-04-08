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

#$VMMS = Get-WmiObject -Namespace 'root\virtualization\v2' -Class 'Msvm_VirtualSystemManagementService' -ErrorAction Stop
#$VMObject = Get-WmiObject -Namespace 'root\virtualization\v2' -Class 'Msvm_ComputerSystem' -Filter ('ElementName = "{0}"' -f "New VM") -ErrorAction Stop
#$VMMS

$name = "NewVM2"
$path = "C:\Data\Virtual Machines\Test\"
$memorySize = 4 #Size in GB
$diskSize = 20 #Size in GB
$switchName = "Default Switch"
$physicalNetworkAdapterName = "LAN"
$bootISOpath = "C:\WinPE_amd64\WinPE_amd64.iso"

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

New-VHD -Path (Join-Path -Path $diskPath -ChildPath "$name.vhdx") -SizeBytes ($diskSize * 1GB) 

$vm = New-VM -VMName $name -MemoryStartupBytes ($memorySize * 1GB) -Generation 1 -Path $path -SwitchName $switchName -VHDPath (Join-Path -Path $diskPath -ChildPath "$name.vhdx") -Force

#If using Generation 2:
#Issue with bootfix that is unresolved.
#Add-VMDvdDrive -VMName $name -Path $bootISOpath
#Set-VMFirmware -VMName $name -EnableSecureBoot Off or On
#Set-VMFirmware -VMName $name -BootOrder (Get-VMDvdDrive -VMName $name), (Get-VMHardDiskDrive -VMName $name)

Set-VMBios -VMName $name -StartupOrder @("IDE", "CD", "Floppy", "LegacyNetworkAdapter")
Set-VMProcessor -Count 2
Set-VMMemory -DynamicMemoryEnabled $true -MinimumBytes ($memorySize * 1GB)
Set-VM -AutomaticCheckpointsEnabled $False
Set-VMDvdDrive -VMName $name -Path $bootISOpath

#Start-Sleep -s 2

#Start-VM -Name $name

<#


$ISOServer = Mount-DiskImage -ImagePath $openFile.FileName -PassThru
  $ServerMediaDriveLetter = (Get-Volume -DiskImage $ISOServer).DriveLetter

        WriteInfoHighlighted "Testing if selected ISO is Server Media"
        $WindowsImage=Get-WindowsImage -ImagePath "$($ServerMediaDriveLetter):\sources\install.wim"
        If ($WindowsImage.ImageName[0].contains("Server")){
            WriteInfo "`t Server Edition found"
        }else{
            $ISOServer | Dismount-DiskImage
            WriteErrorAndExit "`t Selected media does not contain Windows Server. Exitting."
        }
        if ($WindowsImage.ImageName[0].contains("Server") -and $windowsimage.count -eq 2){
            WriteInfo "`t Semi-Annual Server Media detected"
            $ISOServer | Dismount-DiskImage
            WriteErrorAndExit "Please provide LTSC media. Exitting."
        }
    #Test if it's Windows Server 2016 and newer
        $BuildNumber=(Get-ItemProperty -Path "$($ServerMediaDriveLetter):\setup.exe").versioninfo.FileBuildPart
        If ($BuildNumber -lt 14393){
            $ISOServer | Dismount-DiskImage
            WriteErrorAndExit "Please provide Windows Server 2016 and newer. Exitting."
        }

 #ask for MSU patches
            WriteInfoHighlighted "Please select Windows Server Updates (*.msu). Click Cancel if you don't want any."
            [reflection.assembly]::loadwithpartialname("System.Windows.Forms")
            $ServerPackages = New-Object System.Windows.Forms.OpenFileDialog -Property @{
                Multiselect = $true;
                Title="Please select Windows Server Updates (*.msu). Click Cancel if you don't want any."
            }
            $ServerPackages.Filter = "msu files (*.msu)|*.msu|All files (*.*)|*.*" 
            If($ServerPackages.ShowDialog() -eq "OK"){
                WriteInfoHighlighted  "Following patches selected:"
                WriteInfo "`t $($ServerPackages.filenames)"
            }

            $serverpackages=$serverpackages.FileNames | Sort-Object
            




   $ISOServer | Dismount-DiskImage

 $unattendfile=CreateUnattendFileVHD -Computername $DCName -AdminPassword $AdminPassword -path "$PSScriptRoot\temp\" -TimeZone $TimeZone
            New-item -type directory -Path $PSScriptRoot\Temp\mountdir -force
            Mount-WindowsImage -Path "$PSScriptRoot\Temp\mountdir" -ImagePath $VHDPath -Index 1
            Use-WindowsUnattend -Path "$PSScriptRoot\Temp\mountdir" -UnattendPath $unattendFile 
            #&"$PSScriptRoot\Temp\dism\dism" /mount-image /imagefile:$vhdpath /index:1 /MountDir:$PSScriptRoot\Temp\mountdir
            #&"$PSScriptRoot\Temp\dism\dism" /image:$PSScriptRoot\Temp\mountdir /Apply-Unattend:$unattendfile
            New-item -type directory -Path "$PSScriptRoot\Temp\mountdir\Windows\Panther" -force
            Copy-Item -Path $unattendfile -Destination "$PSScriptRoot\Temp\mountdir\Windows\Panther\unattend.xml" -force
            Copy-Item -Path "$PSScriptRoot\Temp\DSC\*" -Destination "$PSScriptRoot\Temp\mountdir\Program Files\WindowsPowerShell\Modules\" -Recurse -force

            Dismount-WindowsImage -Path "$PSScriptRoot\Temp\mountdir" -Save
        
            
             Invoke-Command -VMGuid $DC.id -Credential $cred -ScriptBlock {
                    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
                    d:\scvmm\1_SQL_Install.ps1
                    d:\scvmm\2_ADK_Install.ps1  
                    Restart-Computer    
                }
                Start-Sleep 10


                        #create DSC MOF files
            WriteInfoHighlighted "`t Creating DSC Configs for DC"
            LCMConfig       -OutputPath "$PSScriptRoot\Temp\config" -ConfigurationData $ConfigData
            DCHydration     -OutputPath "$PSScriptRoot\Temp\config" -ConfigurationData $ConfigData -safemodeAdministratorCred $cred -domainCred $cred -NewADUserCred $cred
        
        #copy DSC MOF files to DC
            WriteInfoHighlighted "`t Copying DSC configurations (pending.mof and metaconfig.mof)"
            New-item -type directory -Path "$PSScriptRoot\Temp\config" -ErrorAction Ignore
            Copy-Item -path "$PSScriptRoot\Temp\config\dc.mof"      -Destination "$PSScriptRoot\Temp\mountdir\Windows\system32\Configuration\pending.mof"
            Copy-Item -Path "$PSScriptRoot\Temp\config\dc.meta.mof" -Destination "$PSScriptRoot\Temp\mountdir\Windows\system32\Configuration\metaconfig.mof"



                do{
                $test=Invoke-Command -VMGuid $DC.id -Credential $cred -ArgumentList $LabConfig -ErrorAction SilentlyContinue -ScriptBlock {
                    param($LabConfig);
                    Get-ADComputer -Filter * -SearchBase "$($LabConfig.DN)" -ErrorAction SilentlyContinue}
                    Start-Sleep 5
                }until ($test -ne $Null)

#>