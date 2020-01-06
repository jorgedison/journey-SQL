SELECT   d.object_id, 
         d.database_id, 
         DB_NAME(database_id) AS 'database_name',   
         OBJECT_NAME(object_id, database_id) AS 'trigger_name', 
         d.cached_time,  
         d.last_execution_time, 
         d.total_elapsed_time,   
         d.total_elapsed_time/d.execution_count AS [avg_elapsed_time],   
         d.last_elapsed_time, 
         d.execution_count  
FROM     sys.dm_exec_trigger_stats AS d  
ORDER BY [total_worker_time] DESC;
