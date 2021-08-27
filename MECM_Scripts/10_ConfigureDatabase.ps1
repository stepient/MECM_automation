
# This script creates and configures the database in preparation for MECM installation.
# Adjust the values in the $DBFilePath SQL script accordingly before execution and the Environment parameter
# Author: Tomasz Stepien
# Email: tomasz.stepien@capgemini.com
# Requires -RunAsAdministrator


param(
$DBServerName = "CM01",
$SiteCode = "AUR",
#[Parameter(Mandatory)]
[ValidateSet("Dev","Prod")]
$Environment="Dev",

$PRODDBFileSize = 6280,
$PRODDBFileGrowth = 2072,
$PRODDBLogSize = 8290,
$PRODDBLogMaxSize = 8290,
$PRODDBLogFileGrowth = 512,

$DEVDBFileSize = 2810,
$DEVDBFileGrowth = 927,
$DEVDBLogSize = 1855,
$DEVDBLogMaxSize = 1855,
$DEVDBLogFileGrowth = 512,

$DBFilePath = "$PSScriptRoot\_CreateDB.sql",
$LogPath = "$PSScriptRoot\Logs\CreateDB.log"
)

Switch ($Environment)
{

    "Dev" 
{ 
#can't indent the below block because it contains a here string
$SQLScript = @" 
-- This script creates and configures the database in preparation for MECM installation.
-- Adjust the values accordingly before execution.
USE master
CREATE DATABASE CM_$SiteCode
ON
( NAME = CM_$SiteCode`_1,FILENAME = 'E:\SQL_Database\CM_$SiteCode`_1.mdf',SIZE = $DEVDBFileSize , MAXSIZE = Unlimited, FILEGROWTH = $DEVDBFileGrowth)
LOG ON
( NAME = $SiteCode`_log, FILENAME = 'G:\SQL_Logs\CM_$SiteCode.ldf', SIZE = $DEVDBLogSize , MAXSIZE = $DEVDBLogMaxSize, FILEGROWTH = $DEVDBLogFileGrowth)
ALTER DATABASE CM_$SiteCode
ADD FILE ( NAME = CM_$SiteCode`_2, FILENAME = 'E:\SQL_Database\CM_$SiteCode`_2.mdf', SIZE = $DEVDBFileSize , MAXSIZE = Unlimited, FILEGROWTH = $DEVDBFileGrowth)
-- Change DB owner to sa
ALTER AUTHORIZATION ON DATABASE::CM_$SiteCode TO sa;
GO
"@
}
    "Prod"
{
$SQLScript = @"
-- This script creates and configures the database in preparation for MECM installation.
-- Adjust the values accordingly before execution.
USE master
CREATE DATABASE CM_$SiteCode
ON
( NAME = CM_$SiteCode`_1,FILENAME = 'E:\SQL_Database\CM_$SiteCode`_1.mdf',SIZE = $PRODDBFileSize, MAXSIZE = Unlimited, FILEGROWTH = $PRODDBFileGrowth)
LOG ON
( NAME = $SiteCode`_log, FILENAME = 'G:\SQL_Logs\CM_$SiteCode.ldf', SIZE = $PRODDBLogSize, MAXSIZE = $PRODDBLogMaxSize, FILEGROWTH = $PRODDBLogFileGrowth)
ALTER DATABASE CM_$SiteCode
ADD FILE ( NAME = CM_$SiteCode`_2, FILENAME = 'E:\SQL_Database\CM_$SiteCode`_2.mdf',SIZE = $PRODDBFileSize, MAXSIZE = Unlimited, FILEGROWTH = $PRODDBFileGrowth)
ALTER DATABASE CM_$SiteCode
ADD FILE ( NAME = CM_$SiteCode`_3, FILENAME = 'E:\SQL_Database\CM_$SiteCode`_3.mdf',SIZE = $PRODDBFileSize, MAXSIZE = Unlimited, FILEGROWTH = $PRODDBFileGrowth)
ALTER DATABASE CM_$SiteCode
ADD FILE ( NAME = CM_$SiteCode`_4, FILENAME = 'E:\SQL_Database\CM_$SiteCode`_4.mdf',SIZE = $PRODDBFileSize, MAXSIZE = Unlimited, FILEGROWTH = $PRODDBFileGrowth)
-- Change DB owner to sa
ALTER AUTHORIZATION ON DATABASE::CM_$SiteCode TO sa;
GO
"@
}
Default {"Incorrect value specified as Environment: $Environment"}
}

#Create a file to be executed by sqlcmd
$SQLScript | Out-File $DBFilePath -Force

sqlcmd -S $DBServerName -i $DBFilePath -o $LogPath

"Command completed. See log below:"
Get-Content $LogPath


