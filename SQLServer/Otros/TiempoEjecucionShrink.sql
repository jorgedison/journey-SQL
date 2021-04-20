# Query 1
SELECT T.text,
   R.Status,
   R.Command,
   DatabaseName = DB_NAME(R.database_id),
   R.cpu_time,
   R.total_elapsed_time,
   R.percent_complete
FROM sys.dm_exec_requests R
   CROSS APPLY sys.dm_exec_sql_text(R.sql_handle) T

# Query 2

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

# Query 3

select
a.session_id
, command
, b.text
, percent_complete
, done_in_minutes = a.estimated_completion_time / 1000 / 60
, min_in_progress = DATEDIFF(MI, a.start_time, DATEADD(ms, a.estimated_completion_time, GETDATE() ))
, a.start_time
, estimated_completion_time = DATEADD(ms, a.estimated_completion_time, GETDATE() )
from sys.dm_exec_requests a
CROSS APPLY sys.dm_exec_sql_text(a.sql_handle) b
where command like '%dbcc%'
