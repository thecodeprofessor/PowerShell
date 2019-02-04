<#
.SYNOPSIS
Functions in the Pipeline
.DESCRIPTION
An example of how to use a function in the pipeline.
.NOTES  
File Name  : FunctionsInThePipeline.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

Function Get-DirectorySizes {

    [CmdletBinding()]

    Param(
        [parameter(
            Mandatory,
            ParameterSetName = 'path',
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]$path,
     
        [parameter(
            Mandatory,
            ParameterSetName = 'literalPath',
            Position = 0,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath')]
        [string[]]$literalPath
    )

    Begin {
        #Work to be done at the beginning, before going through each item passed in.
    }

    Process {
        #Work to be done for each item passed in.

        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $currentPaths = Resolve-Path -Path $Path | Select-Object -ExpandProperty Path
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'LiteralPath') {
            $currentPaths = Resolve-Path -LiteralPath $LiteralPath | Select-Object -ExpandProperty Path
        }

        # Process each item in resolved paths
        foreach ($currentPath in $currentPaths) {
            $currentItem = Get-Item -LiteralPath $currentPath
            if ($currentItem -is [System.IO.directoryInfo]) {
 
                $totalSize = 0
                Get-ChildItem -Path $currentItem -File -Recurse -Force -ErrorAction 0 |
                    ForEach-Object {
                    $totalSize += $_.Length
                }

                [PSCustomObject]@{
                    'Directory' = $currentItem.Name;
                    'MB'        = [math]::Round($totalSize / 1MB, 2);
                    'KB'        = [math]::Round($totalSize / 1KB, 2)
                }	
            }

        }
    }

    End {
        #Work to be done at the end, after going through each item passed in.
        $Report
    }
}

#Get-DirectorySizes -Path C:\Users\nate\desktop, C:\Users\nate\desktop

#Get-DirectorySizes -Path C:\Users\nate\downloads\*

#Get-Item "C:\Users\nate\desktop" | Get-DirectorySizes   

#Get-ChildItem "C:\Users\nate" -ErrorAction 0 | Get-DirectorySizes  

#Get-ChildItem "C:\Users\nate\downloads" -ErrorAction 0 | Get-DirectorySizes  