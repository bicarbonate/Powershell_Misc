#Script to parse teh Security event log for file/folder deletions (560)
# extra filters for date, time, user, and object name

#Get-EventLog -LogName security | where {$_.eventid -eq 560 -and $_.message.contains("Domain") -eq $true} | Select-Object message | fl

$filteredevents = Get-EventLog -LogName security | where {$_.eventid -eq 560}
foreach($e in $filteredevents)
{
$logonidline = ""
$pn = ""
$sna = ""
foreach($ml in $e.message.split("'n"))
{
 if($ml.contains("Logon Type") -eq $true)
    {
      $logonIdLine = $ml
    }
    elseif($ml.contains("Logon Process") -eq $true)
    {
      $pn = $ml
    }
    elseif($ml.contains("User Name") -eq $true)
    {
      $sna = $ml
    }

  }
  write-host "Event Id: " $e.eventId
  write-host $logonIdLine
  write-host $pn
  write-host "------------------------------"
  }