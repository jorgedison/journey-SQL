;WITH cte AS
(
  SELECT stat.[sql_handle],
         stat.statement_start_offset,
         stat.statement_end_offset,
         COUNT(*) AS [NumExecutionPlans],
         SUM(stat.execution_count) AS [TotalExecutions],
         ((SUM(stat.total_logical_reads) * 1.0) / SUM(stat.execution_count)) AS [AvgLogicalReads],
         ((SUM(stat.total_worker_time) * 1.0) / SUM(stat.execution_count)) AS [AvgCPU]
  FROM sys.dm_exec_query_stats stat
  GROUP BY stat.[sql_handle], stat.statement_start_offset, stat.statement_end_offset
)
SELECT CONVERT(DECIMAL(15, 5), cte.AvgCPU) AS [AvgCPU],
       CONVERT(DECIMAL(15, 5), cte.AvgLogicalReads) AS [AvgLogicalReads],
       cte.NumExecutionPlans,
       cte.TotalExecutions,
       DB_NAME(txt.[dbid]) AS [DatabaseName],
       OBJECT_NAME(txt.objectid, txt.[dbid]) AS [ObjectName],
       SUBSTRING(txt.[text], (cte.statement_start_offset / 2) + 1,
       (
         (CASE cte.statement_end_offset 
           WHEN -1 THEN DATALENGTH(txt.[text])
           ELSE cte.statement_end_offset
          END - cte.statement_start_offset) / 2
         ) + 1
       )
FROM cte
CROSS APPLY sys.dm_exec_sql_text(cte.[sql_handle]) txt
ORDER BY cte.AvgCPU DESC;
