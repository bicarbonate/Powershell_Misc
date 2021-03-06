Import-Module ActiveDirectory
$groups = get-Adgroup -Filter * -searchbase "ou=vendors,ou=people,dc=difc,dc=root01,dc=org" -Properties * | ? {$_.Flags -eq "1"}
foreach ($group in $groups)
{
Set-ADGroup $group.SamAccountName -Add @{info = "no sync"}
}
#this script returns all ad groups with extended attribute of 'flags' = 1. which marks
#a group as blocked from being syncd to dover via FIM. It then adds teh text 'no sync'
#to the Notes field.