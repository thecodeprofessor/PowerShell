<#
.SYNOPSIS
Filters vs Functions
.DESCRIPTION
Several examples showing the differences between filters and functions.
.NOTES  
File Name  : FiltersvsFunctions.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

#You can use the automatic variable $input to capture pipeline input.
Function Get-Grape {
    foreach ($fruit in $input) {
        if ($fruit -eq 'grape') {
            $fruit
        }
    }
}
@('apple', 'grape', 'orange') | Get-Grape


Filter Get-Orange {
    if ($_ -eq 'orange') {
        $_
    }
}
@('apple', 'grape', 'orange') | Get-Orange

<#
Notice that the function uses a foreach but the filter does not.

The difference is how the pipeline is processed. The function
only starts processing items after all of the items are passed into it.
However, the filter processes each item as they are presented in the pipeline.

In this way, the pipeline can start producing output while the pipeline is
still being filled with new items.
#>
