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

SELECT * FROM dbo.users;
GO

-- for CDC preparation --

ALTER TABLE users
  add
    SysStartTime datetime2 generated always as row start not null default getutcdate(),
    SysEndTime   datetime2 generated always as row end   not null default convert(datetime2, '9999-12-31 23:59:59.9999999'),
    period for system_time (SysStartTime, SysEndTime);
GO

ALTER TABLE users
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.[users_History]))
GO

SELECT * FROM dbo.users_History;
GO

