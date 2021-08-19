-- This script creates and configures the database in preparation for MECM installation.
-- Adjust the values accordingly before execution.
USE master
CREATE DATABASE CM_AUR
ON
( NAME = CM_AUR_1,FILENAME = 'E:\SQL_Database\CM_AUR_1.mdf',SIZE =  6280, MAXSIZE = Unlimited, FILEGROWTH = 2072)
LOG ON
( NAME = AUR_log, FILENAME = 'G:\SQL_Logs\CM_AUR.ldf', SIZE = 8290, MAXSIZE = 8290, FILEGROWTH = 512)
ALTER DATABASE CM_AUR
ADD FILE ( NAME = CM_AUR_2, FILENAME = 'E:\SQL_Database\CM_AUR_2.mdf',SIZE =  6280, MAXSIZE = Unlimited, FILEGROWTH = 2072)
ALTER DATABASE CM_AUR
ADD FILE ( NAME = CM_AUR_3, FILENAME = 'E:\SQL_Database\CM_AUR_3.mdf',SIZE =  6280, MAXSIZE = Unlimited, FILEGROWTH = 2072)
ALTER DATABASE CM_AUR
ADD FILE ( NAME = CM_AUR_4, FILENAME = 'E:\SQL_Database\CM_AUR_4.mdf',SIZE =  6280, MAXSIZE = Unlimited, FILEGROWTH = 2072)