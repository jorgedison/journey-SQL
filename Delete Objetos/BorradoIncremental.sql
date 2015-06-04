USE [DATABASE]
GO

-- Escenario: Se desea eliminar grande volumenes de datos de una tabla en SQL Server

-- Caso Tradicional
DELETE from LaTabla
-- Las condiciones de eliminación
WHERE campo1=X

-- Borrado Incremental
DECLARE @CONTINUE INT
DECLARE @ROWCOUNT INT
SET @continue = 1
 
WHILE @continue = 1
BEGIN
	DELETE TOP (10000) FROM LaTabla WHERE campo1 = X
	SET @ROWCOUNT = @@ROWCOUNT
	
	IF @ROWCOUNT = 0
		BEGIN
		SET @continue = 0
	END
END