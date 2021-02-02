-- Captura objetos (procedimientos almacenados y funciones) y los ejecuta automaticamente

/**************************************************** PROCEDIMIENTOS ALMACENADOS ****************************************************/

SET NOCOUNT ON
DECLARE @Test TABLE (Id INT IDENTITY(1,1), Code VARCHAR(MAX), name VARCHAR(100))

INSERT INTO @Test (Code, name)
SELECT  OBJECT_DEFINITION(OBJECT_ID) + CHAR(13) +CHAR(10) + '' + CHAR(13) + CHAR(10), name
            FROM sys.procedures p where is_ms_shipped = 0

DECLARE @lnCurrent INT, @lnMax INT
DECLARE @LongName VARCHAR(MAX)

SELECT @lnMax = MAX(Id) FROM @Test
SET @lnCurrent = 1
WHILE @lnCurrent <= @lnMax
      BEGIN
            SELECT @LongName = Code FROM @Test WHERE Id = @lnCurrent
            WHILE @LongName <> ''
               BEGIN
				   PRINT LEFT(@LongName,8000)
                   SET @LongName = SUBSTRING(@LongName, 8001, LEN(@LongName))
               END
            SET @lnCurrent = @lnCurrent + 1
      END


INSERT INTO SIIV_AUDITORIA.dbo.storedprocedures_siiv (sp, name, fecha, db) SELECT Code, name, GETDATE(), DB_NAME() from @Test

UPDATE SIIV_AUDITORIA.dbo.storedprocedures_siiv
SET sp = REPLACE (CONVERT(VARCHAR(MAX), sp), 'CREATE PROCEDURE', 'ALTER PROCEDURE') 

UPDATE SIIV_AUDITORIA.dbo.storedprocedures_siiv
SET sp = REPLACE (CONVERT(VARCHAR(MAX), sp), 'CREATE PROC', 'ALTER PROCEDURE')

DECLARE @sqlCommand1 varchar(max)
SET @sqlCommand1 = (SELECT TOP 1 sp  from  SIIV_AUDITORIA.dbo.storedprocedures_siiv WHERE name = 'namesp' ORDER BY fecha DESC)
EXEC (@sqlCommand1)

/**************************************************** FUNCIONES ****************************************************/

SET NOCOUNT ON
DECLARE @Testf TABLE (Id INT IDENTITY(1,1), Code VARCHAR(MAX), name VARCHAR(100))

INSERT INTO @Testf (Code, name)
SELECT ROUTINE_DEFINITION, ROUTINE_NAME FROM information_schema.routines 
WHERE routine_type = 'FUNCTION'

INSERT INTO SIIV_AUDITORIA.dbo.storedprocedures_siiv (sp, name, fecha, db) SELECT Code, name, GETDATE(), DB_NAME() from @Testf

UPDATE SIIV_AUDITORIA.dbo.storedprocedures_siiv
SET sp = REPLACE (CONVERT(VARCHAR(MAX), sp), 'CREATE FUNCTION', 'ALTER FUNCTION') 


DECLARE @sqlCommand16 varchar(max)
SET @sqlCommand16 = (SELECT TOP 1 sp  from  SIIV_AUDITORIA.dbo.storedprocedures_siiv WHERE name = 'namefunction' ORDER BY fecha DESC)
EXEC (@sqlCommand16)

