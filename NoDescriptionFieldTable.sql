USE [DATABASE]
GO

SELECT s.name as [SCHEMA_TABLE], T.NAME AS [TABLE NAME], C.NAME AS [COLUMN NAME], sep.value [Description]
FROM SYS.OBJECTS AS T
JOIN SYS.COLUMNS AS C ON T.OBJECT_ID = C.OBJECT_ID
JOIN SYS.schemas as S ON T.schema_id = S.schema_id
JOIN SYS.TYPES AS P ON C.SYSTEM_TYPE_ID=P.SYSTEM_TYPE_ID
left join sys.extended_properties sep 
on C.OBJECT_ID = sep.major_id and C.column_id = sep.minor_id and sep.name = 'MS_Description'
WHERE T.TYPE_DESC='USER_TABLE' and s.name <> 'dbo' 
and ISNULL(sep.value, '') = ''
order by s.name, T.NAME, c.column_id;

GO