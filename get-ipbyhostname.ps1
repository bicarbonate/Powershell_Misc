$hostname = Read-Host "Please enter the hostname"
[System.Net.Dns]::GetHostByName($hostname)