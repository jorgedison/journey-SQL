USE [DATABASE];
GO

/*Indices que no existe y que sON costos para la bASe de datos: 
Esta cONsulta te provee un impacto si creAS el indice, que columnAS debe llevar el indices y que include debes utilizar.*/

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

/*Analisis de indices*/
SELECT 
	db_name(d.databASe_id) AS DB, object_name(d.object_id, d.databASe_id) tabla, s.avg_user_impact, s.user_seeks, d.equality_columns, 
	d.inequality_columns, d.included_columns, p.row_count, l.num_esperAS, l.ms_esperAS, s.lASt_user_seek,
	create_index = replace('create nONclustered index IX_' + object_name(d.object_id, d.databASe_id) +'_A# ON ' + 
	object_name(d.object_id, d.databASe_id) + ' (' + isnull(d.equality_columns + ',', '') + isnull(d.inequality_columns, '') + ') ' + isnull('include (' + d.included_columns + ')', '') + ' with(ONline = ON)'
	, ',)', ')')	
FROM 
	sys.dm_db_missing_index_details d left join
	sys.dm_db_missing_index_groups g ON d.index_handle =g.index_handle left join
	sys.dm_db_missing_index_group_stats s ON g.index_group_handle = s.group_handle left join
	sys.dm_db_partitiON_stats p ON d.object_id = p.object_id and p.index_id < 2 left join
	(SELECT 
			databASe_id,
			object_id,
			row_number() over (partitiON by databASe_id order by sum(page_io_latch_wait_in_ms) desc) AS row_number,
			sum(page_io_latch_wait_count) AS num_esperAS,
			sum(page_io_latch_wait_in_ms) AS ms_esperAS,
			sum(range_scan_count) AS range_scans,
			sum(singletON_lookup_count) AS index_lookups
		FROM sys.dm_db_index_operatiONal_stats(NULL, NULL, NULL, NULL)
		WHERE page_io_latch_wait_count > 0
		group by databASe_id, object_id) l ON d.object_id = l.object_id and d.databASe_id = l.databASe_id
WHERE
	d.databASe_id = db_id()
	and s.lASt_user_seek > dateadd(dd, -7, getdate())	
order by --floor(s.avg_user_impact) desc, 
	s.user_seeks desc

/*Analizar Utilización de Indices - Depurar Indices no Utilizados*/

SELECT 
DISTINCT OBJECT_NAME(sis.OBJECT_ID) TableName,
si.name AS IndexName,
sc.Name AS ColumnName,
sis.user_seeks,  
sis.user_scans,  
sis.user_lookups, 
sis.user_updates 
FROM sys.dm_db_index_usage_stats sis
INNER JOIN sys.indexes si  ON sis.object_id = si.object_id and sis.index_id = si.Index_id
INNER JOIN sys.index_columns sic ON sis.object_id = sic.object_id and sic.Index_id = si.Index_id
INNER JOIN sys.columns sc ON sis.object_id = sc.object_id and sic.Column_id = sc.Column_id
INNER JOIN  sys.objects o ON si.object_id = o.object_id
WHERE sis.databASe_id = DB_ID('BD_SGAC') and o.type = 'U' ;
GO
