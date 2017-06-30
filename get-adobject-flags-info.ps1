get-adobject -filter {info -eq "no sync" -or flags -eq "1"} | set-adobject -clear info,flags
#Searches all AD objects for attributes flags = 1 or info = no sync and clears it.