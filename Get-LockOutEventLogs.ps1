$TargetUserName = read-host "Enter Target Username"

     Get-ADDomainController -Filter * | Select -ExpandProperty name | 
     #get-addomaincontroller "jak-2k8-dc01" |
% {
    Get-WinEvent -ComputerName $_ -FilterHashTable @{ LogName="Security"; ID = 4740,4771; StartTime = ((Get-Date).AddDays(-1))}
} | % {
    $TargetUserName = $_.message.split("`n") | Select-String "Account Name:"; 
    $_ | Add-Member -MemberType NoteProperty -Name TargetUserName -Value $TargetUserName[0];
    $_
} | Export-CSV "c:\scripts\lockouts.csv" -notypeinformation