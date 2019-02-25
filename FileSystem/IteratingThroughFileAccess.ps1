<#
.SYNOPSIS
Iterating Through File Access
.DESCRIPTION
An example of using foreach loops to iterate through file access.
.NOTES  
File Name  : IteratingThroughFileAccess.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

$filesandFoldersWithGuestFullAccess = @() #Lets make a new variable that is a list. When we find interesting files or folders, we can add them to the list.

$allFilesAndFolders = Get-ChildItem "P:\" -Recurse #Get a list of all files and folders. Be sure to replace this with a valid path.

foreach ($item in $allFilesAndFolders)
{
    #$item is the current file or folder as we iterate through each file and folder.
    #I am using the name item instead of file because it could be either a file or a folder.

    $itemSecurity = get-acl -Path $item.FullName #Get the security information for the current item.
    $itemAccess = $itemSecurity.access #Get the list of users / groups who have access to this current item.

    [bool]$guestHasFullControl = $false #Lets create a new variable that we will use to track if we see the GUEST user. We will start it off with false (no).
    [bool]$isFolder = $item.PSIsContainer #Just incase we need this later, lets create a new variable to tell us if the item is a fole or a folder.

    #Lets output the name of the current item to the screen and make it yellow or green depending on if it is a file or a folder.
    Write-Host "`n`t $(&{If($isFolder) {"Folder:`t"} Else {"File:`t`t"}})$($item.FullName)" -ForegroundColor "$(&{If($isFolder) {"Yellow"} Else {"Green"}})"

    #Lets add some text to the screen to start our list of groups or users who have access to this item.
    Write-Host "`t`t Users or Groups With Access: " -ForegroundColor Blue
    foreach ($itemAccessEntry in $itemAccess)
    {
        #We will loop through each user or group who has access to the current file or folder (item). This is the list you see if you right-click a file or
        #folder and choose properties and then security.

        #Does the current access entry's IdentityReference (name) match guest?
        #AND
        #Does the current access entry's FileSystemRights match fullcontrol?
        #AND
        #Does the current access entry's AccessControlType match allow?

        if ($itemAccessEntry.IdentityReference -match 'guest' -and $itemAccessEntry.FileSystemRights -match 'fullcontrol' -and $itemAccessEntry.AccessControlType -match 'allow')
        {
            #If all three of those criteria match, then change the variable (guestHasFullControl) we created above to true (yes).
            
            $guestHasFullControl = $true #If the guest user has full control, take note of it.
        }

        #Output the current user or group to the screen so we can visualize this loop happening to help us better understand what is happening.
        Write-Host "`t`t -> $($itemAccessEntry.FileSystemRights)`t$($itemAccessEntry.IdentityReference)" -ForegroundColor Gray
    }

    #Did our variable guestHasFullControl stay as false (no) or did it change to true (yes)? If it is yes, then output an IMPORTANT message.
    if ($guestHasFullControl)
    {
        Write-Host "`t`t`t IMPORTANT: A guest user has full control!" -ForegroundColor Red
        $filesandFoldersWithGuestFullAccess += $item #Lets add this current item (file or folder) to the list we made at the very top of the script.
    }
}

#Lets use the list we created at the top of the script. Remember that we only added items to this list when we found that they matched our criteria (guestHasFullControl).
#Lets display our list on the screen, specify which properties (columns) we want to see, and lets format it as a table.
Write-Host "`n`n`nAll files and folders where a guest user has full control:"
$filesandFoldersWithGuestFullAccess | Select-Object -Property FullName, Name, Mode, LastWriteTime | Format-Table

#If all you wanted to do was output this final list, you could omit all of the Write-Host lines in this entire script.
