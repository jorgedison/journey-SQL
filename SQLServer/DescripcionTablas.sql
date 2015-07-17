USE [DATABASE]
GO

SELECT distinct s.name as [SCHEMA_TABLE], 
	T.NAME AS [TABLE NAME], 
	ISNULL(sep.value, '') [Description]
FROM SYS.OBJECTS AS T
	JOIN SYS.schemas as S ON T.schema_id = S.schema_id
	LEFT JOIN sys.extended_properties sep on T.OBJECT_ID = sep.major_id AND sep.minor_id = 0 AND sep.name = 'MS_Description'
WHERE T.TYPE_DESC='USER_TABLE' and s.name <> 'dbo' 
ORDER BY s.name, T.NAME;

GO