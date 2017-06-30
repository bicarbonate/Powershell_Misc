
import-module activedirectory

get-content "c:\oracle.txt" | foreach $user in $users {get-adcomputer -filter * -properties Managedby -eq $user | export-csv "c:\oraclecomputers.txt"}

                                