USE [DATABASENAME]
GO

-- Lista Llaves primarias de una BD
SELECT s.name, COL_NAME(ic.OBJECT_ID,ic.column_id), *
				FROM sys.indexes AS i
				INNER JOIN sys.index_columns AS ic ON i.OBJECT_ID = ic.OBJECT_ID
				INNER JOIN sys.tables AS t ON t.object_id = ic.object_id
				INNER JOIN sys.schemas AS s ON s.schema_id = t.schema_id
				AND i.index_id = ic.index_id and i.is_primary_key = 1
				ORDER BY S.name ASC