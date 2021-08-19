param(
    $MECMArchiveDir = "$PSScriptRoot\BIN",
    $MECMArchive = "X64.zip",
    $MECMArchiveTargetDir = "$MECMArchiveDir\x64"
    #$MECMExtractProcess = "MEM_Configmgr_2103",
)

$OldVerbosePreference = $VerbosePreference
$VerbosePreference = "Continue"

Write-Verbose "Extracting MECM binaries to $MECMArchiveTargetDir"

if (-not $(Test-Path $MECMArchiveTargetDir))
{
    Try{
        
        Push-Location
        Set-Location $MECMArchiveDir
        Expand-Archive -Path $MECMArchiveDir\$MECMArchive -DestinationPath $MECMArchiveDir
        Write-Verbose "Successfully extracted MECM install files to $MECMInstallTargetDir"
        Pop-Location  
    }
    Catch
    {
        throw $_
    }
}
else
{
    Write-Verbose "Directory $MECMArchiveTargetDir already exists, aborting operation"
}

$VerbosePreference = $OldVerbosePreference