-- Change DB owner to sa
ALTER AUTHORIZATION ON DATABASE::SUSDB TO sa;
GO

ALTER DATABASE SUSDB
MODIFY FILE ( NAME = E:\SQL_Database\SUSDB.mdf, FILEGROWTH = 512 )
GO
