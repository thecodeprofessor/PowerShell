<#
.SYNOPSIS
List Disk Space Using Html and Bootstrap
.DESCRIPTION
An example of using a property list with a label and expression as well as a variety of html styles, headers, footers, and even bootstrap to customize the output of the ConvertTo-Html cmdlet and save the result to a file.
.NOTES  
File Name  : GetDiskSpaceUsingHtmlandBootstrap.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

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