

#$users = Get-ADUser -SearchBase "ou=IT Staff,ou=IT,ou=Employees,ou=People,dc=difc,dc=root01,dc=org" -LdapFilter {(extensionattribute1=employee) -or (extensionattribute1=booyah)}
#foreach ($user in $users) {
#Add-ADGroupMember -Identity "it_test" -Members $users
#}



#$user = Get-ADUser -SearchBase "ou=IT Staff,ou=IT,ou=Employees,ou=People,dc=difc,dc=root01,dc=org" -filter { (custom attribute 13 -like "311") -and (custom attribute 13 -like "387") -and (custom attribute 13 -like "383") -and (custom attribute 13 -like "335") 
#-and (custom attribute 7 -notlike "Employee")
#foreach ($user in $users) {
#Add-ADGroupMember -Identity "group" -Members $users


$users = Get-ADUser -SearchBase "ou=IT Staff,ou=IT,ou=Employees,ou=People,dc=difc,dc=root01,dc=org" -Filter {(extensionattribute13 -eq 311) -Or (extensionattribute13 -eq 387) -Or (extensionattribute13 -eq 383) -and (extensionattribute7 -notlike "employee")}
foreach ($user in $users) {
Add-ADGroupMember -Identity "it_test" -Members $users
}