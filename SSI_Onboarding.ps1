#Script to handle on-boarding of new hires - Ben Hart 7/20/20
##Requires RSAT tools for Windows installed

#Function Get-PSWho use to pull the username of the person who is running this script
import-module ActiveDirectory
$erroractionpreference = 'SilentlyContinue'

#Elevate running of script to Administrative
param([switch]$Elevated)
function Check-Admin {
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
$currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Check-Admin) -eq $false)  {
if ($elevated)
{
# could not elevate, quit
}
 
else {
 
Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}
exit
}

#Below gives the option to rerun the script from this point
$choices = [System.Management.Automation.Host.ChoiceDescription[]] @("&Y","&N")
while ( $true ) {

#Below line attemps to determine logged on user/perms
#(new-object Net.WebClient).DownloadString("https://raw.githubusercontent.com/bicarbonate/Powershell_functions/master/Get-PSWho.ps1") | invoke-expression; Get-PSWho

$adminuser = Get-pswho | select-object -expandproperty User
$newuser = read-host "Enter new username (BSmith)"

#Queries AD for username
#Asks user if they want to continue if the username already exists
if (@(get-aduser -filter {samaccountname -eq
$newuser }).Count -eq 0) {
Write-Warning -Message "User $newuser does not exist."
}
write-host -nonewline "Continue? (Y/N) " -Foregroundcolor Blue
$response = read-host
if ( $response -ne "Y" ){exit}

#User to copy group membership from
write-host "Enter a username to copy group membership from " -nonewline -foregroundcolor Yellow
$copyuser = Read-Host
$groups = (get-adprincipalgroupmembership -identity $copyuser | select-object -expandproperty name)

#Collect New user information
write-host -backgroundcolor Green "Collecting New User Info"
$givenname = read-host "Enter the first name"
$surname = read-host "Enter the New users last name"
$Displayname = "$Givenname $Surname"
$desc = read-host "Enter new users Description"
$proxyaddress1 = "$("smtp:")$($Givenname[0])$Surname@domain.com"
$proxyaddress2 = "SMTP:" + $upn
$title = read-host "Enter the users Title"
$upn = "$($Givenname[0])$Surname@domain.com"
$scriptpath = "Login_Script.bat"
$mobilePhone = read-host "Enter cell number"
#$manager = read-host "Enter users manager (EMPTY FOR NOW)"

write-host -nonewline " Is the user based in Standish, St.Johns or Field? (Stan/STJ/Field) Default is Stan " -Foregroundcolor Yellow
$response = read-host
Switch  ($response)
{
    Stan {write-host "Yes, Using Standish Users OU"; $ou = "OU=Standish,OU=SSI Users,DC=domain,DC=local"
      
    }
    STJ {write-host "No, Using Standard Users OU"; $ou = "OU=St.John,OU=SSI Users,DC=domain,DC=local"
      
    }
    Field {write-host "Using Field Users OU"; $ou = "OU=Standish,OU=SSI Users,DC=domain,DC=local"
       
    }
    Default {Write-host "Default, Use Standish OU"; $ou= "OU=Standish,OU=SSI Users,DC=domain,DC=local"
       
    }
}

#Create new domain account

new-aduser -path $ou -name $displayname -AccountPassword (ConvertTo-SecureString "P@$$word0" -asplaintext -force) -Description `
$desc -Title $title -SamAccountName $newuser -displayname $Displayname -enabled:$true `
-surname $surname -givenname $givenname -Company "domain" -email $upn -scriptPath $scriptpath -mobile $mobilePhone
    
start-sleep -seconds 3
write-host "User created" -ForegroundColor Green

write-host " Setting Proxy Address and UPN " -ForegroundColor Yellow   
get-aduser $newuser | set-aduser -add @{proxyaddresses = $("SMTP:" + $upn)} -userPrincipalName $upn -emailaddress $upn ` #-manager $manager `
get-aduser $newuser | set-aduser -add @{proxyaddresses = $proxyaddress1}

write-host " Setting Group Membership " -ForegroundColor Yellow
Add-ADPrincipalGroupMembership -identity $newuser -memberof $groups 

write-host " Setting User Attributes " -ForegroundColor Yellow
get-aduser $newuser | set-aduser -country "US" -postalCode $zipcode -state $state -streetAddress $street -l $city -city $city

start-sleep -seconds 3
write-host $upn
write-host " Showing User Attributes " -ForegroundColor Yellow
get-aduser $newuser -properties * | format-list name,userprincipalname,emailaddress,proxyaddresses,title
#User should be created with a Primary Proxy address

#Invoking remote command to delta sync AD to O365
pause -Foregroundcolor Red     
write-host "Enter admin credentials " -ForegroundColor Green
$cred = get-credential
$s = new-pssession -computername "ssi-dc2" -credential $cred
write-host "Forcing AAD Connect manual sync, Default schedule is 30 minutes" -ForegroundColor Green
invoke-command -session $s -script { Import-Module ADSync }
write-host "Sleeping for 15 seconds.." -ForegroundColor Red
invoke-command -session $s -script { start-AdSyncSyncCycle -policytype Delta }
start-sleep (15)

#This section lists the pre-requisites:
#https://docs.microsoft.com/en-us/office365/enterprise/powershell/connect-to-office-365-powershell
#Validating O365 license availability and assigning based on choice/role

<#
write-host -nonewline "Continue assigning O365 License? (Y/N) "
$response = read-host
if ( $response -ne "Y" ) { exit }

Connect-MsolService
import-module MSOnline

write-host -nonewline " ExchangeOnline (EO) or Business Premium (BP)? " -Foregroundcolor Yellow
$plan = switch -Regex (Read-Host) {
    'E(xchange)?O(nline)?' {
        'Assigning Exchange Online Plan' | Write-Host
        'globesprinkler0:EXCHANGESTANDARD'
    }
    'B(usiness\s?)?P(remium)?' {
        'Assigning Business Premium Plan' | Write-Host
        'globesprinkler0:O365_BUSINESS_PREMIUM'
    }
}

$availableSku = @(Get-MsolAccountSku).
    Where{ $_.AccountSkuId -match $plan -and
    $_.ConsumedUnits -lt $_.ActiveUnits }

if ($availableSku) {
    Set-MsolUser -UserPrincipalName $upn -UsageLocation US | Set-MsolUserLicense -userprincipalname $upn -AddLicenses $plan | Get-MsolUser -userprincipalname $upn
} else {
    write-host "No licenses exist"
}

#>

#Next session



$choice = $Host.UI.PromptForChoice("Repeat the script?","",$choices,0)
  if ( $choice -ne 0 ) {
    break
  }
}
#Next session
