# This script creates OU structure in preparation for MECM deployment
# Author: Tomasz Stepien
# Email: tomasz.stepien@capgemini.com
# Requires -RunAsAdministrator
# Requires -Modules ActiveDirectory

[CmdletBinding()]
param(
    [string]$ParentOUPath,#="OU=test,DC=dev,DC=local",
    [ValidateNotNullOrEmpty()]
    $MECMOUName = "MECM",
    [ValidateNotNullOrEmpty()]
    $ComputersOUName = "Servers",
    [ValidateNotNullOrEmpty()]
    $GroupsOUName = "Groups",
    [ValidateNotNullOrEmpty()]
    $AccountsOUName = "Accounts"
)

#Import functions
. "$PSScriptRoot\Functions\CreateADGroup.ps1"
. "$PSScriptRoot\Functions\CreateADOU.ps1"

$Root = (Get-ADRootDSE).defaultNamingContext

If ($ParentOUPath)
{
    $MECMOUPath = "OU=$MECMOUName" + ',' + $ParentOUPath
}
else
{
    $MECMOUPath = "OU=$MECMOUName" + ',' + $Root
    $ParentOUPath = $Root
}


$MECMOU = @{
    ParentOUPath = $ParentOUPath
    Name = $MECMOUName
}

$ComputersOU = @{
    ParentOUPath = $MECMOUPath
    Name = $ComputersOUName
}

$AccountsOU = @{
    ParentOUPath = $MECMOUPath
    Name = $AccountsOUName
}

$GroupsOU = @{
    ParentOUPath = $MECMOUPath
    Name = $GroupsOUName
}

$OUs = $MECMOU, $ComputersOU, $GroupsOU, $AccountsOU

Foreach ($OU in $OUs)
{
    Try{
        CreateADOU @OU -Verbose -ErrorAction Stop
    }
    Catch{
        throw $_
    }
}
