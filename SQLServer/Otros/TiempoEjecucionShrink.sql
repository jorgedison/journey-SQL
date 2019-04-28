SELECT T.text,
   R.Status,
   R.Command,
   DatabaseName = DB_NAME(R.database_id),
   R.cpu_time,
   R.total_elapsed_time,
   R.percent_complete
FROM sys.dm_exec_requests R
   CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) T

SELECT 
    d.name,
    percent_complete, 
    session_id,
    start_time, 
    status, 
    command, 
    estimated_completion_time, 
    cpu_time, 
    total_elapsed_time
FROM 
    sys.dm_exec_requests E left join
    sys.databases D on e.database_id = d.database_id
WHERE
    command in ('DbccFilesCompact','DbccSpaceReclaim')
