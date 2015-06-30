USE [DATABASENAME]
GO

PRINT ('Eliminando registros de todas las tablas - SQL SERVER ');
GO

EXEC sp_msforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
EXEC sp_msforeachtable 'DELETE FROM ?'
EXEC sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL'

PRINT ('Registros de todas las tablas eliminados - SQL SERVER ');
GO