USE [DATABASE]
GO

SELECT s.name AS [SCHEMA_TABLE], T.NAME AS [TABLE NAME], C.NAME AS [COLUMN NAME], P.NAME AS [DATA TYPE], 
CASE C.MAX_LENGTH WHEN -1 THEN 'MAX' ELSE cONvert(varchar, C.MAX_LENGTH) END AS [SIZE],
CASE c.is_nullable WHEN 0 THEN 'No Nulo' ELSE 'Nulo' END AS [Nullable], 
CASE c.is_identity WHEN 0 THEN '' ELSE 'PK' END AS [PK],
CASE WHEN (fk.object_id Is Null) THEN '' ELSE 'FK' END AS [FK],
ISNULL(sep.value, '') [DescriptiON]
FROM SYS.OBJECTS AS T
JOIN SYS.COLUMNS AS C ON T.OBJECT_ID = C.OBJECT_ID
JOIN SYS.schemAS AS S ON T.schema_id = S.schema_id
JOIN SYS.TYPES AS P ON C.SYSTEM_TYPE_ID=P.SYSTEM_TYPE_ID
left join sys.extENDed_properties sep ON C.OBJECT_ID = sep.major_id and C.column_id = sep.minor_id and sep.name = 'MS_DescriptiON'
Left Join (sys.Foreign_Keys fk Inner Join Sys.Foreign_Key_Columns fc ON (fk.object_id = fc.CONstraint_Object_id)) ON ((fk.parent_object_id = C.object_id) And (fc.parent_column_id = C.column_id))
WHERE T.TYPE_DESC='USER_TABLE' and s.name <> 'dbo'
ORDER by s.name, T.NAME, c.column_id;

GO


SELECT s.name AS [SCHEMA_TABLE], T.NAME AS [TABLE NAME], C.NAME AS [COLUMN NAME], P.NAME AS [DATA TYPE],
CASE C.MAX_LENGTH
WHEN -1 THEN 'MAX'
ELSE CASE WHEN P.NAME = 'decimal' THEN cONvert(varchar,(c.precision)) +','+cONvert(varchar,c.scale) ELSE cONvert(varchar, C.MAX_LENGTH)END END AS [SIZE],
CASE c.is_nullable WHEN 0 THEN 'No Nulo' ELSE 'Nulo' END AS [Nullable],
CASE c.is_identity WHEN 0 THEN '' ELSE 'PK' END AS [PK],
CASE WHEN (fk.object_id Is Null) THEN '' ELSE 'FK' END AS [FK],
ISNULL(sep.value, '') [DescriptiON]
FROM SYS.OBJECTS AS T
JOIN SYS.COLUMNS AS C ON T.OBJECT_ID = C.OBJECT_ID
JOIN SYS.schemAS AS S ON T.schema_id = S.schema_id
JOIN SYS.TYPES AS P ON C.SYSTEM_TYPE_ID=P.SYSTEM_TYPE_ID
left join sys.extENDed_properties sep ON C.OBJECT_ID = sep.major_id and C.column_id = sep.minor_id and sep.name = 'MS_DescriptiON'
Left Join (sys.Foreign_Keys fk Inner Join Sys.Foreign_Key_Columns fc ON (fk.object_id = fc.CONstraint_Object_id)) ON ((fk.parent_object_id = C.object_id) And (fc.parent_column_id = C.column_id))
WHERE T.TYPE_DESC='USER_TABLE' and s.name <> 'dbo'
ORDER by s.name, T.NAME, c.column_id;
