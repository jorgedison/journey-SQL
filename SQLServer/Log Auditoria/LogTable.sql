USE [DATABASE]
GO

SELECT 
     [db_name] = d.name
    , [table_name] = SCHEMA_NAME(o.[schema_id]) + '.' + o.name
    , s.last_user_update
FROM sys.dm_db_index_usage_stats s
JOIN sys.databases d ON s.database_id = d.database_id
JOIN sys.objects o ON s.[object_id] = o.[object_id]
WHERE o.[type] = 'U'
    AND s.last_user_update IS NOT NULL
    AND s.last_user_update BETWEEN DATEADD(wk, -1, GETDATE()) AND GETDATE()
ORDER BY last_user_update DESC


SELECT *, [Transaction Id], [Begin Time], SUSER_SNAME ([Transaction SID]) AS [User]
FROM fn_dblog (NULL, NULL)
WHERE [Transaction Name] = N'DROPOBJ' and  [Begin Time] >='2015/04/16 13:00:01:543';
GO

SELECT [Transaction Name] FROM fn_dblog (NULL, NULL) ORDER BY [Transaction Name]

DECLARE @LSN_HEX_SEP NVARCHAR(23) = '000022a7:000002b6:0005'

DECLARE @N1 BIGINT = CONVERT(varbinary,SUBSTRING(@LSN_HEX_SEP, 1, 8),2),
        @N2 BIGINT = CONVERT(varbinary,SUBSTRING(@LSN_HEX_SEP, 10, 8),2),
        @N3 BIGINT = CONVERT(varbinary,SUBSTRING(@LSN_HEX_SEP, 19, 4),2)

SELECT CAST(@N1 AS VARCHAR) + ':' +
      CAST(@N2 AS VARCHAR) + ':' +
      CAST(@N3 AS VARCHAR)

SELECT
  [Current LSN],
  [Transaction ID],
  [Operation],
  [Context],
  [AllocUnitName]
FROM fn_dblog(NULL, NULL)
WHERE Operation = 'LOP_DELETE_ROWS'