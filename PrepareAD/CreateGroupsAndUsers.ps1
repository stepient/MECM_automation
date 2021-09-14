
param (
    $GroupNamesPath = "$PSScriptRoot\InputFiles\GroupNames.txt",
    $AccountNamesPath = "$PSScriptRoot\InputFiles\ServiceAccountNames.txt",
    $MECMAdminsPath = "$PSScriptRoot\InputFiles\MECMAdmins.txt",
    $MECMServersPath = "$PSScriptRoot\InputFiles\MECMServers.txt",

    $MECMOUPath = "OU=MECM," + (Get-ADRootDSE).defaultNamingContext,
    $GroupsOUPath = "OU=Groups" + "," + $MECMOUPath,
    $AccountsOUPath = "OU=Accounts" + "," + $MECMOUPath,
    $ServersOUPath = "OU=Servers" + "," + $MECMOUPath,
    $MECMServersADGroup = "MECM-Servers", #($GroupNames | where {$_ -like "*servers*"}),
    $MECMAdminsADGroup = "MECM-Admins" #($GroupNames | where {$_ -like "*admins*"})
)

$OldVerbosePreference = $VerbosePreference
$VerbosePreference = "Continue"

#import functions
. "$PSScriptRoot\Functions\CreateADGroup.ps1"
. "$PSScriptRoot\Functions\CreateADUser.ps1"
. "$PSScriptRoot\Functions\CreateADComputer.ps1"

$GroupNames = (Get-Content $GroupNamesPath).Trim()
$AccountNames = (Get-Content $AccountNamesPath).Trim()
$MECMAdmins = (Get-Content $MECMAdminsPath).Trim()
$MECMServers = (Get-Content $MECMServersPath).Trim()

Foreach ($GroupName in $GroupNames)
{
    Try{
        CreateADGroup -GroupName $GroupName -OU $GroupsOUPath -Verbose -ErrorAction Stop
    }
    Catch
    {
        $_
    }
}

Foreach ($AccountName in $AccountNames)
{
    #put this in script, not in function, on purpose in case the passwords are pulled from another source in zero touch deployment of MECM
    Try{
        $Credentials = Get-Credential -UserName $AccountName -Message "Provide the password for the $AccountName account" 
        CreateADUser -Username $Credentials.UserName -Password $Credentials.Password -OUPath $AccountsOUPath -Verbose -ErrorAction Stop
    }
    Catch
    {
        throw $_
    }
}

#Prestage MECM servers in AD and add them to the $MECMServers group
Foreach ($ComputerName in $MECMServers)
{
    Try{
        CreateADComputer -ComputerName $ComputerName -OUPath $ServersOUPath -Verbose -ErrorAction Stop
        Write-Verbose "Adding server $ComputerName to the group $MECMServersADGroup"
        Add-ADGroupMember -Identity $MECMServersADGroup -Members $ComputerName$ -ErrorAction Stop
        Write-Verbose "Successfully added server $ComputerName to the group $MECMServersADGroup"
    }
    Catch
    {
        throw $_
    }
}

#Add users to the $MECMAdmins group
Try{
    Write-Verbose "Adding users to the $MECMAdminsADGroup"
    $MECMAdmins | ForEach-Object {Add-ADGroupMember -Identity $MECMAdminsADGroup -Members $_} -ErrorAction Stop
    Write-Verbose "Successfully added users to the $MECMAdminsADGroup"
}
Catch
{
    throw $_
}

$VerbosePreference = $OldVerbosePreference
