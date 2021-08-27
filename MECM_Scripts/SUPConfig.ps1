#run it on the primary site server
param(
    $DBServerName = $env:COMPUTERNAME,
    $DBFilePath = "$PSScriptRoot\WSUSDBConfig.sql",
    $LogPath = "$PSScriptRoot\Logs\WSUSDBConfig.log",
    $WSUSDBName = "SUSDB",
    $DBPath = "E:\SQL_Database\SUSDB.mdf",
    $WSUSDBAutogrowth = 512
)

$SQLScript = @" 
-- Change DB owner to sa
ALTER AUTHORIZATION ON DATABASE::$WSUSDBName TO sa;
GO

ALTER DATABASE $WSUSDBName
MODIFY FILE ( NAME = $DBPath, FILEGROWTH = $WSUSDBAutogrowth )
GO
"@

$SQLScript | Out-File $DBFilePath -Force

sqlcmd -S $DBServerName -i $DBFilePath -o $LogPath
#change wsus db owner to sa
