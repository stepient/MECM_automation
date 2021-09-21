#Improvements: Create and use a migration table
#Create and import a GPO for workstations and managed servers (FW rules; client push)
param(
    $MECMOUPath = "OU=MECM," + (Get-ADRootDSE).defaultNamingContext,
    $ServersOUPath = "OU=Servers" + "," + $MECMOUPath,
    $NewGPOName = "MECM_Servers",
    $BackupGPOName = "MECM_Servers",
    $GPOBackupPath = "$PSScriptRoot\GPO"
)

$params = @{
    Path = $GPOBackupPath
    BackupGpoName = $BackupGPOName
    TargetName = $NewGPOName
    CreateIfNeeded = $true
    ErrorAction = 'Stop'
}

$OldVerbosePreference = $VerbosePreference
$VerbosePreference = "Continue"

Try{
    $ExistingGPO = Get-GPO -Name $NewGPOName -ErrorAction Stop
    Write-Verbose "GPO $NewGPOName already exists"
}
Catch [System.ArgumentException]{
    Try{
        Write-Verbose "Importing GPO $NewGPOName from $GPOBackupPath and linking to the $ServersOUPath OU"
        Import-GPO @params | New-GPLink -Target $ServersOUPath -LinkEnabled Yes | Out-Null
        Write-Verbose "Successfully imported GPO $NewGPOName from $GPOBackupPath and linked it to the $ServersOUPath OU"
    }
    Catch
    {
        throw $_
    }
}
Catch{
    throw $_
}

$VerbosePreference = $OldVerbosePreference
