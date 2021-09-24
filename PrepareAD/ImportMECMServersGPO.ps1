param(
    $MECMOUPath = "OU=MECM," + (Get-ADRootDSE).defaultNamingContext,
    $ServersOUPath = "OU=Servers" + "," + $MECMOUPath,
    $NewGPOName = "MECM_Servers",
    $BackupGPOName = "MECM_Servers",
    $GPOBackupPath = "$PSScriptRoot\GPO",
    $SecPrincipalsCSVPath = "$PSScriptRoot\InputFiles\SecurityPrincipals.csv",
    $MigTableSource = "$PSScriptRoot\MigTableTemplate.migtable",
    $MigrationTable = "$PSScriptRoot\MigTable.migtable"
)

$OldVerbosePreference = $VerbosePreference
$VerbosePreference = "Continue"

$params = @{

    Path = $GPOBackupPath
    BackupGpoName = $BackupGPOName
    TargetName = $NewGPOName
    CreateIfNeeded = $true
    ErrorAction = 'Stop'
    MigrationTable = $MigrationTable
}

#Create a migration table
$SecPrincipalIDs = @(
    @{
        Name = "MECM-SQLService"
        ID = 0
    }

    @{
        Name = "MECM-SQLReporting"
        ID = 1
    }

    @{
        Name = "MECM-DomainJoin"
        ID = 2
    }

    @{
        Name = "MECM-ClientPush"
        ID = 3
    }

    @{
        Name = "MECM-Admins"
        ID = 4
    }

    @{
        Name = "MECM-Servers"
        ID = 5
    }
)

$SecPrincipals = Import-Csv $SecPrincipalsCSVPath -Delimiter ','
$DomainName = (Get-ADDomain).DnsRoot

[xml]$MigTable = Get-Content $MigTableSource
$SecPrincipalsMigTable = $MigTable.MigrationTable.Mapping.Source

Foreach ($SecPrincipal in $SecPrincipalIDs)
{
    
    ($MigTable.MigrationTable.Mapping | where {$_.Source -eq $SecPrincipal.Name}).Destination = $($DomainName + "\" + $($SecPrincipals | where {$_.ID -eq $SecPrincipal.ID}).Name)
}

$MigTable.Save($MigrationTable)

Remove-Variable ExistingGPO -ErrorAction SilentlyContinue

Try{

    Write-Verbose "Importing GPO $NewGPOName from $GPOBackupPath"
    $ExistingGPO = Get-GPO -Name $NewGPOName -ErrorAction Stop
    Write-Verbose "GPO $NewGPOName already exists"
}
Catch [System.ArgumentException]{
    Try{

        $GPOOutput = Import-GPO @params 
        Write-Verbose "Successfully imported GPO $NewGPOName from $GPOBackupPath and linked it to the $ServersOUPath OU"
    }
    Catch{

        throw $_
    }
}
Catch{

    throw $_
}

If ($ExistingGPO){

    $GPOInput = $ExistingGPO
}
else{

    $GPOInput = $GPOOutput
}

Try{

    Write-Verbose "Linking $NewGPOName GPO to the $ServersOUPath OU"
    $GPOInput | New-GPLink -Target $ServersOUPath -LinkEnabled Yes -ErrorAction Stop | Out-Null
    Write-Verbose "Successfully linked $NewGPOName GPO to the $ServersOUPath OU"
}
Catch [System.ArgumentException]{

    Write-Verbose "GPO $NewGPOName is already linked to the $ServersOUPath OU"
}

$VerbosePreference = $OldVerbosePreference
