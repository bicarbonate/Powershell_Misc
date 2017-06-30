#script to remotely install software"

#prompt for destination computer name"
$computername = Read-host "Enter the computer name."

#prompt for installer MSI"
$msiPath = Read-Host "Type the complete path to the installer MSI file"

wmic /node:$computername product call install true,"","$msiPath"
