<#
.SYNOPSIS
Basics of Functions with Parameters
.DESCRIPTION
Several examples showing the basics of functions with parameters and how to use them.
.NOTES  
File Name  : BasicsofFunctionsWithParameters.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>


Write-Host "`nExample 1:" -ForegroundColor Green
function Get-EyeColourSentence($name, $colour)
{ 
    return "$name, your eyes are $colour."
}

$yourName = Read-Host "What is your name"
$yourEyeColour = Read-Host "What colour are your eyes"

Write-Host "$(Get-EyeColourSentence -name $yourName -colour $yourEyeColour)"
Write-Host "$(Get-EyeColourSentence $yourName $yourEyeColour)"


Write-Host "`nExample 2:" -ForegroundColor Blue

function Get-PriceIncludingTax($price, $taxPercentage)
{ 
    $total = ([double]$price * [double]$taxPercentage) + [double]$price
    return $total
}

$price = Read-Host "How much is the bag of bananas"
$tax = 0.15 #This example is 15%.

Write-Host "The price including tax is: $(Get-PriceIncludingTax $price $tax)"


Write-Host "`nExample 3:" -ForegroundColor Blue

function Get-PriceIncludingTax
{ 
    Param(
        [double]$price,
        [double]$taxPercentage
    )

    $total = ([double]$price * [double]$taxPercentage) + [double]$price
    return $total
}

$price = Read-Host "How much is the bag of bananas"
$tax = 0.15 #This example is 15%.

Write-Host "The price including tax is: $(Get-PriceIncludingTax $price $tax)"