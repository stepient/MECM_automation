param(
    #CreateOUStructure
    $ParentOUPath ="OU=test,DC=dev,DC=local", #this OU has to exist
    $MECMOUName = "MECM",
    $ServersOUName = "Servers",
    $GroupsOUName = "Groups",
    $AccountsOUName = "Accounts",

    #CreateGroupsAndUsers
    $GroupNamesPath = "$PSScriptRoot\InputFiles\GroupNames.txt",
    $AccountNamesPath = "$PSScriptRoot\InputFiles\ServiceAccountNames.txt",
    $MECMAdminsPath = "$PSScriptRoot\InputFiles\MECMAdmins.txt",
    $MECMServersPath = "$PSScriptRoot\InputFiles\MECMServers.txt",
    #$MECMOUPath = $MECMOUName + "," + $ParentOUPath, #common
    #$GroupsOUPath = "OU=$GroupsOUName" + "," + $MECMOUPath,
    #$AccountsOUPath = "OU=$AccountsOUName" + "," + $MECMOUPath,
    #$ServersOUPath = "OU=$ServersOUName" + "," + $MECMOUPath, #common
    $MECMServersADGroup = "MECM-Servers", #($GroupNames | where {$_ -like "*servers*"}) #common
    $MECMAdminsADGroup = "MECM-Admins", #($GroupNames | where {$_ -like "*admins*"})

    #extend ad schema
    $extadschPath = "$PSScriptRoot\BIN\X64",

    #grant permissions to domain join account
    $NewGPOName = "MECM_Servers",
    $BackupGPOName = "MECM_Servers",
    $GPOBackupPath = "$PSScriptRoot\GPO",

    #setSPN
    $DomainName = "dev.local",
    $SQLServiceAccount = "dev\MECM-SQLService",
    $DBServer = "CM01",
    $PortNumber = 1433
)

$MECMOUPath = $("OU=$MECMOUName" + "," + $ParentOUPath) #common
$GroupsOUPath = $("OU=$GroupsOUName" + "," + $MECMOUPath)
$AccountsOUPath = $("OU=$AccountsOUName" + "," + $MECMOUPath)
$ServersOUPath = $("OU=$ServersOUName" + "," + $MECMOUPath) #common


#ExtendADSchema
$ExtendADSchemaParams = @{
    ExtadschPath = $extadschPath
}

#CreateSystemMgmtcontainer
$CreateSystemMgmtContainerParams = @{
    MECMServersADGroup = $MECMServersADGroup
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
    $ADJoinAccount = "MECM-DomainJoin"
}

#SetSPN
$SetSPNParams = @{
    DomainName = $DomainName
    SQLServiceAccount = $SQLServiceAccount
    DBServer = $DBServer
    PortNumber = $PortNumber
}


"1"
$ExtendADSchemaParams

"2"
$CreateSystemMgmtContainerParams

"3"
$CreateOUStructureParams

"4"
$CreateGroupsAndUsersParams

"5"
$ImportMECMServersGPOParams

"6"
$GrantPermissionsToADJoinAccountParams

"7"
$SetSPNParams