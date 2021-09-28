$interactive = $false
$SecPrincipalsCSVPath = "$PSScriptRoot\InputFiles\SecurityPrincipals.csv" #groups and users
$SecPrincipals = Import-Csv $SecPrincipalsCSVPath -Delimiter ','
$Accounts = $SecPrincipals | where {$_.type -eq 'user'} #| select -ExpandProperty Name
$MECMOUPath = "OU=MECM," + (Get-ADRootDSE).defaultNamingContext
$GroupsOUPath = "OU=Groups" + "," + $MECMOUPath
$AccountsOUPath = "OU=Accounts" + "," + $MECMOUPath

$SQLAccountPass = "Welcome123"
$SQLReportingPass = "Welcome789"
$DomainJoinPass = "Welcome123"
$ClientPushPass = "Welcome123"
$MECMAdminPass = "Welcome123"
$NetworkAccessPass = "Welcome123"

#import functions
. "$PSScriptRoot\Functions\CreateADGroup.ps1"
. "$PSScriptRoot\Functions\CreateADUser.ps1"
. "$PSScriptRoot\Functions\CreateADComputer.ps1"

Foreach ($Account in $Accounts){
    
    If ($interactive){
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
        $Password = $PasswordStr | ConvertTo-SecureString -AsPlainText -Force
        $Password
    }

    CreateADUser -Username $UserName -Password $Password -OUPath $AccountsOUPath -Verbose -ErrorAction Stop
} #end foreach

