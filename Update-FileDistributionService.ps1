
$domainstr = ",dc=difc,dc=root01,dc=org"
$domainnb = "difc"             ## domain netbios name
$domain = "difc.root01.org"

## Forces manual OAB update check polling

Update-FileDistributionService -Type OAB
 