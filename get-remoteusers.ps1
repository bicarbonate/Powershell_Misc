$strComputer = Read-Host Enter remote hostname

$computer = [ADSI]("WinNT://" + $strComputer + ",computer")
$computer.name

$Users = $computer.psbase.children |where{$_.psbase.schemaclassname -eq "User"}

foreach ($member in $Users.psbase.syncroot)
{$member.name} 