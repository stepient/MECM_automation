$SourceFilesLocation = "C:\MECM_Setup\Install_Files"
$InstallPath = "D:\Program Files\SSRS"

Push-Location
#change install location to D:\
Set-Location $SourceFilesLocation
& .\SQLServerReportingServices.exe /passive /norestart /IAcceptLicenseTerms /InstallFolder=$InstallPath

Pop-Location
