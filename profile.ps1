# PowerShell Profile for PSSnapin
# Set-Location e:\powershell\
set-executionpolicy unrestricted
Add-PSSnapin quest.activeroles.admanagement
# Welcome message
$Guy = $env:Username.ToUpper()
Write-Host "You are now entering PowerShell: $Guy"