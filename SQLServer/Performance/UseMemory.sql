-- estado actual del uso de la memoria en SQL Server

SELECT
	physical_memory_kb/1024/1024,
	virtual_memory_kb/1024/1024,
	committed_kb/1024/1024,
	committed_target_kb/1024/1024
FROM sys.dm_os_sys_info;

-- consulta retorna, ordenada desde más páginas a menos, la cantidad de memoria consumida por cada base de datos en la caché del búfer:

SELECT
    databases.name AS database_name,
    COUNT(*) * 8 / 1024 AS mb_used
FROM sys.dm_os_buffer_descriptors
INNER JOIN sys.databases
ON databases.database_id = dm_os_buffer_descriptors.database_id
GROUP BY databases.name
ORDER BY COUNT(*) DESC;
