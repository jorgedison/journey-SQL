USE [DATABASENAME]
GO

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

CREATE TABLE #FRAGMENTEDINDEXES
(
 DATABASENAME SYSNAME
 , SCHEMANAME SYSNAME
 , TABLENAME SYSNAME
 , INDEXNAME SYSNAME
 , [FRAGMENTATION%] FLOAT
)

INSERT INTO #FRAGMENTEDINDEXES
SELECT
 DB_NAME(DB_ID()) AS DATABASENAME
 , SS.NAME AS SCHEMANAME
 , OBJECT_NAME (S.OBJECT_ID) AS TABLENAME
 , I.NAME AS INDEXNAME
 , S.AVG_FRAGMENTATION_IN_PERCENT AS [FRAGMENTATION%]
FROM SYS.DM_DB_INDEX_PHYSICAL_STATS(DB_ID(),NULL, NULL, NULL, NULL) S
INNER JOIN SYS.INDEXES I ON S.[OBJECT_ID] = I.[OBJECT_ID]
AND S.INDEX_ID = I.INDEX_ID
INNER JOIN SYS.OBJECTS O ON S.OBJECT_ID = O.OBJECT_ID
INNER JOIN SYS.SCHEMAS SS ON SS.[SCHEMA_ID] = O.[SCHEMA_ID]
WHERE S.DATABASE_ID = DB_ID()
AND I.INDEX_ID != 0
AND S.AVG_FRAGMENTATION_IN_PERCENT > 0
AND O.IS_MS_SHIPPED = 0
DECLARE @REBUILDINDEXESSQL NVARCHAR(MAX)
SET @REBUILDINDEXESSQL = ''
SELECT
 @REBUILDINDEXESSQL = @REBUILDINDEXESSQL +
CASE
 WHEN [FRAGMENTATION%] > 30
   THEN CHAR(10) + 'ALTER INDEX ' + QUOTENAME(INDEXNAME) + ' ON '
      + QUOTENAME(SCHEMANAME) + '.'
      + QUOTENAME(TABLENAME) + ' REBUILD;'
 WHEN [FRAGMENTATION%] > 5
    THEN CHAR(10) + 'ALTER INDEX ' + QUOTENAME(INDEXNAME) + ' ON '
    + QUOTENAME(SCHEMANAME) + '.'
    + QUOTENAME(TABLENAME) + ' REORGANIZE;'
END
FROM #FRAGMENTEDINDEXES
WHERE [FRAGMENTATION%] > 10
DECLARE @STARTOFFSET INT
DECLARE @LENGTH INT
SET @STARTOFFSET = 0
SET @LENGTH = 4000
WHILE (@STARTOFFSET < LEN(@REBUILDINDEXESSQL))
BEGIN
 PRINT SUBSTRING(@REBUILDINDEXESSQL, @STARTOFFSET, @LENGTH)
 SET @STARTOFFSET = @STARTOFFSET + @LENGTH
END
PRINT SUBSTRING(@REBUILDINDEXESSQL, @STARTOFFSET, @LENGTH)
EXECUTE SP_EXECUTESQL @REBUILDINDEXESSQL
DROP TABLE #FRAGMENTEDINDEXES