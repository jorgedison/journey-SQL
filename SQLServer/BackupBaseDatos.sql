USE master
GO

BACKUP DATABASE [TEST] 
	TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\TEST.bak' 
	WITH NOFORMAT, INIT,  NAME = N'TEST-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO

DECLARE @backupSetId AS INT
SELECT @backupSetId = position FROM msdb..backupset WHERE database_name=N'SIIV' and backup_set_id=(SELECT max(backup_set_id) FROM msdb..backupset WHERE database_name=N'TEST' )

IF @backupSetId IS NULL BEGIN RAISERROR(N'Verify failed. Backup information for database ''TEST'' not found.', 16, 1) END
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\TEST.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO
