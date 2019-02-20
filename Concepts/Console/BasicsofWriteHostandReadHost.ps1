<#
.SYNOPSIS
  Basics of Write-Host and Read-Host
.DESCRIPTION
  Several examples showing how to get input from the user and make decisions based on that input.
.NOTES  
File Name  : BasicsofWriteHostandReadHost.ps1
Author     : Nathan Abourbih - nathan@abourbih.com 
#>

Write-Host "`nUse the Write-Host cmdlet to output text to the console."
Write-Host "Additionally, you can use the backtick and n character`n to add line breaks provide more visual space.`n"
Write-Host "You can also use additional parameters to change the colour.`n" -ForegroundColor Green
Write-Host "Use the Read-Host cmdlet to ask the user to type something...`n"

$favoriteColour = Read-Host "What is your favorite colour"

if (@("red", "green", "blue", "yellow") -contains $favoriteColour)
{
  Write-Host "I just love the colour $favoriteColour!!" -ForegroundColor $favoriteColour
}
else {
  Write-Host "Wow! Your favorite colour is $favoriteColour!!"
}

Write-Host "`nYou can use an if statement or a switch statement to make a choice."

$number = Read-Host "Choose a number between 1 and 5"

switch ($number) {
  "1" { 
    Write-Host "You typed the number one!"
  }
  "2" { 
    Write-Host "You typed the number two! Here are two happy faces: :) :)"
  }
  "3" { 
    Write-Host "You typed the number three! Here are three happy faces: :) :) :)"
  }
  "4" { 
    Write-Host "You typed the number four! Here are four happy faces: :) :) :) :)"
  }
 "5" { 
    Write-Host "You typed the number five! Here are five happy faces: :) :) :) :) :)"
  }
  Default {
    Write-Host "Sorry! Please try again."
  }
}

#Alternativly you could do the same thing with an if statement. See below...

<#
if ($number -eq "1")
{ 
    Write-Host "You typed the number one!"
  }
  elseif ($number -eq "2"){ 
    Write-Host "You typed the number two! Here are two happy faces: :) :)"
  }
  elseif ($number -eq "3") { 
    Write-Host "You typed the number three! Here are three happy faces: :) :) :)"
  }
  elseif ($number -eq "4") { 
    Write-Host "You typed the number four! Here are four happy faces: :) :) :) :)"
  }
 elseif ($number -eq "5") { 
    Write-Host "You typed the number five! Here are five happy faces: :) :) :) :) :)"
  }
  else {
    Write-Host "Sorry! Please try again."
  }
#>