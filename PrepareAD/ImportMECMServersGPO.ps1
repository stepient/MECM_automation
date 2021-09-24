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
#Create a migration table
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
