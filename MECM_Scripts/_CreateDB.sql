-- This script creates and configures the database in preparation for MECM installation.
-- Adjust the values accordingly before execution.
USE master
CREATE DATABASE CM_AUR
ON
( NAME = CM_AUR_1,FILENAME = 'E:\SQL_Database\CM_AUR_1.mdf',SIZE = 2810 , MAXSIZE = Unlimited, FILEGROWTH = 927)
LOG ON
( NAME = AUR_log, FILENAME = 'G:\SQL_Logs\CM_AUR.ldf', SIZE = 1855 , MAXSIZE = 1855, FILEGROWTH = 512)
ALTER DATABASE CM_AUR
ADD FILE ( NAME = CM_AUR_2, FILENAME = 'E:\SQL_Database\CM_AUR_2.mdf', SIZE = 2810 , MAXSIZE = Unlimited, FILEGROWTH = 927)
-- Change DB owner to sa
ALTER AUTHORIZATION ON DATABASE::CM_AUR TO sa;
GO
