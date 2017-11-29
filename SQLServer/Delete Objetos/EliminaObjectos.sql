USE [DATABASE]
GO
PRINT ('Proceso 1: Eliminación de objetos ');
GO

-- Procedimientos almacenados
PRINT ('1.a. Eliminando procedimientos almacenados ' + CONVERT( VARCHAR(19), GETDATE(), 121));
GO
DECLARE @procedure NVARCHAR(max)
DECLARE @n CHAR(1)
SET @n = CHAR(10)
SELECT @procedure = isnull( @procedure + @n, '' ) +
    'DROP PROCEDURE [' + schema_name(schema_id) + '].[' + name + ']'
FROM sys.procedures

EXEC sp_executesql @procedure
PRINT ('1.b. Procedimientos almacenados eliminados ' + CONVERT( VARCHAR(19), GETDATE(), 121));
GO

-- Constraints
PRINT ('1.c. Eliminando Constraints ' + CONVERT( VARCHAR(19), GETDATE(), 121));
GO
DECLARE @constraints NVARCHAR(max)
DECLARE @n CHAR(1)
SET @n = CHAR(10)
SELECT @constraints = isnull( @constraints + @n, '' ) +
	'ALTER TABLE [' + schema_name(schema_id) + '].[' + object_name( parent_object_id ) + ']    DROP CONSTRAINT [' + name + ']'
FROM sys.check_constraints

EXEC sp_executesql @constraints
PRINT ('1.d. Constraints eliminados ' + CONVERT( VARCHAR(19), GETDATE(), 121));
GO

-- Funciones
PRINT ('1.e. Eliminando Funciones ' + CONVERT( VARCHAR(19), GETDATE(), 121));
GO
DECLARE @functions NVARCHAR(max)
DECLARE @n CHAR(1)
SET @n = CHAR(10)
SELECT @functions = isnull( @functions + @n, '' ) +
    'DROP FUNCTION [' + schema_name(schema_id) + '].[' + name + ']'
FROM sys.objects
WHERE TYPE IN ( 'FN', 'IF', 'TF' ) ORDER BY schema_id, name ASC

EXEC sp_executesql @functions
PRINT ('1.f. Funciones eliminados ' + CONVERT( VARCHAR(19), GETDATE(), 121));
GO

-- LLaves foráneas
PRINT ('1.g. Eliminando Llaves foráneas ' + CONVERT( VARCHAR(19), GETDATE(), 121));
GO
DECLARE @foreign NVARCHAR(max)
DECLARE @n CHAR(1)
SET @n = CHAR(10)
SELECT @foreign = isnull( @foreign + @n, '' ) +
    'ALTER TABLE [' + schema_name(schema_id) + '].[' + object_name( parent_object_id ) + '] DROP CONSTRAINT [' + name + ']'
FROM sys.foreign_keys

EXEC sp_executesql @foreign
PRINT ('1.h. Llaves foráneas eliminadas ' + CONVERT( VARCHAR(19), GETDATE(), 121));
GO

-- Tablas
PRINT ('1.i. Eliminando Tablas ' + CONVERT( VARCHAR(19), GETDATE(), 121));
GO
DECLARE @table NVARCHAR(max)
DECLARE @n CHAR(1)
SET @n = CHAR(10)
SELECT @table = isnull( @table + @n, '' ) +
    'DROP TABLE [' + schema_name(schema_id) + '].[' + name + ']'
FROM sys.tables

EXEC sp_executesql @table
PRINT ('1.j. Tablas eliminadas ' + CONVERT( VARCHAR(19), GETDATE(), 121));
GO

-- Esquemas
PRINT ('1.k. Eliminando Esquemas ' + CONVERT( VARCHAR(19), GETDATE(), 121));
GO
DECLARE @schema NVARCHAR(max)
DECLARE @n CHAR(1)
SET @n = CHAR(10)
SELECT @schema = isnull( @schema + @n, '' ) +
    'DROP SCHEMA [' + schema_name(schema_id) + ']'
FROM sys.schemas
WHERE name LIKE 'PN_%' OR name LIKE 'PS_%' OR name LIKE 'SC_%'

EXEC sp_executesql @schema
PRINT ('1.l. Esquemas eliminados ' + CONVERT( VARCHAR(19), GETDATE(), 121));
GO

PRINT ('Fin de Proceso');

