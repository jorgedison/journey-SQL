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