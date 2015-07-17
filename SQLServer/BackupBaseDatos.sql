BACKUP DATABASE [SIIV] 
	TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\SIIV.bak' 
	WITH NOFORMAT, INIT,  NAME = N'SIIV-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10
GO

DECLARE @backupSetId AS INT
SELECT @backupSetId = position FROM msdb..backupset WHERE database_name=N'SIIV' and backup_set_id=(SELECT max(backup_set_id) FROM msdb..backupset WHERE database_name=N'SIIV' )

IF @backupSetId IS NULL BEGIN RAISERROR(N'Verify failed. Backup information for database ''SIIV'' not found.', 16, 1) END
RESTORE VERIFYONLY FROM  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Backup\SIIV.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO
