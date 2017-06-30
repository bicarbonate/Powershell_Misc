#ADCS Backup Tool 
#Made by Fredrik “DXter” Jonsson (dxter@poweradmin.se) 2011-03-31 
#http://www.poweradmin.se

#Get input strings 
param( 
  [string]$backupdir=$(throw “Mandatory parameter -backupdir missing, for example “”C:Backup”””), 
  [string]$pfxpassword=$(throw “Mandatory parameter -pfxpassword missing, for example “”secretpassword”””)
)

#Start stopwatch 
$totalTime = New-Object -TypeName System.Diagnostics.Stopwatch 
$totalTime.Start()

#Set variables 
$CAPOLICY = “$ENV:SystemRootCAPolicy.inf” 
$CERTUTIL = “$ENV:SystemRootSystem32certutil.exe” 
$REG = “$ENV:SystemRootSystem32reg.exe” 
$REGFILE= “adcs_registry_backup.reg”

#Credits 
Write-Host 
Write-Host “ADCS Backup Tool” -ForegroundColor “Yellow” 
Write-Host

#Function to backup CA 
function Backup-ADCS 
{ 
if (Test-Path –Path $BACKUPDIR) 
{ 
    Write-Progress -Activity “ADCS Backup Tool” -Status “Backup directory $BACKUPDIR exists!” -PercentComplete 10 
    Write-Host “Backup directory $BACKUPDIR exists!” -ForegroundColor Yellow 
    Start-Sleep -Seconds 1 
    Write-Host 
} 
else 
{ 
    Write-Host “Creating backup directory $BACKUPDIR!” -ForegroundColor Yellow 
    New-Item -Path $BACKUPDIR -ItemType Directory 
if ($? -eq $true) 
{ 
    Write-Host “Backup directory $BACKUPDIR created!” -ForegroundColor Yellow 
} 
else 
{ 
    Write-Host “Backup directory $BACKUPDIR failed to create!” -ForegroundColor Yellow 
} 
    Write-Host 
}

#Verify certutil installation 
Test-Path $CERTUTIL 
if (Test-Path –Path $CERTUTIL) 
{ 
    Write-Progress -Activity “ADCS Backup Tool” -Status “Backing up ADCS private key + certificate!” -PercentComplete 20 
    Write-Host “Backing up ADCS private key + certificate!” -ForegroundColor Yellow 
    Start-Sleep -Seconds 1 
    .$CERTUTIL -f -backupKey -p $PFXPASSWORD $BACKUPDIR 
if ($? -eq $true) 
{ 
    Write-Progress -Activity “ADCS Backup Tool” -Status “ADCS private key + certificate backed up!” -PercentComplete 30 
    Write-Host “ADCS private key + certificate backed up!” -ForegroundColor Yellow 
} 
else 
{ 
    Write-Host “ADCS private key + certificate not backed up!” -ForegroundColor Red 
} 
    Start-Sleep -Seconds 1 
    Write-Host 
    Write-Progress -Activity “ADCS Backup Tool” -Status “Backing up ADCS database + log files!” -PercentComplete 40 
    Write-Host “Backing up ADCS database + log files!” -ForegroundColor Yellow 
    Start-Sleep -Seconds 1 
    .$CERTUTIL -f -backupDB $BACKUPDIR KeepLog 
if ($? -eq $true) 
{ 
    Write-Progress -Activity “ADCS Backup Tool” -Status “ADCS database + log files backed up!” -PercentComplete 50 
    Write-Host “ADCS database + log files backed up!” -ForegroundColor Yellow 
} 
else 
{ 
    Write-Host “ADCS database + log files not backed up!” -ForegroundColor Red 
} 
    Start-Sleep -Seconds 1 
    Write-Host 
} 
else 
{ 
    Write-Host “Certutil not installed!” -ForegroundColor Red 
    Write-Host 
}

#Copy CAPolicy.inf 
if (Test-Path –Path $CAPOLICY) 
{ 
    Write-Progress -Activity “ADCS Backup Tool” -Status “Backing up CAPolicy.inf” -PercentComplete 60 
    Write-Host “Backing up CAPolicy.inf!” -ForegroundColor Yellow 
    Start-Sleep -Seconds 1 
    Copy-Item $CAPOLICY -Destination $BACKUPDIRCAPolicy.inf -Force 
if ($? -eq $true) 
{ 
    Write-Progress -Activity “ADCS Backup Tool” -Status “CAPolicy.inf backed up!” -PercentComplete 70 
    Write-Host “CAPolicy.inf backed up!” -ForegroundColor Yellow 
} 
else 
{ 
    Write-Host “CAPolicy.inf not backed up!” -ForegroundColor Red 
} 
    Start-Sleep -Seconds 1 
    Write-Host 
} 
else 
{ 
    Write-Host “CAPolicy.inf does not exist. Skipping!” -ForegroundColor Yellow 
    Write-Host 
}

#Export registry 
if (Test-Path –Path $REG,HKLM:SYSTEMCurrentControlSetServicesCertSvcConfiguration) 
{ 
    Write-Progress -Activity “ADCS Backup Tool” -Status “Backing up ADCS configuration from registry!” -PercentComplete 80 
    Write-Host “Backing up ADCS configuration from registry!” -ForegroundColor Yellow 
    Start-Sleep -Seconds 1 
    .$REG export HKLMSYSTEMCurrentControlSetServicesCertSvcConfiguration $BACKUPDIR$REGFILE /y 
if ($? -eq $true) 
{ 
    Write-Progress -Activity “ADCS configuration exported from registry!” -Status “ADCS configuration exported from registry!” -PercentComplete 90 
    Write-Host “ADCS configuration exported from registry!” -ForegroundColor Yellow 
} 
else 
{ 
    Write-Host “ADCS configuration not exported from registry!” -ForegroundColor Red 
} 
    Start-Sleep -Seconds 1 
    Write-Host 
} 
else 
{ 
    Write-Host “ADCS configuration not existent!” -ForegroundColor Red 
    Write-Host 
} 
}

#Run backup 
Backup-ADCS | Out-Null 
if ($? -eq $true) 
{ 
    Write-Progress -Activity “ADCS Backup Tool” -Status “CA backup completed successfully!” -PercentComplete 100 
    Write-Host “ADCS backup completed successfully!” -ForegroundColor Yellow 
    Start-Sleep -Seconds 1 
    Write-Host 
} 
else 
{ 
    Write-Host “ADCS backup not completed successfully!” -ForegroundColor Red 
    Write-Host 
}

#Stop stopwatch 
$totalTime.Stop() 
$ts = $totalTime.Elapsed 
$totalTime = [system.String]::Format(“{0:00}:{1:00}:{2:00}”,$ts.Hours, $ts.Minutes, $ts.Seconds) 
Write-Host “Process total time: $totalTime” -ForegroundColor Yellow 
Write-Host