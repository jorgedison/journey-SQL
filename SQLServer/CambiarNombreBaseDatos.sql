USE [master]
GO

-- Paso 1: Se setea la BD a "Single User"
ALTER DATABASE A
SET SINGLE_USER WITH ROLLBACK IMMEDIATE

-- Paso 2: Se modifica el Nombre de la BD
ALTER DATABASE A
MODIFY NAME = B

-- Paso 3: Se retorna la BD ya renombrada a "Multi User"
ALTER DATABASE B
SET MULTI_USER
GO
