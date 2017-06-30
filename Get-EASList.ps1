$mailboxes = Get-Mailbox
$mailboxes | foreach {Get-ActiveSyncDeviceStatistics -Mailbox:$_.identity} |ft devicefriendlyname, devicetype, deviceuseragent, identity