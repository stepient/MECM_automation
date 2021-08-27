#run it on the primary site server
param(
    $SiteCode = "AUR",
    $SUPServerName = "CM02",
    $DBServerName = $env:COMPUTERNAME,
    $DBFilePath = "$PSScriptRoot\WSUSDBConfig.sql",
    $LogPath = "$PSScriptRoot\Logs\WSUSDBConfig.log",
    $WSUSDBName = "SUSDB",
    $DBFileName = "SUSDB",
    $WSUSDBAutogrowth = 512
)


$CMDrive = $SiteCode + ":\"
$ModulePath = 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager\ConfigurationManager.psd1'
Import-Module $ModulePath
$ErrorActionPreference = "Stop"
Push-Location

$SQLScript = @" 
-- Change DB owner to sa
ALTER AUTHORIZATION ON DATABASE::$WSUSDBName TO sa;
GO

ALTER DATABASE $WSUSDBName
MODIFY FILE ( NAME = $DBFileName, FILEGROWTH = $WSUSDBAutogrowth )
GO
"@

$SQLScript | Out-File $DBFilePath -Force

sqlcmd -S $DBServerName -i $DBFilePath -o \\dc01\files\Repositories\MECM_Scripts\Logs\wsus.log  #$LogPath

Set-Location $CMDrive

#adjust the command for HTTPS-only communication
#possibly it's beeter to configure SUP from the console, 
#because there is no easy way to automate it with PowerShell
#and it is a one-off task
Add-CMSoftwareUpdatePoint -ClientConnectionType Intranet -SiteCode $SiteCode -SiteSystemServerName $SUPServerName -WsusIisSslPort 8531 -WsusIisPort 8530
Pop-Location