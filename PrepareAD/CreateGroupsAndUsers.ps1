
param (
    #Default is true, can be changed to false when the script is part of a workflow
    #Do not type cast this parameter as switch or boolean,
    #or you won't be able to overwrite its value when calling the script from another script
    $Interactive = $true, 

    [string]$SQLAccountPass,       #Pass as an encrypted value in non-interactive mode only
    [string]$SQLReportingPass,     #Pass as an encrypted value in non-interactive mode only
    [string]$DomainJoinPass,       #Pass as an encrypted value in non-interactive mode only
    [string]$ClientPushPass,       #Pass as an encrypted value in non-interactive mode only
    [string]$MECMAdminPass,        #Pass as an encrypted value in non-interactive mode only
    [string]$NetworkAccessPass,    #Pass as an encrypted value in non-interactive mode only

    $MECMAdminsPath = "$PSScriptRoot\InputFiles\MECMAdmins.txt",
    $MECMServersPath = "$PSScriptRoot\InputFiles\MECMServers.txt",
    $SecPrincipalsCSVPath = "$PSScriptRoot\InputFiles\SecurityPrincipals.csv", #groups and users

    $MECMOUPath = "OU=MECM," + (Get-ADRootDSE).defaultNamingContext,
    $GroupsOUPath = "OU=Groups" + "," + $MECMOUPath,
    $AccountsOUPath = "OU=Accounts" + "," + $MECMOUPath,
    $ServersOUPath = "OU=Servers" + "," + $MECMOUPath

    #$MECMServersADGroup = "MECM-Servers",
    #$MECMIISServersAdGroup = "MECM-IISServers",
    #$MECMAdminsADGroup = "MECM-Admins"
)
$Interactive

$OldVerbosePreference = $VerbosePreference
$VerbosePreference = "Continue"

#import functions
. "$PSScriptRoot\Functions\CreateADGroup.ps1"
. "$PSScriptRoot\Functions\CreateADUser.ps1"
. "$PSScriptRoot\Functions\CreateADComputer.ps1"


$SecPrincipals = Import-Csv $SecPrincipalsCSVPath -Delimiter ','

$GroupNames = $SecPrincipals | where {$_.type -eq 'group'} | select -ExpandProperty Name
$MECMServersADGroup = ($SecPrincipals | where {$_.type -eq 'group' -and $_.ID -eq 5}).Name
$MECMIISServersAdGroup = ($SecPrincipals | where {$_.type -eq 'group' -and $_.ID -eq 7}).Name
$MECMAdminsADGroup = ($SecPrincipals | where {$_.type -eq 'group' -and $_.ID -eq 4}).Name  
$Accounts = $SecPrincipals | where {$_.type -eq 'user'}

$MECMAdmins = (Get-Content $MECMAdminsPath).Trim()
$MECMServers = (Get-Content $MECMServersPath).Trim()

Foreach ($GroupName in $GroupNames){

    Try{

        CreateADGroup -GroupName $GroupName -OU $GroupsOUPath -Verbose -ErrorAction Stop
    }
    Catch{

        $_
    }
}

Foreach ($Account in $Accounts){
    
    If ($Interactive -eq $true){
    "Interactive"
        #put this in script, not in function, on purpose in case the passwords are pulled from another source in zero touch deployment of MECM
        Try{

            $Credentials = Get-Credential -UserName $Account.Name -Message "Provide the password for the $($Account.Name) account" 
            $UserName = $Credentials.UserName
            $Password = $Credentials.Password
        }
        Catch{

            throw $_
        }
    } else {
    "Noninteractive"
    
        Switch($Account.ID) {

            0 {$PasswordStr = $SQLAccountPass}
            1 {$PasswordStr = $SQLReportingPass}
            2 {$PasswordStr = $DomainJoinPass}
            3 {$PasswordStr = $ClientPushPass}
            6 {$PasswordStr = $MECMAdminPass}
            8 {$PasswordStr = $NetworkAccessPass}
            Default {"Unable to match ID $_ to any parameter"}

        }

        $UserName = $Account.Name
            $UserName
            $PasswordStr
        $Password = $PasswordStr | ConvertTo-SecureString -AsPlainText -Force
    }

    CreateADUser -Username $UserName -Password $Password -OUPath $AccountsOUPath -Verbose -ErrorAction Stop
} #end foreach

#Prestage MECM servers in AD and add them to the $MECMServers group
Foreach ($ComputerName in $MECMServers){

    Try{

        CreateADComputer -ComputerName $ComputerName -OUPath $ServersOUPath -Verbose -ErrorAction Stop
        Write-Verbose "Adding server $ComputerName to the group $MECMServersADGroup"
        Add-ADGroupMember -Identity $MECMServersADGroup -Members $ComputerName$ -ErrorAction Stop
        Write-Verbose "Successfully added server $ComputerName to the group $MECMServersADGroup"
    }
    Catch{

        throw $_
    }
}

#Add users to the $MECMAdmins group
Try{

    Write-Verbose "Adding users to the $MECMAdminsADGroup"
    $MECMAdmins | ForEach-Object {Add-ADGroupMember -Identity $MECMAdminsADGroup -Members $_} -ErrorAction Stop
    Write-Verbose "Successfully added users to the $MECMAdminsADGroup"
}
Catch{

    throw $_
}

$VerbosePreference = $OldVerbosePreference
