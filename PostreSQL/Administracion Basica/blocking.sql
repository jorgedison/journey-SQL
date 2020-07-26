--Database Type	PostgreSQL
--Script Location	Basic Administration
--Script Type	SQL File
--Script Name	blocking
--Script Description	Shows sessions that are blocking other sessions.

SELECT 
	BL.PID AS BLOCKED_PID, A.USENAME AS BLOCKED_USER, 
	KL.PID AS BLOCKING_PID, KA.USENAME AS BLOCKING_USER
FROM PG_CATALOG.PG_LOCKS BL
	JOIN PG_CATALOG.PG_STAT_ACTIVITY A
	ON BL.PID = A.PID
	JOIN PG_CATALOG.PG_LOCKS KL
		JOIN PG_CATALOG.PG_STAT_ACTIVITY KA
		ON KL.PID = KA.PID
		ON BL.TRANSACTIONID = KL.TRANSACTIONID AND BL.PID != KL.PID
WHERE NOT BL.GRANTED;


select pid, 
       usename, 
       pg_blocking_pids(pid) as blocked_by, 
       query as blocked_query
from pg_stat_activity
where cardinality(pg_blocking_pids(pid)) > 0;
