param(
    $SetupFileLocation = "C:\MECM_Setup\Install_Files\MECM\SMSSETUP\BIN\X64",
    $ConfigFilePath = "C:\MECM_Setup\Install_Files\ConfigMgrAutoSaveDev.ini"
)

#Ensure BITS is started and set to start up automatically
Set-Service -Name BITS -StartupType Automatic -Status Running

#Ensure setupwpf is not running from previous install attempt
Get-Process -Name setupwpf | Stop-Process

Push-Location

Set-Location $SetupFileLocation
#Run prereqcheck
& .\Prereqchk.exe /LOCAL
& .\Setup.exe /HIDDEN /SCRIPT $ConfigFilePath

Pop-Location
