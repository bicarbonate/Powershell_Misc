
# Loads additional snapins and their init scripts
function LoadSnapins(){
   $snapinList = @( "VMware.VimAutomation.Core", "VMware.VimAutomation.Vds", "VMware.VimAutomation.License", "VMware.DeployAutomation", "VMware.ImageBuilder", "VMware.VimAutomation.Cloud")

   $loaded = Get-PSSnapin -Name $snapinList -ErrorAction SilentlyContinue | % {$_.Name}
   $registered = Get-PSSnapin -Name $snapinList -Registered -ErrorAction SilentlyContinue  | % {$_.Name}
   $notLoaded = $registered | ? {$loaded -notcontains $_}
   
   foreach ($snapin in $registered) {
      if ($loaded -notcontains $snapin) {
         Add-PSSnapin $snapin
      }
   }
}
LoadSnapins




$cred = Get-Credential
connect-viserver 10.2.3.19  -credential $cred
get-vmhost | get-vmhostfirmware -backupconfiguration -destinationpath "C:\vmware_backups"

pause