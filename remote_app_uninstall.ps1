#script to remotely uninstall software"

#prompt for destination computer name"
$computername = Read-host "Enter the computer name."

#prompt for vendor/app name"
$prodName = Read-Host "Type the name or vendor name of the application you wish to search for. (wildcard searches i.e. "vendor like'adobe%'""

wmic /node:$computername product get name, version, vendor

#prompt for app name for uninstallation"
$removeProd = Read-Host "Type the name of the application you wish to uninstall"

wmic /node:$computername product where name="$removeProd" call uninstall
