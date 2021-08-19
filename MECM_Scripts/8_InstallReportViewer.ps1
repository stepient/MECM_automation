$MSILocation = "C:\MECM_Setup\Install_Files"

Push-Location
Set-Location $MSILocation

msiexec /passive /norestart /i SQLSysCLRTypes.msi
msiexec /passive /norestart /i ReportViewer.msi

Pop-Location