param(
    $SQLArchiveDir = "C:\MECM_Setup\Install_Files",
    $SQLArchiveEXE = "SQL2019-SSEI-Eval.exe",
    $SQLExtractProcess = "SQL2019-SSEI-Eval",
    $SQLInstallTargetDir = "C:\MECM_Setup\Install_Files\SQL"
)

Write-Output "Extracting SQL files to $SQLInstallTargetDir"
if (-not $(Test-Path $SQLInstallTargetDir) -or -not $(Get-ChildItem $SQLInstallTargetDir))
{
    Try{
        
        Push-Location
        Set-Location $SQLArchiveDir
        & .\$SQLArchiveEXE /Quiet /Verbose /Action=Download /Language=en-US /MediaType=CAB /MediaPath=$SQLInstallTargetDir
        Wait-Process -Name $SQLExtractProcess
        Set-Location $SQLInstallTargetDir
        $EXEFile = Get-ChildItem -File -Name "*.exe" -ErrorAction Stop
        & .\$EXEFile /q /x:$SQLInstallTargetDir\SETUP
        Wait-Process -Name SQLServer2019-x64-ENU
        Write-Output "Successfully extracted SQL install files to $SQLInstallTargetDir"
        Pop-Location
    }
    Catch
    {
        throw $_
    }
}
else
{
    Write-Output "Directory $SQLInstallTargetDir already exists, aborting operation"
}

#
