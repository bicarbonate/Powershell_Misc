#
# Powershell Script originally written by Peter Van Eeckhoutte - but heavily modified since then.
# http://www.corelan.be:8800/index.php/2009/01/19/exchange-2007-powershell-script-to-select-optimal-database-for-a-new-mailbox/
#
# This script selects the most optimal database for hosting a new mailbox in Exchange 2007, taking into account the number of active mailboxes 
# in the database. I.E. It doesn't consider the amount of disconnected mailboxes as they will soon be purged.
#


# Create a DataTable to host the mailbox data.
$MBXDBTable = New-Object system.Data.DataTable “MBXDatabaseTable”
# Create the columns by defining their name and attribute type.
$MBXDBTable.Columns.Add("DataBaseName",[String]) | Out-Null
$MBXDBTable.Columns.Add("ActiveMBs",[Int]) | Out-Null
$MBXDBTable.Columns.Add("InactiveMBs",[Int]) | Out-Null
$MBXDBTable.Columns.Add("TotalMBs",[Int]) | Out-Null
$MBXDBTable.Columns.Add("TotalMBSize",[Decimal]) | Out-Null
$MBXDBTable.Columns.Add("AverageMBSize",[Decimal]) | Out-Null


# Query just the mailbox databases with "MBX*" in the name, which avoids other server with a mailbox database, and skip any recovery databases.
$Databases = Get-MailboxDatabase -status | where {$_.Name -like "M*" -and $_.Recovery -eq $False} | sort-object Name
# Set the loop count to 0. 
$LoopCount=0

# Loop through each database in the above query.
Foreach ($Database in $Databases) {
    # Check to see if the database is mounted, otherwise skip to down below.
    if ($Database.Mounted -eq "True") {
        # Define the query which specifies grabbing statistics for each mailbox in the database.
        # NOTE: This only grabs information on mailboxes that have been created in the database. New mailboxes that haven't been "created" will not show up here.
        $DBStats = Get-MailboxStatistics -database $Database
        # Set the initial values to 0 for each database being processed.
        $TotalActiveMB = 0
        $TotalInactiveMB = 0
        $TotalNrofMB = 0
        $TotalDBSize = 0
        $AvgMBSize = 0
        # Loop through the statistics for each mailbox in the database.
        foreach ($DBStat in $DBStats) {
            # Count the total number of mailboxes (active and inactive).
            $TotalNrofMB++
            # Add the size of the mailbox to the total size of all mailboxes in the database.
            $TotalDBSize = $TotalDBSize + $DBStat.TotalItemSize.Value.ToMB()
            # Count the number of mailboxes that are not disconnected (I.E. they are still active).
            If ($DBStat.DisconnectDate -eq $Null) {
                $TotalActiveMB++
            }
        }
        if ($TotalNrofMB -gt 0) {
            # Set the average mailbox size to collective mailbox size divided by the number of mailboxes.
            $AvgMBSize = $TotalDBSize/$TotalNrofMB
            # Calculate the number of inactive mailboxes by subtracting the active mailboxes.
            $TotalInactiveMB = ($TotalNrofMB - $TotalActiveMB)
            # Round out the average mailbox size.
            $AvgMBSize=[math]::round($AvgMBSize, 2)
        }
        # Add the gathered information to a new row in the table.
        $NewDBRow = $MBXDBTable.NewRow()
        $NewDBRow.DataBaseName = $Database.Name
        $NewDBRow.ActiveMBs = $TotalActiveMB
        $NewDBRow.InactiveMBs = $TotalInactiveMB
        $NewDBRow.TotalMBs = $TotalNrofMB
        $NewDBRow.TotalMBSize = $TotalDBSize
        $NewDBRow.AverageMBSize = $AvgMBSize
        $MBXDBTable.Rows.Add($NewDBRow)
    } else {
        # If a database is not mounted, write its name to the screen in RED text.
        write-host -Fore Red "Database : $Database : not mounted"
    }
    # Show a status bar for progress while data is collected.
    $PercentComplete = [Math]::Round($LoopCount++ / $Databases.Count * 100)
    $CurrentDB = $Database.Name
    Write-Progress -Activity "Mailbox Database Query in Progress" -PercentComplete $PercentComplete -Status "$PercentComplete% Complete" -CurrentOperation "Current Database: $CurrentDB"
}
# Choose the optimal database by the choosing one with the fewest active mailboxes.
$Optimaldb = ($MBXDBTable | Sort-Object ActiveMBs | select -first 1)
# Dump the table to the screen.
$MBXDBTable | Sort-Object -Descending ActiveMBs | Format-Table -AutoSize
# Dump the table to a CSV - not currently used.
# $MBXDBTable | Export-CSV MailboxDBSizes.csv
write-host -fore Blue "The optimal new mailbox database is" $Optimaldb.DataBaseName "based upon the active mailbox count of" $Optimaldb.ActiveMBs "`b."