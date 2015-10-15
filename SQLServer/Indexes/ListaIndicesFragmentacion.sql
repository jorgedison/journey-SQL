USE [DATABASENAME]
GO

-- Lista porcentaje de Indices fragmentados

SELECT 
   SI.[name] AS index_name, 
   OBJECT_SCHEMA_NAME(SDDIPS.[object_id]) + '.' + OBJECT_NAME(SDDIPS.[object_id]) AS [object_name], 
   SDDIPS.[index_type_desc], SDDIPS.[avg_fragmentation_in_percent], SDDIPS.[page_count] 
FROM sys.[dm_db_index_physical_stats](DB_ID(), NULL, NULL, NULL, NULL) SDDIPS
   INNER JOIN sys.[indexes] SI ON SDDIPS.[object_id] = SI.[object_id]
   AND SDDIPS.[index_id] = SI.[index_id] 
 WHERE SDDIPS.[avg_fragmentation_in_percent] > 5
   AND SDDIPS.[page_count] >= 2
   AND SDDIPS.[index_id] > 0
ORDER BY OBJECT_SCHEMA_NAME(SDDIPS.[object_id]), OBJECT_NAME(SDDIPS.[object_id])