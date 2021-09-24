param(

    $GroupNamesPath = "$PSScriptRoot\InputFiles\GroupNames.txt",            #DO NOT EDIT
    $AccountNamesPath = "$PSScriptRoot\InputFiles\ServiceAccountNames.txt", #DO NOT EDIT
    $MECMAdminsPath = "$PSScriptRoot\InputFiles\MECMAdmins.txt",            #DO NOT EDIT
    $MECMServersPath = "$PSScriptRoot\InputFiles\MECMServers.txt",          #DO NOT EDIT

    #CreateOUStructure
    $ParentOUPath = (Get-ADRootDSE).defaultNamingContext, #EDIT AS APPROPRIATE, this OU has to exists. Default value is domain root
    $MECMOUName = "MECM",              #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE
    $ServersOUName = "Servers",        #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE
    $GroupsOUName = "Groups",          #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE
    $AccountsOUName = "Accounts",      #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE

    #GrantPermissionsToADJoinAccount
    $OUPath = "OU=Workstations,$root", #If the OU does not exist, it will be created

    #ImportMECMServersGPO
    $NewGPOName = "MECM_Servers", #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE

    #setSPN
    $DBServer = "CM01", #EDIT AS APPROPRIATE
    $PortNumber = 1433 #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE
)

$OldErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = "Stop"

#Don't edit the below variables, unless necessary
#All customization should be done in the param section

#CreateOUStructure vars
$MECMOUPath = $("OU=$MECMOUName" + "," + $ParentOUPath)
$GroupsOUPath = $("OU=$GroupsOUName" + "," + $MECMOUPath)
$AccountsOUPath = $("OU=$AccountsOUName" + "," + $MECMOUPath)
$ServersOUPath = $("OU=$ServersOUName" + "," + $MECMOUPath)

#CreateGroupsAndUsers vars
$MECMServersADGroup = ($SecPrincipals | where {$_.type -eq 'group' -and $_.ID -eq 5}).Name
$MECMIISServersAdGroup = ($SecPrincipals | where {$_.type -eq 'group' -and $_.ID -eq 7}).Name
$MECMAdminsADGroup = ($SecPrincipals | where {$_.type -eq 'group' -and $_.ID -eq 4}).Name  

#GrantPermissionsOnSystemContainer vars
$MECMSiteServer = (Get-Content $MECMServersPath)[0]

#ExtendADSchema vars
$extadschPath = "$PSScriptRoot\BIN\X64"

#ImportMECMServersGPO vars
$BackupGPOName = "MECM_Servers"
$GPOBackupPath = "$PSScriptRoot\GPO"
$SecPrincipalsCSVPath = "$PSScriptRoot\InputFiles\SecurityPrincipals.csv"
$MigTableSource = "$PSScriptRoot\MigTableTemplate.migtable"
$MigrationTable = "$PSScriptRoot\MigTable.migtable"

#GarntPermissionsToADJoinAccount vars
$root = (Get-ADRootDSE).defaultNamingContext
$ADJoinAccount = ($SecPrincipals | where {$_.type -eq 'user' -and $_.ID -eq 2}).Name

#SetSPN vars
$DomainName = (Get-ADDomain).DnsRoot
$SQLServiceAccount = ($SecPrincipals | where {$_.type -eq 'user' -and $_.ID -eq 0}).Name

#Param blocks for each script

#ExtractMECMArchives
$ExtractMECMArchivesParams = @{
    MECMArchiveDir = $MECMArchiveDir
    MECMArchive = $MECMArchive
    MECMArchiveTargetDir = $MECMArchiveTargetDir
}

#ExtendADSchema
$ExtendADSchemaParams = @{
    ExtadschPath = $extadschPath
}

#CreateOUStructure
$CreateOUStructureParams = @{
    ParentOUPath = $ParentOUPath
    MECMOUName = $MECMOUName
    ServersOUName = $ServersOUName
    GroupsOUName = $GroupsOUName
    AccountsOUName = $AccountsOUName
}

#CreateGroupsAndUsers
$CreateGroupsAndUsersParams = @{
    GroupNamesPath = $GroupNamesPath
    AccountNamesPath = $AccountNamesPath
    MECMAdminsPath = $MECMAdminsPath
    MECMServersPath = $MECMServersPath
    MECMOUPath = $MECMOUPath
    GroupsOUPath = $GroupsOUPath
    AccountsOUPath = $AccountsOUPath
    ServersOUPath = $ServersOUPath
    MECMServersADGroup = $MECMServersADGroup #($GroupNames | where {$_ -like "*servers*"}) #common
    MECMAdminsADGroup = $MECMAdminsADGroup #($GroupNames | where {$_ -like "*admins*"})
}

#CreateSystemMgmtcontainer
$CreateSystemMgmtContainerParams = @{
    MECMServersADGroup = $MECMServersADGroup
}

#GrantPermissionsOnSystemContainer
$GrantPermissionsOnSystemManagementContainerParams = @{
    MECMSiteServer = $MECMSiteServer
}

#ImportMECMServersGPO
$ImportMECMServersGPOParams = @{
    MECMOUPath = $MECMOUPath #common
    ServersOUPath = $ServersOUPath
    NewGPOName = $NewGPOName
    BackupGPOName = $BackupGPOName
    GPOBackupPath = $GPOBackupPath
    SecPrincipalsCSVPath = $SecPrincipalsCSVPath
    MigTableSource = $MigTableSource
    MigrationTable = $MigrationTable
}

#GrantPermissionsToADJoinAccount
$GrantPermissionsToADJoinAccountParams = @{
    ADJoinAccount = $ADJoinAccount
}

#SetSPN
$SetSPNParams = @{
    DomainName = $DomainName
    SQLServiceAccount = $SQLServiceAccount
    DBServer = $DBServer
    PortNumber = $PortNumber
}

#powershell -executionpolicy bypass -file $PSScriptRoot\ExtractMECMArchives.ps1 @ExtractMECMArchivesParams zip file is broken, binaries will need to be present in the proper dir
powershell -executionpolicy bypass -file $PSScriptRoot\ExtendADSchema.ps1 @ExtendADSchemaParams
powershell -executionpolicy bypass -file $PSScriptRoot\CreateOUStructure.ps1 @CreateOUStructureParams
powershell -executionpolicy bypass -file $PSScriptRoot\CreateGroupsAndUsers.ps1 @CreateOUStructureParams
powershell -executionpolicy bypass -file $PSScriptRoot\CreateSystemManagementContainer.ps1 @CreateSystemMgmtContainerParams
powershell -executionpolicy bypass -file $PSScriptRoot\GrantPermissionsOnSystemManagementContainer.ps1 @GrantPermissionsOnSystemManagementContainerParams
powershell -executionpolicy bypass -file $PSScriptRoot\GrantPermissionsToADJoinAccount.ps1 @GrantPermissionsToADJoinAccountParams
powershell -executionpolicy bypass -file $PSScriptRoot\ImportMECMServersGPO.ps1 @ImportMECMServersGPOParams
powershell -executionpolicy bypass -file $PSScriptRoot\SetSPN.ps1 @SetSPNParams

$ErrorActionPreference = $OldErrorActionPreference
