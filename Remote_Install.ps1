cls
$servername = read-host "Enter server hostname"
$password = read-host "Enter admin password"
$computername = $servername
$sourcefile = "\\netapp\mis\software\microsoft\pcns\password change notification service.msi"
$servicename = "PCNSSVC"
$adminusername = "subhart"
$adminpassword = $password
#This section will install the software 
#foreach ($computer in $computername) 
{
    $destinationFolder = "\\$computer\C$\test"
    #This section will copy the $sourcefile to the $destinationfolder. If the Folder does not exist it will create it.
    if (!(Test-Path -path $destinationFolder))
    {
        New-Item $destinationFolder -Type Directory
    }
Copy-Item -Path $sourcefile -Destination $destinationFolder
    Write-Host "Files Copied Successfully"
    C:\PSTools\psexec.exe \\$computer -s -u $adminUserName -p $adminPassword msiexec.exe /i C:\test\password change notification service.msi /qb /l* out.txt
    Write-Host "Installed Successfully"
    C:\PSTools\psexec.exe \\$computer -s -u $adminUserName -p $adminPassword sc.exe start $serviceName
    Write-Host "Starting the Service"
}