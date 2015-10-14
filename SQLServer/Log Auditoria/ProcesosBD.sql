USE [master]
GO

-- Select a SYS.processes con bloqueo mayor a valor 0
SELECT * FROM SYS.sysprocesses WHERE blocked > 0;

-- Select a SYS.processes con login distinto a sa
SELECT * FROM SYS.sysprocesses WHERE loginame NOT IN ('sa');

-- Ubicamos el PID y ejecutamos la consulta
DECLARE @BDID INT
SET @BDID=89
DECLARE @HANDLE BINARY(20)
SELECT @HANDLE = SQL_HANDLE FROM SYSPROCESSES WHERE SPID = @BDID
SELECT * FROM ::FN_GET_SQL(@HANDLE) H
INNER JOIN SYS.sysdatabases S ON S.dbid=H.dbid