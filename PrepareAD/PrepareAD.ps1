
param(
    $ParentOUPath="DC=dev,DC=local",
    $MECMOUName = "MECM",
    $ComputersOUName = "Servers",
    $GroupsOUName = "Groups",
    $AccountsOUName = "Accounts"
)

powershell -file $PSScriptRoot\ExtendSchema.ps1 -Verbose
powershell -file $PSScriptRoot\CreateOUStructure.ps1 -ParentOUPath $ParentOUPath -Verbose
powershell -file $PSScriptRoot\CreateGroupsAndUsers.ps1 -Verbose
powershell -file $PSScriptRoot\CreateSystemManagementContainer.ps1 -Verbose
powershell -file $PSScriptRoot\GrantPermissionsToADJoinAccount.ps1 -Verbose
powershell -file $PSScriptRoot\ImportMECMServersGPO.ps1 -Verbose
powershell -file $PSScriptRoot\SetSPN.ps1 -Verbose