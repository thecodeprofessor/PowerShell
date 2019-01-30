<#
.SYNOPSIS
List Disk Space Using Custom Properties
.DESCRIPTION
 An example of using a property list with a name and expression to customize the output of the Format-Table cmdlet.
.NOTES  
File Name  : GetDiskSpaceUsingCustomProperties.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

Write-Host "`nYour computer's disk space is as follows..."  -ForegroundColor Blue

$properties = @(
    @{ Name = "Letter"; Expression = {$_.DeviceID}},
    @{ Name = "Name"; Expression = {$_.VolumeName}},
    @{ Name = "Size (GB)"; Expression = {[math]::Round($_.Size / 1GB, 2) }; Alignment = "right"; },
    @{ Name = "Size (TB)"; Expression = {[math]::Round($_.Size / 1TB, 2) }; Alignment = "right"; },
    @{ Name = "Free (GB)"; Expression = {[math]::Round($_.FreeSpace / 1GB, 2) }; Alignment = "right"; },
    @{ Name = "Free (TB)"; Expression = {[math]::Round($_.FreeSpace / 1TB, 2) }; Alignment = "right"; },
    @{ Name = "Free (%)"; Expression = {([math]::Round($_.FreeSpace / $_.Size, 2) * 100) }; Alignment = "right"; }
)

Get-WmiObject Win32_LogicalDisk | Format-Table -Property $properties -AutoSize


<# =======================================================
   Example 2
    - This example uses custom line widths in combination
    with the write-output cmdlet to allow for full 
    control over the output.
# =======================================================#>

$lineWidths = "{0,-12} {1,-12} {2,-12} {3,-12} {4,-12} {5,-12} {6,-12}"

write-output $($lineWidths -f "Letter","Name","Size (GB)","Size (TB)","Free (GB)","Free (TB)","Free (%)")
write-output $($lineWidths -f "------","----","---------","---------","---------","---------","--------")
foreach ($disk in $disks)
{
  write-output $($lineWidths -f $(Write-Host $disk.DeviceID -NoNewLine -ForegroundColor Green),
  $disk.VolumeName,
  [math]::Round($disk.Size / 1GB, 2),
  [math]::Round($disk.Size / 1TB, 2),
  [math]::Round($disk.FreeSpace / 1GB, 2),
  [math]::Round($disk.FreeSpace / 1TB, 2),
  ([math]::Round($disk.FreeSpace / $disk.Size, 2) * 100)
  )
}


<# =======================================================
   Example 3
    - This example uses a property list with a label and
    expression as well as a variety of html styles,
    headers, footers, and even bootstrap to customize
    the output of the ConvertTo-Html cmdlet and save the
    result to a file.
# =======================================================#>

Write-Host "`nGenerating Disk Space Report..."  -ForegroundColor Blue

$reportSaveLocation = "C:\Users\nate\Desktop\DisksSpaceReport.html"

$properties = @(
    @{ Label = "Letter"; Expression = {$_.DeviceID}},
    @{ Label = "Name"; Expression = {$_.VolumeName}},
    @{ Label = "Size (GB)"; Expression = {[math]::Round($_.Size / 1GB, 2) }; },
    @{ Label = "Size (TB)"; Expression = {[math]::Round($_.Size / 1TB, 2) }; },
    @{ Label = "Free (GB)"; Expression = {[math]::Round($_.FreeSpace / 1GB, 2) }; },
    @{ Label = "Free (TB)"; Expression = {[math]::Round($_.FreeSpace / 1TB, 2) };},
    @{ Label = "Free (%)"; Expression = {([math]::Round($_.FreeSpace / $_.Size, 2) * 100) }; }
)

$styles = @"
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css" integrity="sha384-GJzZqFGwb1QTTN6wy59ffF1BuGJpLSa9DkKMp0DgiMDm4iYMj70gZWKYbI706tWS" crossorigin="anonymous">
<script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
<style>
body { padding: 2em; }
</style>
<script>
  `$(document ).ready(function() {
    `$('table').addClass('table').addClass('table-striped').addClass('table-hover').addClass('table-bordered');
  });
</script>
"@

$formattedDate = Get-Date -Format "D";
$formattedTime = Get-Date -Format "T";

$top = @"
<div class="jumbotron" style="padding: 2em;">
<h1 class="display-4">Disk Space Report</h1>
<p class="lead">For Computer: $($env:computername)</p>
<hr class="my-4">
<p>This report outlines the current state of the logical disks for $($env:computername) on $formattedDate at $formattedTime.</p>
<a class="btn btn-primary btn-lg" href="https://moodle.cambriancollege.ca/course/view.php?id=13942" role="button">Learn more</a>
</div>
"@

$bottom = @"
<p>This report was generated $(Get-Date) by $($env:UserName).</p>
"@

Get-WmiObject Win32_LogicalDisk | ConvertTo-Html -Property $properties -Head $styles -PreContent $top -PostContent $bottom | Out-File -FilePath $reportSaveLocation