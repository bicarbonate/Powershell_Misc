# 
# 
# NAME: Get-BitlockerEnabledComputer.ps1 
# 
 

# EDITTED BY: Benjamin Hart
# EMAIL: Invalid.path@gmail.com
# 
# COMMENT: Script to retrieve BitLocker-information for all computer objects with Windows 7 or Windows Vista in the current domain. 
# 
#          The information will be exported to a CSV-file containing the following information: 
#          -Computername 
#          -OperatingSystem 
#          -HasBitlockerRecoveryKey 
#          -HasTPM-OwnerInformation 
#           
#          Required version: Windows PowerShell 1.0 or 2.0 
#          Requried privileges: Read-permission on msFVE-RecoveryInformation objects and Read-permissions on msTPM-OwnerInformation on computer-objects (e.g. Domain Admins) 
#     
#  
#        Original Blog post: http://chronicgeekage.blogspot.com/2015/06/powershell-script-generates-csv-with.html




import-module activedirectory 

#Custom variables
$CsvFilePath = "d:\users\bhart.difc\desktop\bitlocker\bitlocker_status.csv" 

set-location AD:
$bitlockerenabled = Get-ADObject -LDAPFilter '(objectclass=msFVE-recoveryInformation)' -Properties cn,distinguishedname | ForEach `
{
    ((($_ | Select -ExpandProperty DistinguishedName) -split ",?CN=")[2] -split ",")[0]
}

$computers = Get-ADComputer -filter * -Properties cn,OperatingSystem,msTPM-OwnerInformation,description | Where-Object {$_.operatingsystem -like "Windows 7*" -or $_.operatingsystem -like 
"Windows 8*"} | Sort-Object msTPM-OwnerInformation
 
#Create array to hold computer information 
$export = @() 

read-host "Created array"

foreach ($computer in $computers) 
  { 
    #Create custom object for each computer 
    $computerobj = New-Object -TypeName psobject 
    
     
    #Add name and operatingsystem to custom object 
    $computerobj | Add-Member -MemberType NoteProperty -Name DistinguishedName -Value $computer.Name 
    $computerobj | Add-Member -MemberType NoteProperty -Name OperatingSystem -Value $computer.operatingsystem 
    $computerobj | Add-Member -MemberType NoteProperty -Name Description -Value $computer.description

    #Set HasBitlockerRecoveryKey to true or false, based on matching against the computer-collection with BitLocker recovery information 
    if ($computer.cn -match ('(' + [string]::Join(')|(', $bitlockerenabled) + ')')) { 
    $computerobj | Add-Member -MemberType NoteProperty -Name HasBitlockerRecoveryKey -Value $true 
    } 
    else 
    { 
    $computerobj | Add-Member -MemberType NoteProperty -Name HasBitlockerRecoveryKey -Value $false 
    } 
    
     
    #Set HasTPM-OwnerInformation to true or false, based on the msTPM-OwnerInformation on the computer object 
     if ($computer."msTPM-OwnerInformation") { 
    $computerobj | Add-Member -MemberType NoteProperty -Name HasTPM-OwnerInformation -Value $true 
    } 
    else 
    { 
    $computerobj | Add-Member -MemberType NoteProperty -Name HasTPM-OwnerInformation -Value $false 
    } 
   #  $computerobj | add-member -membertype noteproperty -name recoveryguid -value $object.recoveryguid
   #$computerobj | add-member -membertype noteproperty -name When-Created -value $computer.whencreated
#Add the computer object to the array with computer information 
$export += $computerobj 
 
  } 
 
#Export the array with computerinformation to the user-specified path 
$export | Export-Csv -Path $CsvFilePath -NoTypeInformation | sort HasBitlockerRecoveryKey -descending
read-host "Exported csv"

