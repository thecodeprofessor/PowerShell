<#
.SYNOPSIS
Iterating Through File Access
.DESCRIPTION
An example of using foreach loops to iterate through file access.
.NOTES  
File Name  : IteratingThroughFileAccess.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$allFilesAndFolders = Get-ChildItem "C:\Users\nate\Downloads" #Get a list of all files and folders. Be sure to replace this with a valid path.

foreach ($item in $allFilesAndFolders)
{
    #$item is the current file or folder as we iterate through each file and folder.

    $itemSecurity = get-acl -Path $item.FullName
    $itemAccess = $itemSecurity.access 

    [bool]$guestHasFullControl = $false
    [bool]$isFolder = $item.PSIsContainer

    Write-Host "`n`t $(&{If($isFolder) {"Folder:`t"} Else {"File:`t`t"}})$($item.FullName)" -ForegroundColor "$(&{If($isFolder) {"Yellow"} Else {"Green"}})"

    Write-Host "`t`t Users or Groups With Access: " -ForegroundColor Blue
    foreach ($itemAccessEntry in $itemAccess)
    {
        #$itemAccessEntry is possibly one of many users or groups that have an access entry for the current file or folder.

        if ($itemAccessEntry.IdentityReference -match 'guest' -and $itemAccessEntry.FileSystemRights -match 'fullcontrol')
        {
            #Do something if the current access entry is for a user with guest in their name and they have Full Control.
            
            $guestHasFullControl = $true #If the guest user has full control, take note of it.
        }

        Write-Host "`t`t -> $($itemAccessEntry.FileSystemRights)`t$($itemAccessEntry.IdentityReference)" -ForegroundColor Gray
    }

    if ($guestHasFullControl)
    {
        Write-Host "`t`t`t IMPORTANT: A guest user has full control!" -ForegroundColor Red
    }
}