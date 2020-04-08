$folder = get-childitem -path "c:\users\user\desktop\test" -filter "1" -recurse -directory | foreach-object { $_.Fullname }
#get-acl $folder | where {$_.identityreference -notmatch "BUILTIN|NT AUTHORITY|EVERYONE|CREATOR OWNER"} | fl Path,owner,group,access
$acl = get-acl $folder
$rule = new-object system.security.accesscontrol.filesystemaccessrule("domain\project_managers","FullControl","Allow")
$acl.setaccessrule($rule)
$acl | set-acl
get-acl $folder | where {$_.identityreference -notmatch "BUILTIN|NT AUTHORITY|EVERYONE|CREATOR OWNER"} | fl path,owner,group,access
