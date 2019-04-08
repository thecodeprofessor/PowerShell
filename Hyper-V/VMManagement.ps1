#1Requires -RunAsAdministrator

<#
.SYNOPSIS
New VM
.DESCRIPTION
An examples of how to use PowerShell to Manage Hyper-V.
.NOTES  
File Name  : VMManagement.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

#$VMMS = Get-WmiObject -Namespace 'root\virtualization\v2' -Class 'Msvm_VirtualSystemManagementService' -ErrorAction Stop
#$VMObject = Get-WmiObject -Namespace 'root\virtualization\v2' -Class 'Msvm_ComputerSystem' -Filter ('ElementName = "{0}"' -f "New VM") -ErrorAction Stop
#$VMMS


#$name = "NewVM2"
#$path = "C:\Data\Virtual Machines\Test\"
#$memorySize = 4 #Size in GB
#$diskSize = 20 #Size in GB
#$switchName = "Default Switch"
#$physicalNetworkAdapterName = "LAN"
#$bootISOpath = "C:\WinPE_amd64\WinPE_amd64.iso"

#$vmPath = (Join-Path -Path $path -ChildPath "\$name\")
#$diskPath = (Join-Path -Path $vmPath -ChildPath "\Virtual Hard Disks\")

#Find network adapters in case an external switch needs to be created -notmatch "virtual" 

function Get-NetworkAdapter ([string]$name) {
    $networkAdapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.NdisPhysicalMedium -eq 14 -and $_.Name -match $name}

    if (!$networkAdapter) {
        Write-Host "Could not locate a physical network adapter."
        $networkAdapter = $null
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

    return $networkAdapter
}

function Stop-VirtualMachine ([string]$name) {
    $vm = Get-VM -Name $name -ErrorAction SilentlyContinue
    if ($vm) {
        $vmStateCounter = 0
        while (($vm -and $vm.State -eq 'Running') -and $vmStateCounter -lt 30) {
            Stop-VM -Name $name -TurnOff -ErrorAction SilentlyContinue | Out-Null
            Start-Sleep -Milliseconds 500
            $vmStateCounter++
        }
    }
}
function Remove-VirtualMachine ([string]$name, [bool]$removeDisk) {
    #Find existing VM and delete it if it exists.

    $vm = Get-VM -Name $name -ErrorAction SilentlyContinue
    if ($vm) {
        Stop-VirtualMachine -Name $name

        $vmDisk = get-vhd -id $vm.id

        Remove-VM -Name $name -Force -ErrorAction SilentlyContinue

        if (!$vmDisk -and $removeDisk) {
            Remove-Item $vmDisk.Path -Force -ErrorAction SilentlyContinue
        }
    }
}

function Get-VirtualSwitch ([string]$name, [string]$networkAdapterName) {
    #Find or create the switch. If external is selected, make sure its name is set to "External" and rename it if needed.

    $vmSwitch = $null
    if ($name -eq "External") {
        $vmSwitch = Get-VMSwitch -SwitchType External -ErrorAction 0
        if (!$vmSwitch) {
            $vmSwitch = New-VMSwitch -Name External -NetAdapterName $networkAdapterName -ErrorAction SilentlyContinue
        }
        elseif ($vmSwitch.Name -ne $name) {
            $vmSwitch.Name = $name
        }
    }
    else {
        $vmSwitch = Get-VMSwitch -Name $name -ErrorAction 0
        if (!$vmSwitch) {
            $vmSwitch = New-VMSwitch -Name $name -SwitchType Internal -ErrorAction SilentlyContinue
        }
    }

    return $vmSwitch
}

function Add-VirtualMachine($name, $generation, $memory, $minimumMemory, $path, $switchName, $nicName, $disk, $checkpoints, $dynamicMemory, $processors, $virtualization) {
    $vm = Get-VM -Name $name -ErrorAction SilentlyContinue
    if (!$vm) {
        if ($generation -eq 2) {
            $vm = New-VM -VMName $name -MemoryStartupBytes $memory -Generation $generation -Path $path -SwitchName $switchName -Force
            #$vm | Set-VM –AutomaticStartAction Nothing
            $vm | Set-VMFirmware -EnableSecureBoot Off
            $vm | Set-VMFirmware -BootOrder (Get-VMHardDiskDrive -VMName $name)
            $vm | Set-VMMemory -DynamicMemoryEnabled $dynamicMemory -MinimumBytes $minimumMemory
            $vm | Set-VM -AutomaticCheckpointsEnabled $checkpoints
            $vm | Set-VM -AutomaticStopAction Shutdown
            $vm | Set-VMProcessor -Count $processors -ExposeVirtualizationExtensions $virtualization

            #Remove auto-generated network adapters.
            $vm | Get-VMNetworkAdapter | Remove-VMNetworkAdapter
        }
    }

    return $vm
}

function Add-VirtualMachineNetworkAdapter($vmName, $networkAdapterName, $switchName) {
    $vm = Get-VM -Name $vmName
    
    Stop-VirtualMachine -Name $vm.Name

    $vm | Add-VMNetworkAdapter -SwitchName $switchName -Name $networkAdapterName -DeviceNaming On

    #Briefly start the VM and then stop it so that we can lock the MAC address into the NIC.
    $vm | Start-VM -ErrorAction 0 | Out-Null
    
    $macAddressCounter = 0
    do
    {
        $vmMACAddress = $vm | Get-VMNetworkAdapter -Name $networkAdapterName | Select-Object MacAddress -ExpandProperty MacAddress
        Start-Sleep -Milliseconds 500
        $macAddressCounter++
    } while (!$vmMACAddress -and $macAddressCounter -lt 30)
    
    Stop-VirtualMachine -Name $vm.Name

    

    $vmMACAddress = ($vmMACAddress -replace '(..)', '$1-').trim('-')

    $vm | Get-VMNetworkAdapter -Name $networkAdapterName | Set-VMNetworkAdapter -StaticMacAddress $vmMACAddress

    return $vmMACAddress
}

function Remove-VirtualMachineNetworkAdapter($vmName, $networkAdapterName) {
    $vm = Get-VM -Name $vmName

    $vm | Get-VMNetworkAdapter | Where-Object Name -match $networkAdapterName | Remove-VMNetworkAdapter
}

function Add-VirtualMachineDisk($vmName, $diskPath, $setBootDevice) {
    Add-VMHardDiskDrive -VMName $vmName -ControllerType SCSI -Path $diskPath

    if ($setBootDevice) {
        $vmDisk = Get-VMHardDiskDrive -VMName $vmName | Where-Object {$_.Path -eq "$diskPath"}
        Get-VMFirmware -VMName $vmName | Set-VMFirmware -FirstBootDevice $vmDisk
    }
}

function Remove-VirtualMachineDisk($vmName, $networkAdapterName) {
    $vm = Get-VM -Name $vmName

    $vm | Get-VMNetworkAdapter | Where-Object Name -match $networkAdapterName | Remove-VMNetworkAdapter
}

function Mount-VirtualMachineDisk($disk) {
    [string]$vhdDriveLetter = $null

    $vhdDriveLetter = (Get-VHD -Path $disk | Get-Disk  -ErrorAction 0 | Get-Partition  -ErrorAction 0 | Get-Volume  -ErrorAction 0 | Where-Object {$_.FileSystemLabel -like ""}).DriveLetter

    $vhdDriveLetterCounter = 0
    if (!$vhdDriveLetter) {
        $vhdDisk = Mount-VHD -Path $disk -PassThru -ErrorAction 0
        do
        {
            Start-Sleep -Milliseconds 500
            $vhdDriveLetter = ($vhdDisk | Get-Disk  -ErrorAction 0 | Get-Partition  -ErrorAction 0 | Get-Volume  -ErrorAction 0 | Where-Object {$_.FileSystemLabel -like ""}).DriveLetter

            $vhdDriveLetterCounter++
        } while (!$vhdDriveLetter -and $vhdDriveLetterCounter -lt 30)

        if (!$vhdDriveLetter) {
            Dismount-VHD $disk -ErrorAction 0
            $vhdDriveLetter = $null
        }
    }
    return $vhdDriveLetter.Trim()
}

function Dismount-VirtualMachineDisk($disk) {
    Dismount-VHD $disk -ErrorAction 0
}

function New-VMDeployment() {
    $vmName = "Test"
    $diskImage = "C:\Data\Virtual Machines\Virtual Hard Disks\Test.vhdx"
    $virtualSwitchName = "External"
    $unattendPath = "C:\Data\Virtual Machines\Server 2019 Core Unattend.xml"

    Write-Host "Starting VM Deployment of $vmName..." -ForegroundColor Green

    $networkAdapterName = Get-NetworkAdapter "" | Select-Object -ExpandProperty Name
    $virtualSwitch = Get-VirtualSwitch $virtualSwitchName $networkAdapterName

    if (Get-VM -Name $vmName)
    {
        Write-Host "Removing Existing VM..."
        Remove-VirtualMachine -Name $vmName -RemoveDisk $false
    }

    Write-Host "Adding VM..."
    $vm = Add-VirtualMachine -Name $vmName -Generation 2 -Memory 2GB -MinimumMemory 512MB -Path "C:\Data\Virtual Machines\" -SwitchName $virtualSwitch.Name -NICName "Primary" -Disk $diskImage -Checkpoints $false -DynamicMemory $true -Processors 2 -Virtualization $true

    Write-Host "Adding Network Adapter..."
    $macAddress = Add-VirtualMachineNetworkAdapter -VMName $vmName -networkAdapterName "Primary" -switchName $virtualSwitchName

    Write-Host "Applying Unattend.xml..."
    $driveLetter = Mount-VirtualMachineDisk($diskImage)

    $localUsername = "Administrator"
    $localPassword = "Passw0rd!"
    $vmOrganization = "Test Organization"
    $Name = "TestName"
    $ProductID = ""
    $IPDomain = "192.168.0.1"
    $DefaultGW = "192.168.0.254"
    $DNSServer = "192.168.0.1"
    $DNSDomain = "test.com"
    $ComputerName = "compnamehere"

    $passwordSecure = ConvertTo-SecureString "Passw0rd!" -AsPlainText -Force
    $localCredentials = New-Object System.Management.Automation.PSCredential ($localUsername, $passwordSecure )

    Copy-item $unattendPath -Destination  "$driveLetter`:\unattend.xml" -Force

    $originalUnattendXML = Get-Content "$driveLetter`:\unattend.xml"

    $newUnattendXML  = $originalUnattendXML | Foreach-Object {
        $_ -replace '1AdminAccount', $localUsername `
            -replace '1Organization', $vmOrganization `
            -replace '1Name', $Name `
            -replace '1ProductID', $ProductID`
            -replace '1MacAddressDomain', $macAddress `
            -replace '1DefaultGW', $DefaultGW `
            -replace '1DNSServer', $DNSServer `
            -replace '1DNSDomain', $DNSDomain `
            -replace '1AdminPassword', $localPassword `
            -replace '1IPDomain', $IPDomain `
            -replace '1ComputerName', $ComputerName `
    }
    
    $newUnattendXML | Set-Content "$driveLetter`:\unattend.xml"

    Dismount-VirtualMachineDisk($diskImage)

    Write-Host "Adding Disk..."
    Add-VirtualMachineDisk -vmName $vmName -diskPath $diskImage -setBootDevice $true

    Write-Host "Starting VM..." -ForegroundColor Green
    $vm | Start-VM
    Start-Sleep -Seconds 30

    $vmSessionCounter = 0
    do 
    {
        Write-Host "Connecting to WinRM..."
        $vmSession = New-PSSession -VMName $vmName -Credential $localCredentials -ErrorAction 0
        Start-Sleep -Seconds 5
        $vmSessionCounter++
    } while (!$vmSession -and $vmSessionCounter -lt 30)

    Write-Host "Connected to WinRM..." -ForegroundColor Green
    Enter-PSSession $vmSession
}

New-VMDeployment

<#
$password = ConvertTo-SecureString "Passw0rd!" -AsPlainText -Force
$cred= New-Object System.Management.Automation.PSCredential ("Administrator", $password )

Enter-PSSession  -VMName Test -Cred $cred
#>
##$vm = Add-VirtualMachine -Name "Test" -Generation 2 -Memory 2GB -MinimumMemory 512MB -Path "C:\Data\Virtual Machines\" -SwitchName $virtualSwitch.Name -NICName "Primary" -Disk $diskImage -Checkpoints $false -DynamicMemory $true -Processors 2 -Virtualization $true

##$vm | Start-VM

##Remove-Item -Recurse -Force $vmPath -ErrorAction SilentlyContinue

##mkdir $diskPath -ErrorAction SilentlyContinue

##New-VHD -Path (Join-Path -Path $diskPath -ChildPath "$name.vhdx") -SizeBytes ($diskSize * 1GB) 

##$vm = New-VM -VMName $name -MemoryStartupBytes ($memorySize * 1GB) -Generation 1 -Path $path -SwitchName $switchName -VHDPath (Join-Path -Path $diskPath -ChildPath "$name.vhdx") -Force

#If using Generation 2:
#Issue with bootfix that is unresolved.
#Add-VMDvdDrive -VMName $name -Path $bootISOpath
#Set-VMFirmware -VMName $name -EnableSecureBoot Off or On
#Set-VMFirmware -VMName $name -BootOrder (Get-VMDvdDrive -VMName $name), (Get-VMHardDiskDrive -VMName $name)

##Set-VMBios -VMName $name -StartupOrder @("IDE", "CD", "Floppy", "LegacyNetworkAdapter")
##Set-VMProcessor -Count 2
##Set-VMMemory -DynamicMemoryEnabled $true -MinimumBytes ($memorySize * 1GB)
##Set-VM -AutomaticCheckpointsEnabled $False
##Set-VMDvdDrive -VMName $name -Path $bootISOpath

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

 $unattendfile=CreateUnattendFileVHD -Computername $DCName -AdminPassword $localPassword -path "$PSScriptRoot\temp\" -TimeZone $TimeZone
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