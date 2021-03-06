-- RECUPERAR REGISTROS ELIMINADOS DE UNA BASE DE DATOS

-- HAREMOS USO DE LA FUNCI�N FN_DBLOG, ESTA ES UNA FUNCI�N DE SQL SERVER NO DOCUMENTADA QUE LEE LA PORCI�N ACTIVA DE UN REGISTRO DE TRANSACCIONES EN L�NEA.

USE [DATABASE]
GO

SET NOCOUNT ON; 

-- 1.LOP_DELETE_ROWS

SELECT
    [CURRENT LSN],
    [TRANSACTION ID],
    [OPERATION],
    [CONTEXT],
    [ALLOCUNITNAME]
FROM FN_DBLOG(NULL, NULL)
WHERE [OPERATION] = 'LOP_DELETE_ROWS'

--RESULT:
--CURRENT LSN				TRANSACTION ID	OPERATION							CONTEXT	ALLOCUNITNAME
--000A06EE:00000834:0073	0000:193F3575	LOP_DELETE_ROWS	LCX_MARK_AS_GHOST	REQUIREMENT.REQUIREMENT.REQUIREMENT_V_UNIQUECODE
--000A06EE:00000834:0078	0000:193F3575	LOP_DELETE_ROWS	LCX_MARK_AS_GHOST	REQUIREMENT.REQUIREMENT.IDX_UNIQUECODE

-- 2.LOP_BEGIN_XACT

SELECT
    [CURRENT LSN],
    [OPERATION],
    [TRANSACTION ID],
    [BEGIN TIME],
    [TRANSACTION NAME],
    [TRANSACTION SID]
FROM FN_DBLOG(NULL, NULL)
WHERE [TRANSACTION ID] = '0000:193F3575' -- TRANSACTION ID OBTENIDO EN CONSULTA (1)
    AND [OPERATION] = 'LOP_BEGIN_XACT'

--RESULT:
--CURRENT LSN				OPERATION		TRANSACTION ID	BEGIN TIME				TRANSACTION NAME	TRANSACTION SID
--000A06EE:00000834:0002	LOP_BEGIN_XACT	0000:193F3575	2015/11/13 09:29:53:923	USER_TRANSACTION	0X5A09FF0176D77C4B9476E8E3E400D682

-- 3.VARBINARY - CURRENT LSN - CONVERT HEXADECIMAL

SELECT CONVERT(INT, CONVERT(VARBINARY, '0X000A06EE', 1)) AS CURRENT_LSN_1
SELECT CONVERT(INT, CONVERT(VARBINARY, '0X00000834', 1)) AS CURRENT_LSN_2
SELECT CONVERT(INT, CONVERT(VARBINARY, '0X0002', 1)) AS CURRENT_LSN_3

--RESULT:
--CURRENT_LSN_1
--657134
--CURRENT_LSN_2
--2100
--CURRENT_LSN_3
--2

-- 4. LSN - CONVERT DECIMAL

SELECT RIGHT('0000000000' + CAST(CONVERT(INT, CONVERT(VARBINARY, '0X00000834', 1)) AS NVARCHAR), 10) AS LSN_1
SELECT RIGHT('00000' + CAST(CONVERT(INT, CONVERT(VARBINARY, '0X0002', 1)) AS NVARCHAR), 5) AS LSN_2

--RESULT:
--LSN_1
--0000002100
--LSN_2
--00002

--LSN = CURRENT_LSN_3 + LSN_1 + LSN_2
--LSN = 2000000210000002

-- 5. RESTORING

--RESTORING FULL BACKUP WITH NORECOVERY.
RESTORE DATABASE DATABASE_COPY
    FROM DISK = 'C:\DATABASE.BAK'
WITH
    MOVE 'DATABASE' TO 'C:\DATABASE.MDF',
    MOVE 'DATABASE_LOG' TO 'C:\DATABASE_LOG.LDF',
    REPLACE, NORECOVERY;  
    GO

--RESTORE LOG BACKUP WITH STOPBEFOREMARK OPTION TO RECOVER EXACT LSN.
   RESTORE LOG DATABASE_COPY
FROM
    DISK = N'C:\DATABASE.TRN'
WITH
    STOPBEFOREMARK = 'LSN:2000000210000002'

-- 6. SELECT DATA RECOVERY

USE DATABASE_COPY
GO

SELECT * FROM REQUIREMENT.REQUIREMENT
GO