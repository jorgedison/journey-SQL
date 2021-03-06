-- Tamaño de tablas (1)

USE [DATABASE]
GO

SELECT 
    X.[name],
    REPLACE(CONVERT(varchar, CONVERT(money, X.[rows]), 1), '.00', '') 
        AS [rows], 
    REPLACE(CONVERT(varchar, CONVERT(money, X.[reserved]), 1), '.00', '') 
        AS [reserved], 
    REPLACE(CONVERT(varchar, CONVERT(money, X.[data]), 1), '.00', '') 
        AS [data], 
    REPLACE(CONVERT(varchar, CONVERT(money, X.[index_size]), 1), '.00', '') 
        AS [index_size], 
    REPLACE(CONVERT(varchar, CONVERT(money, X.[unused]), 1), '.00', '') 
        AS [unused], 
	X.MB,
	GETDATE() AS [fecha]
FROM 
(SELECT 
    CAST(object_name(id) AS varchar(50)) 
        AS [name], 
    SUM(CASE WHEN indid < 2 THEN CONVERT(bigint, [rows]) END) 
        AS [rows],
    SUM(CONVERT(bigint, reserved)) * 8 
        AS reserved, 
    SUM(CONVERT(bigint, dpages)) * 8 
        AS data, 
    SUM(CONVERT(bigint, used) - CONVERT(bigint, dpages)) * 8 
        AS index_size, 
    SUM(CONVERT(bigint, reserved) - CONVERT(bigint, used)) * 8 
        AS unused,
	SUM(reserved_page_count)*8.0/1024 + SUM(lob_reserved_page_count)*8.0/1024 as MB,
	GETDATE() as hora
    FROM sysindexes WITH (NOLOCK),  sys.dm_db_partition_stats WITH (NOLOCK)
    WHERE sysindexes.indid IN (0, 1, 255) 
        AND sysindexes.id > 100 
        AND object_name(sysindexes.id) <> 'dtproperties' 
		AND sys.dm_db_partition_stats.object_id=sysindexes.id
    GROUP BY sysindexes.id WITH ROLLUP
) AS X
WHERE X.[name] is not null
ORDER BY X.[rows] DESC

SELECT sys.objects.name, SUM(reserved_page_count) * 8.0 / 1024 as [T]
		FROM sys.dm_db_partition_stats, sys.objects 
		WHERE sys.dm_db_partition_stats.object_id = sys.objects.object_id AND schema_id <> 4
		GROUP BY sys.objects.name

SELECT * FROM sys.dm_db_partition_stats, 
		sys.objects WHERE  sys.dm_db_partition_stats.object_id = sys.objects.object_id AND schema_id <> 4

-- Tamaño de tablas (2)

SET NOCOUNT ON 
DBCC UPDATEUSAGE(0) 
-- Table row counts and sizes.
DECLARE @sizes TABLE
(
    [name] NVARCHAR(128),
    [rows] int,
    reserved VARCHAR(18),
    data VARCHAR(18),
    index_size VARCHAR(18),
    unused VARCHAR(18)
)
INSERT @sizes EXEC sp_msForEachTable 'EXEC sp_spaceused ''?''' 
SELECT *
FROM   @sizes
ORDER BY [rows] desc

-- Tamaño de tablas (3)

SELECT o.NAME,
  i.rowcnt 
FROM sysindexes AS i
  INNER JOIN sysobjects AS o ON i.id = o.id 
WHERE i.indid < 2  AND OBJECTPROPERTY(o.id, 'IsMSShipped') = 0
ORDER BY I.rowcnt DESC

-- Tamaño de tablas (4)

CREATE TABLE #counts
(
    table_name varchar(255),
    row_count int
)

EXEC sp_MSForEachTable @command1='INSERT #counts (table_name, row_count) SELECT ''?'', COUNT(*) FROM ?'
SELECT table_name, row_count FROM #counts ORDER BY row_count DESC
DROP TABLE #counts
