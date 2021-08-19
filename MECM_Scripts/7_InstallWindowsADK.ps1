$InstallPath = 'D:\Program Files (x86)\Windows Kits\10'
& C:\MECM_Setup\Install_Files\ADK\adksetup.exe /quiet /features OptionId.UserStateMigrationTool OptionId.DeploymentTools /ceip off /installpath $InstallPath
Start-Sleep 120
& C:\MECM_Setup\Install_Files\ADK_WinPE\adkwinpesetup.exe /quiet /features OptionId.WindowsPreinstallationEnvironment /ceip off /forcerestart /installpath $InstallPath 
Restart-Computer