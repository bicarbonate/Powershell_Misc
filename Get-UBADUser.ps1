import-module ActiveDirectory
$user = Read-Host "Please enter the persons last name."
get-aduser -filter {surname -eq $user} | select name,samaccountname