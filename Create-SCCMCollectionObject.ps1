Add-PSSnapin Quest.ActiveRoles.ADManagement
 
#Set Collection Type
$CollectionType = Read-Host "Is this a computer or user collection?"
 
if ($CollectionType -eq "Computer")
{$CollectionType = "2"}
 
if ($CollectionType -eq "User")
{$CollectionType = "1"}
 
#Build Collection Name and Description
$CollectionName = Read-Host "What is the name of the Application group? EX: APP_Adobe Flash Player"
$Description = $CollectionName
 
#Configuration Block for SCCM 
$Sitename = "MI1"
$Domain = "Difc.root01.org"
$GroupOU = "OU=Software Distribution,DC=difc,DC=root01,DC=org"
 
$Namespace = "Root\SMS\Site_" + $Sitename
 
#Create Collection Block
Function Create-Collection($CollectionName)
{
    $CollectionArgs = @{
        Name = $CollectionName;
        CollectionType = "1";         # User Collection Type
        LimitToCollectionID = "SMS00002" # All Users Collection
    }
    Set-WmiInstance -Class SMS_Collection -Arguments $CollectionArgs -Namespace $Namespace | Out-Null
}
 
#Update Query Block
Function Update-Query($CollectionName) {
 
$QueryExperssion = 'select *  from  SMS_R_User where SMS_R_User.UserGroupName = "' + $Domain + '\\' + $CollectionName + '"'
$Collection = Get-WmiObject -Namespace $Namespace -Class SMS_Collection -Filter "Name='$CollectionName' and CollectionType = '$CollectionType'"
 
#Validate Query syntax  
$ValidateQuery = Invoke-WmiMethod -Namespace $Namespace -Class SMS_CollectionRuleQuery -Name ValidateQuery -ArgumentList $QueryExperssion
 
If($ValidateQuery){
    $Collection.Get()
 
    #Create new rule
    $NewRule = ([WMIClass]"\\Localhost\$Namespace`:SMS_CollectionRuleQuery").CreateInstance()
    $NewRule.QueryExpression = $QueryExperssion
    $NewRule.RuleName = $CollectionName
 
    #Commit changes and initiate the collection evaluator                   
    $Collection.CollectionRules += $NewRule.psobject.baseobject
    $Collection.RefreshType = 6 # Enables Incremental updates
    $Collection.Put()
    $Collection.RequestRefresh()
    }
}
 
#The WorkHorse 
 
Create-Collection $CollectionName
Update-Query $CollectionName
New-QADGroup -Name $CollectionName -ParentContainer $GroupOU -groupScope Global -Description $Description
