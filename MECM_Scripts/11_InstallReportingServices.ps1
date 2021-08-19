$SourceFilesLocation = "C:\MECM_Setup\Install_Files"

Push-Location

Set-Location $SourceFilesLocation
& .\SQLServerReportingServices.exe /passive /norestart /IAcceptLicenseTerms

Pop-Location
