USE [DATABASE]
GO

sp_helpdb DATABASE_NAME;

-- Antes de truncar el log cambiamos el modelo de recuperación a SIMPLE.
ALTER DATABASE DATABASE_NAME
SET RECOVERY SIMPLE;
GO
--Reducimos el log de transacciones a  1 MB.
DBCC SHRINKFILE(DATABASE_NAME_Log, 1);
GO
-- Cambiamos nuevamente el modelo de recuperación a Completo.
ALTER DATABASE DATABASE_NAME
SET RECOVERY FULL;
GO

