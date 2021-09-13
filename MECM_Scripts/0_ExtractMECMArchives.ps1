param(
    $MECMArchiveDir = "C:\MECM_Setup\Install_Files",
    $MECMArchiveEXE = "MEM_Configmgr_2103.exe",
    $MECMExtractProcess = "MEM_Configmgr_2103",
    $MECMInstallTargetDir = "C:\MECM_Setup\Install_Files\MECM"
)

Write-Verbose "Extracting MECM files to $MECMInstallTargetDir"
if (-not $(Test-Path $MECMInstallTargetDir) -or -not $(Get-ChildItem $MECMInstallTargetDir))
{
    Try{
        
        Push-Location
        Set-Location $MECMArchiveDir
        & .\$MECMArchiveEXE /auto $MECMInstallTargetDir
        Wait-Process -Name $MECMExtractProcess
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
    Write-Verbose "Directory $MECMInstallTargetDir already contains files, aborting operation"
}
