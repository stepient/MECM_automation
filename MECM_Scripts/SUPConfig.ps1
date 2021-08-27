param(
    $DBFilePath = "$PSScriptRoot\WSUSDBConfig.sql",
    $LogPath = "$PSScriptRoot\Logs\WSUSDBConfig.log"
)

$SQLScript = @" 
-- Change DB owner to sa
ALTER AUTHORIZATION ON DATABASE::CM_$SiteCode TO sa;
GO
"@

$SQLScript | Out-File $DBFilePath -Force

sqlcmd -S $DBServerName -i $DBFilePath -o $LogPath
#change wsus db owner to sa
