param(
    $InstallPath = 'D:\Program Files (x86)\Windows Kits\10',
    $InstallFilesLocation = "C:\MECM_Setup\Install_Files"
)

Push-Location
Set-Location $InstallFilesLocation
& .\adksetup.exe /quiet /features OptionId.UserStateMigrationTool OptionId.DeploymentTools /ceip off /installpath $InstallPath
Wait-Process adksetup
& .\adkwinpesetup.exe /quiet /features OptionId.WindowsPreinstallationEnvironment /ceip off /forcerestart /installpath $InstallPath
Wait-Process adkwinpesetup
#Restart-Computer -Force