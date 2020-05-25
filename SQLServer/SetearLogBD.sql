USE [DATABASE];
GO

sp_helpdb [DATABASE]

-- View Detail 
SELECT * FROM sys.database_files;
SELECT name ,size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS AvailableSpaceInMB
FROM sys.database_files;
DBCC LOGINFO;

-- Truncate the log by changing the database recovery model to SIMPLE.
ALTER DATABASE [DATABASE]
SET RECOVERY SIMPLE;
GO
-- Shrink the truncated log file to 100 MB.
DBCC SHRINKFILE (2, 100);
GO
-- Reset the database recovery model.
ALTER DATABASE [DATABASE]
SET RECOVERY FULL;
GO


----------------------------

SELECT 
      'USE [' + d.name + N']' + CHAR(13) + CHAR(10) 
    + 'DBCC SHRINKFILE (N''' + mf.name + N''' , 0, TRUNCATEONLY);' 
    + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) 
FROM 
         sys.master_files mf 
    JOIN sys.databases d 
        ON mf.database_id = d.database_id 
WHERE d.database_id > 4;
