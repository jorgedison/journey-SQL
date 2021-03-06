USE [DATABASENAME]
GO

--SCHEMANAME � NAME OF THE SCHEMA.
--TABLENAME � NAME OF THE TABLE.
--TABLETYPE � TYPE OF THE TABLE E.G. HEAP OR CLUSTER.
--FILEGROUPNAME � FILEGROUP WHERE THE TABLE IS STORED.
--NUMBEROFPARTITIONS � NUMBER OF PARTITIONS IN THE TABLE.
--NUMBEROFROWS � NUMBER OF ROWS IN THE TABLE.
--TOTALDATAPAGES � NUMBER OF DATA PAGES IN THE TABLE.
--SIZEOFDATAPAGESKB � SIZE OF DATA PAGES IN KB.
--NUMBEROFINDEXES  � NUMBER OF INDEXES IN THE TABLE.
--NUMBEROFINDEXPAGES  �  NUMBER OF INDEX PAGES FOR THE TABLE INDEXES.
--SIZEOFINDEXPAGESKB � SIZE OF INDEX PAGES IN KB.

WITH DATAPAGES
AS (
	SELECT O.OBJECT_ID
		,COALESCE(F.NAME, D.NAME) AS STORAGE
		,S.NAME AS SCHEMANAME
		,O.NAME AS TABLENAME
		,COUNT(DISTINCT P.PARTITION_ID) AS NUMBEROFPARTITIONS
		,CASE MAX(I.INDEX_ID)
			WHEN 1
				THEN 'CLUSTER'
			ELSE 'HEAP'
			END AS TABLETYPE
		,SUM(P.ROWS) AS [ROWCOUNT]
		,SUM(A.TOTAL_PAGES) AS DATAPAGES
	FROM SYS.TABLES O
	INNER JOIN SYS.INDEXES I ON I.OBJECT_ID = O.OBJECT_ID
	INNER JOIN SYS.PARTITIONS P ON P.OBJECT_ID = O.OBJECT_ID
		AND P.INDEX_ID = I.INDEX_ID
	INNER JOIN SYS.ALLOCATION_UNITS A ON A.CONTAINER_ID = P.PARTITION_ID
	INNER JOIN SYS.SCHEMAS S ON S.SCHEMA_ID = O.SCHEMA_ID
	LEFT JOIN SYS.FILEGROUPS F ON F.DATA_SPACE_ID = I.DATA_SPACE_ID
	LEFT JOIN SYS.DESTINATION_DATA_SPACES DDS ON DDS.PARTITION_SCHEME_ID = I.DATA_SPACE_ID
		AND DDS.DESTINATION_ID = P.PARTITION_NUMBER
	LEFT JOIN SYS.FILEGROUPS D ON D.DATA_SPACE_ID = DDS.DATA_SPACE_ID
	WHERE O.TYPE = 'U'
		AND I.INDEX_ID IN ( 0, 1 )
	GROUP BY S.NAME
		,COALESCE(F.NAME, D.NAME)
		,O.NAME
		,O.OBJECT_ID
	)
	,INDEXPAGES
AS (
	SELECT O.OBJECT_ID
		,O.NAME AS TABLENAME
		,COALESCE(F.NAME, D.NAME) AS STORAGE
		,COUNT(DISTINCT I.INDEX_ID) AS NUMBEROFINDEXES
		,SUM(A.TOTAL_PAGES) AS INDEXPAGES
	FROM SYS.OBJECTS O
	INNER JOIN SYS.INDEXES I ON I.OBJECT_ID = O.OBJECT_ID
	INNER JOIN SYS.PARTITIONS P ON P.OBJECT_ID = O.OBJECT_ID
		AND P.INDEX_ID = I.INDEX_ID
	INNER JOIN SYS.ALLOCATION_UNITS A ON A.CONTAINER_ID = P.PARTITION_ID
	LEFT JOIN SYS.FILEGROUPS F ON F.DATA_SPACE_ID = I.DATA_SPACE_ID
	LEFT JOIN SYS.DESTINATION_DATA_SPACES DDS ON DDS.PARTITION_SCHEME_ID = I.DATA_SPACE_ID
		AND DDS.DESTINATION_ID = P.PARTITION_NUMBER
	LEFT JOIN SYS.FILEGROUPS D ON D.DATA_SPACE_ID = DDS.DATA_SPACE_ID
	WHERE I.INDEX_ID <> 0
	GROUP BY O.NAME
		,O.OBJECT_ID
		,COALESCE(F.NAME, D.NAME)
	)
SELECT T.[SCHEMANAME]
	,T.[TABLENAME]
	,T.[TABLETYPE]
	,T.[STORAGE] AS FILEGROUPNAME
	,T.[NUMBEROFPARTITIONS]
	,T.[ROWCOUNT]
	,T.[DATAPAGES]
	,(T.[DATAPAGES] * 8) AS SIZEOFDATAPAGESKB
	,ISNULL(I.[NUMBEROFINDEXES], 0) AS NUMBEROFINDEXES
	,ISNULL(I.[INDEXPAGES], 0) AS INDEXPAGES
	,(ISNULL(I.[INDEXPAGES], 0) * 8) AS SIZEOFINDEXPAGESKB
FROM DATAPAGES T
LEFT JOIN INDEXPAGES I ON I.OBJECT_ID = T.OBJECT_ID
	AND I.STORAGE = T.STORAGE;
GO