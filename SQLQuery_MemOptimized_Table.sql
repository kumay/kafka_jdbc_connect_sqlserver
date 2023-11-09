CREATE DATABASE mydb;
GO

ALTER DATABASE mydb
ADD FILEGROUP mydb_mod_fg CONTAINS MEMORY_OPTIMIZED_DATA;
GO

ALTER DATABASE mydb
ADD FILE (name='mydb_mod', filename='/var/opt/mssql/data/mydb_mod')
TO FILEGROUP mydb_mod_fg;
GO

USE mydb;
GO

CREATE TABLE test
(
	ID int NOT NULL PRIMARY KEY NONCLUSTERED HASH WITH (BUCKET_COUNT = 102400),
	name nvarchar(50),
	created datetime2
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO

CREATE TABLE users
(
	ID int NOT NULL PRIMARY KEY NONCLUSTERED IDENTITY(1, 1),
	"userid" nvarchar(50),
	"regionid" nvarchar(50),
	"gender" nvarchar(50),
	"registertime" datetime2
) WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO


ALTER DATABASE CURRENT 
SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON
GO