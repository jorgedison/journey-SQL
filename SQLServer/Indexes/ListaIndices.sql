USE [DATABASE]
GO

SELECT 
     TableName = t.name,
     IndexName = ind.name,
     IndexId = ind.index_id,
     ColumnId = ic.index_column_id,
     ColumnName = col.name,
     ind.*,
     ic.*,
     col.* 
FROM 
     sys.indexes ind 
INNER JOIN 
     sys.index_columns ic ON  ind.object_id = ic.object_id and ind.index_id = ic.index_id 
INNER JOIN 
     sys.columns col ON ic.object_id = col.object_id and ic.column_id = col.column_id 
INNER JOIN 
     sys.tables t ON ind.object_id = t.object_id 
WHERE 
     ind.is_primary_key = 0 
     AND ind.is_unique = 0 
     AND ind.is_unique_constraint = 0 
     AND t.is_ms_shipped = 0 
ORDER BY 
     t.name, ind.name, ind.index_id, ic.index_column_id 
GO


SELECT  
        [Total Cost]  = ROUND(avg_total_user_cost * avg_user_impact * (user_seeks + user_scans),0) 
        , avg_user_impact
        , TableName = statement
        , [EqualityUsage] = equality_columns 
        , [InequalityUsage] = inequality_columns
        , [Include Cloumns] = included_columns
FROM        sys.dm_db_missing_index_groups g 
INNER JOIN    sys.dm_db_missing_index_group_stats s 
       ON s.group_handle = g.index_group_handle 
INNER JOIN    sys.dm_db_missing_index_details d 
       ON d.index_handle = g.index_handle
ORDER BY [Total Cost] DESC;
GO


SELECT o.[name], o.[type], i.[name], i.[index_id], f.[name]
	FROM sys.indexes i
	INNER JOIN sys.filegroups f
	ON i.data_space_id = f.data_space_id
	INNER JOIN sys.all_objects o
	ON i.[object_id] = o.[object_id]
	WHERE i.data_space_id = f.data_space_id
	AND i.data_space_id = 2 -- Filegroup
GO


SELECT name, type_desc FROM sys.objects 
	WHERE TYPE in ( 'C', 'D', 'F', 'L', 'P', 'PK', 'RF', 'TR', 'UQ', 'V', 'X' ) 
	UNION
	SELECT name, type_desc FROM sys.indexes
	ORDER BY name
GO
