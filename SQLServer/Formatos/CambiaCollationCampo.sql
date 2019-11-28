--
ALTER TABLE [dbo].[col_test]
ALTER COLUMN Text NVARCHAR(10)
COLLATE SQL_Latin1_General_CP1_CS_AS NULL

-- CAMBIA COLLATION DE CAMPOS
-- EL COLLATION PERMITE ASOCIAR UN VALOR ÚNICO A CADA LETRA DEPENDIENDO DEL IDIOMA SELECCIONADO

USE DATABASE
GO

SELECT 'ALTER TABLE [' + SYS.OBJECTS.NAME + '] ALTER COLUMN ['
+ SYS.COLUMNS.NAME + '] ' + SYS.TYPES.NAME + 
    CASE SYS.TYPES.NAME
    WHEN 'TEXT' THEN ' '
    ELSE
    '(' + RTRIM(CASE SYS.COLUMNS.MAX_LENGTH
    WHEN -1 THEN 'MAX'
    ELSE CONVERT(CHAR,SYS.COLUMNS.MAX_LENGTH)
    END) + ') ' 
    END

    + ' ' + ' COLLATE MODERN_SPANISH_CI_AS ' + CASE SYS.COLUMNS.IS_NULLABLE WHEN 0 THEN 'NOT NULL' ELSE 'NULL' END
    FROM SYS.COLUMNS , SYS.OBJECTS , SYS.TYPES
    WHERE SYS.COLUMNS.OBJECT_ID = SYS.OBJECTS.OBJECT_ID
    AND SYS.OBJECTS.TYPE = 'U'
    AND SYS.TYPES.SYSTEM_TYPE_ID = SYS.COLUMNS.SYSTEM_TYPE_ID
    AND SYS.COLUMNS.COLLATION_NAME IS NOT NULL
    AND NOT ( SYS.OBJECTS.NAME LIKE 'SYS%' )
    AND NOT ( SYS.TYPES.NAME LIKE 'SYS%' )

-- CONSULTA ALTERNATIVA

USE DATABASE
GO

DECLARE @collate SYSNAME
SELECT @collate = 'x'

SELECT 
      '[' + SCHEMA_NAME(o.[schema_id]) + '].[' + o.name + '] -> ' + c.name
    , 'ALTER TABLE [' + SCHEMA_NAME(o.[schema_id]) + '].[' + o.name + ']
        ALTER COLUMN [' + c.name + '] ' +
        UPPER(t.name) + 
        CASE WHEN t.name NOT IN ('ntext', 'text') 
            THEN '(' + 
                CASE 
                    WHEN t.name IN ('nchar', 'nvarchar') AND c.max_length != -1 
                        THEN CAST(c.max_length / 2 AS VARCHAR(10))
                    WHEN t.name IN ('nchar', 'nvarchar') AND c.max_length = -1 
                        THEN 'MAX'
                    ELSE CAST(c.max_length AS VARCHAR(10)) 
                END + ')' 
            ELSE '' 
        END + ' COLLATE ' + @collate + 
        CASE WHEN c.is_nullable = 1 
            THEN ' NULL'
            ELSE ' NOT NULL'
        END AS T
FROM sys.columns c WITH(NOLOCK)
JOIN sys.objects o WITH(NOLOCK) ON c.[object_id] = o.[object_id]
JOIN sys.types t WITH(NOLOCK) ON c.system_type_id = t.system_type_id AND c.user_type_id = t.user_type_id
WHERE t.name IN ('char', 'varchar', 'text', 'nvarchar', 'ntext', 'nchar')
    AND c.collation_name != @collate
    AND o.[type] = 'U'
	ORDER BY T ASC
