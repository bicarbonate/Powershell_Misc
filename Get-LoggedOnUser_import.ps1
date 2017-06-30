#$filepath = "D:\users\bhart.difc\Desktop\bitlocker\mi-workstations.csv"
$computers = Get-ADComputer -Properties  OperatingSystem -Filter "OperatingSystem -Like 'Windows 7*'" -erroraction SilentlyContinue
#$stuff = import-csv $filepath
foreach ($computer in $computers) {
get-wmiobject Win32_ComputerSystem -computername $computer | 
  format-table -property username, dnshostname}