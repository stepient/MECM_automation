param(

    $GroupNamesPath = "$PSScriptRoot\InputFiles\GroupNames.txt"
    $AccountNamesPath = "$PSScriptRoot\InputFiles\ServiceAccountNames.txt"
    $MECMAdminsPath = "$PSScriptRoot\InputFiles\MECMAdmins.txt"
    $MECMServersPath = "$PSScriptRoot\InputFiles\MECMServers.txt"

    #CreateOUStructure
    $ParentOUPath = (Get-ADRootDSE).defaultNamingContext, #EDIT AS APPROPRIATE, this OU has to exists. Default value is domain root
    $MECMOUName = "MECM",              #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE
    $ServersOUName = "Servers",        #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE
    $GroupsOUName = "Groups",          #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE
    $AccountsOUName = "Accounts",      #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE

    #CreateGroupsAndUsers
    $MECMServersADGroup = (Get-Content $GroupNamesPath | where {$_ -like "*servers*"}), # "MECM-Servers",  #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE
    $MECMAdminsADGroup = (Get-Content $GroupNamesPath | where {$_ -like "*admin*"}), # "MECM-Admins"       #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE

    #ImportMECMServersGPO
    $NewGPOName = "MECM_Servers", #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE

    #GrantPermissionsToADJoinAccount
    $ADJoinAccount = (Get-Content $AccountNamesPath | where {$_ -like "*join*"}), #EDIT AS APPROPRIATE OR LEAVE DEFAULT VALUE

    #setSPN
    $SQLServiceAccount = "MECM-SQLService", #EDIT AS APPROPRIATE
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

#ExtractMECMArchives vars
$MECMArchiveDir = "$PSScriptRoot\BIN"
$MECMArchive = "X64.zip"
$MECMArchiveTargetDir = "$MECMArchiveDir\x64"

#ExtendADSchema vars
$extadschPath = "$PSScriptRoot\BIN\X64"

#ImportMECMServersGPO vars
$BackupGPOName = "MECM_Servers"
$GPOBackupPath = "$PSScriptRoot\GPO"

#SetSPN vars
$DomainName = (Get-ADDomain).DnsRoot

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

#ImportMECMServersGPO
$ImportMECMServersGPOParams = @{
    MECMOUPath = $MECMOUPath #common
    ServersOUPath = $ServersOUName #common
    NewGPOName = $NewGPOName
    BackupGPOName = $BackupGPOName
    GPOBackupPath = $GPOBackupPath
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

powershell -file $PSScriptRoot\ExtractMECMArchives.ps1 @ExtractMECMArchivesParams
powershell -file $PSScriptRoot\ExtendADSchema.ps1 @ExtendADSchemaParams
powershell -file $PSScriptRoot\CreateOUStructure.ps1 @CreateOUStructureParams
powershell -file $PSScriptRoot\CreateGroupsAndUsers.ps1 @CreateOUStructureParams
powershell -file $PSScriptRoot\CreateSystemManagementContainer.ps1 @CreateSystemMgmtContainerParams
powershell -file $PSScriptRoot\GrantPermissionsToADJoinAccount.ps1 @GrantPermissionsToADJoinAccountParams
powershell -file $PSScriptRoot\ImportMECMServersGPO.ps1 @ImportMECMServersGPOParams
powershell -file $PSScriptRoot\SetSPN.ps1 @SetSPNParams

$ErrorActionPreference = $OldErrorActionPreference
