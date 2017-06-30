Get-MailboxDatabase -server jak-2k8-exch | where {$_.Name -like "M*"} | Select @{Name="Mailboxcount";expression={(Get-Mailbox -Database $_.Identity |
Measure-Object).Count}},Name, Server, StorageGroupName | Sort-Object -Property "mailboxcount" -Descending | Select-Object -Last 1



