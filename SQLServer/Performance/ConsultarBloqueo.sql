USE master
GO

SELECT * FROM (
	SELECT 
	 [Process ID]	  = p.spid
	,[HostName]	      = p.hostname
	,[User]           = p.loginame   
    ,[Database]       = ISNULL(db_name(p.dbid),N'')
	,[Query]		  = sql1.text
	,[Command]        = p.cmd 
	,[Blocked By]	  = p.blocked
	,[Blocked By Query] = sp.text
	,[Blocking]		  = CASE 
							WHEN (SELECT count(*) FROM master.dbo.sysprocesses pp WHERE p.spid=pp.blocked)>0 THEN 1
					    ELSE 0
					    END 
	,[Wait Time]      = p.waittime 
    ,[Wait Type]      = CASE 
							WHEN p.waittype = 0 THEN N'' 
					    ELSE p.lastwaittype 
					    END
    ,[Kill Command] = 'kill ' + CONVERT(varchar(10), p.spid)
	FROM master.dbo.sysprocesses p
	CROSS APPLY sys.dm_exec_sql_text(p.sql_handle) sql1
	LEFT JOIN (SELECT mp.spid,sql2.text FROM master.dbo.sysprocesses mp
			   CROSS APPLY sys.dm_exec_sql_text(mp.sql_handle) sql2 ) sp ON p.blocked=sp.spid
) AS tabla
--WHERE [Blocking] <> 0 or [Blocked By] <> 0	-- Ver Procesos que están siendo bloqueados o que están bloqueando
--WHERE [Blocking] <> 0 and [Blocked By] = 0	-- Ver Procesos que no están siendo bloqueados y que están bloqueando
ORDER BY [Process ID]