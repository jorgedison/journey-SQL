USE [DATABASE]
GO

-- Consumo de memoria

SELECT top 1
spl.succeeded AS [Succeeded] FROM msdb.dbo.sysmaintplan_plans AS s
INNER JOIN msdb.dbo.sysmaintplan_subplans AS sp ON sp.plan_id=s.id
INNER JOIN msdb.dbo.sysmaintplan_log AS spl ON spl.subplan_id=sp.subplan_id
WHERE s.name='nombre_del_plan_de_mantenimiento' ORDER BY spl.end_time DESC;
GO

-- Aplicación real

SELECT
COUNT (*) * 8 / 1024 AS MB_EN_USO FROM sys.dm_os_buffer_descriptors
GROUP BY database_id
HAVING DB_NAME (database_id) LIKE '%BD_SGAC%'
ORDER BY COUNT (*) * 8 / 1024 DESC
GO

-- Monitorización

DECLARE @total_buffer INT;
SELECT @total_buffer = cntr_value
FROM sys.dm_os_performance_counters
WHERE RTRIM([object_name]) LIKE '%Buffer Manager'
AND counter_name = 'Total Pages';
;WITH src AS
(SELECT database_id, db_buffer_pages = COUNT_BIG(*)
FROM sys.dm_os_buffer_descriptors WHERE database_id BETWEEN 5 AND 32766
GROUP BY database_id
)
SELECT
[db_name] = CASE [database_id] WHEN 32767
THEN 'Resource DB'
ELSE DB_NAME([database_id]) END,
db_buffer_pages,
db_buffer_MB = db_buffer_pages / 128,
db_buffer_percent = CONVERT(DECIMAL(6,3),
db_buffer_pages * 100.0 / @total_buffer)
FROM src
ORDER BY db_buffer_MB DESC;
GO
