USE [DATABASE]
GO

/*Liberar memoria no utlizada*/
DBCC FREESYSTEMCACHE ('ALL', default);
DBCC FREESYSTEMCACHE ('ALL');
/*Seteamos el uso maximo de SQL Server a un valor bajo (en este ejemplo, 100MB)*/
EXEC sys.sp_configure N'max server memory (MB)', N'100'
GO
RECONFIGURE WITH OVERRIDE
GO
CHECKPOINT
GO

/*Liberar cache*/
--USE BD_SGAC

DBCC FREESYSTEMCACHE ('ALL') WITH MARK_IN_USE_FOR_REMOVAL;
DBCC FREEPROCCACHE
/*Seteamos el uso maximo de SQL Server al valor que deseamos, (en este ejemplo, 1024MB). 
Como la liberacion de memoria, el SQL Server no la hace inmediatamente, hacemos un delay de 1 minuto.*/
WAITFOR DELAY '00:01:00'
GO
EXEC sys.sp_configure N'max server memory (MB)', N'1024'
GO
RECONFIGURE WITH OVERRIDE
GO

sp_configure 'show advanced options', 1;
GO
RECONFIGURE WITH OVERRIDE
GO
CHECKPOINT
GO

/*Seteamos el uso maximo de SQL Server a un valor bajo (en este ejemplo, 200MB)*/
sp_configure 'max server memory', 200;
GO
RECONFIGURE WITH OVERRIDE
GO
CHECKPOINT
GO

/*Seteamos el uso maximo de SQL Server al valor que deseamos, (en este ejemplo, 1500MB). 
Como la liberacion de memoria, el SQL Server no la hace inmediatamente, hacemos un delay de 1 minuto.*/
WAITFOR DELAY '00:01:00'
GO
sp_configure 'max server memory', 1500;
GO
RECONFIGURE WITH OVERRIDE
GO
CHECKPOINT
GO

EXEC sp_configure 'show advanced options', 0;
GO
RECONFIGURE WITH OVERRIDE
GO
CHECKPOINT
GO