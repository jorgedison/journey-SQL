USE master
GO

SET NOCOUNT ON

DECLARE @jobId BINARY(16) 
EXEC  msdb.dbo.sp_add_job 
		@job_name=N'Nombre Job',	
		@enabled=1,					
		@notify_level_eventlog=0,	
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'Descripcion Job',
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@job_id = @jobId OUTPUT		-- Número de identificación del trabajo al que se va a agregar la programación

EXEC msdb.dbo.sp_add_jobserver @job_id=@jobId, @server_name = @@SERVERNAME

EXEC msdb.dbo.sp_help_job @job_id=@jobId

EXEC msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Nombre Steps', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [dbo].[table]', --TSQL
		@database_name=N'Nombre BD', 
		@flags=0

DECLARE @schedule_id int

EXEC msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Nombre Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20150805,	-- Dia de Inicio 05082015
		@active_end_date=99991231,		-- Dia de Fin 31129999
		@active_start_time=60000, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT

