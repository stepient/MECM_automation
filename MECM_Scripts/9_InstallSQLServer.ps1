# Requires -RunAsAdministrator

param(
$SQLSourceFilesDir = "C:\MECM_Setup\Install_Files\SQL\SETUP",
$ConfigurationFilePath = "C:\MECM_setup\MECM_automation-main\MECM_Scripts\SQLConfigFile_Lab.ini",
$SQLServiceAccount = "dev\MECM-SQLService",
$KBLocation = "C:\MECM_Setup\Install_Files",
$KBFileName = "SQLServer2019-KB5003249-x64.EXE",
$SSMSSetupFileName = "SSMS-Setup-ENU.EXE"
)

If (-not (Test-Path $SQLSourceFilesDir))
{
    throw Write-Verbose "Directory $SQLSourceFilesDir does not exist; aborting operation"
}

$OldErrorActionPreference =$Error

$Credential = Get-Credential -UserName $SQLServiceAccount -Message "Type in the password for the $SQLServiceAccount account"
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Credential.Password)
$strPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

Push-Location

Set-Location $SQLSourceFilesDir
Try{
& .\SETUP.EXE /QS /IACCEPTSQLSERVERLICENSETERMS /SQLSVCPASSWORD="$strPassword" /AGTSVCPASSWORD="$strPassword" /ASSVCPASSWORD="str$Password" /ConfigurationFile=$ConfigurationFilePath

#Install SQL Server update
Set-Location  $KBLocation
& .\$KBFileName /ACTION=INSTALL /QUIETSIMPLE /ALLINSTANCES /ENU /IACCEPTSQLSERVERLICENSETERMS /INDICATEPROGRESS
Wait-Process -Name ($KBFileName -replace '\.exe')

#Install SQL Server Management Studio
& .\$SSMSSetupFileName /install /passive

Pop-Location

Restart-Computer
}
Catch
{
    throw $_
}


 
