USE master
GO

SELECT 
       [Process ID]    = p.spid
      ,[HostName]	   = p.hostname 
      ,[User]          = p.loginame   
      ,[Database]      = ISNULL(db_name(p.dbid),N'')
      ,[Query]		   = sql1.text
      ,[Status]        = p.status 
      ,[Open Transactions] = p.open_tran 
      ,[Command]       = p.cmd 
      ,[ApplicatiON]   = p.program_name 
      ,[Wait Time]     = p.waittime  
      ,[Wait Type]     = CASE 
							WHEN p.waittype = 0 THEN N'' 
						 ELSE p.lastwaittype 
						 END 
      ,[CPU]           = p.cpu 
      ,[Physical IO]   = p.physical_io 
      ,[Memory Usage]  = p.memusage
      ,[Login Time]    = p.login_time 
      ,[Last Batch]    = p.last_batch 
      ,[Blocked By]    = p.blocked
      ,[Blocked By Query] = sp.text
      ,[Blocking]      = CASE
							WHEN (SELECT count(*) FROM master.dbo.sysprocesses pp WHERE p.spid=pp.blocked)>0 THEN 1
                         ELSE 0
						 END
FROM master.dbo.sysprocesses p
INNER JOIN master.sys.dm_exec_sessiONs s WITH (NOLOCK) ON p.spid = s.session_id
CROSS APPLY sys.dm_exec_sql_text(p.sql_handle) sql1
LEFT JOIN (SELECT mp.spid,sql2.text FROM master.dbo.sysprocesses mp
		   CROSS APPLY sys.dm_exec_sql_text(mp.sql_handle) sql2 ) sp ON p.blocked=sp.spid
ORDER BY p.spid 