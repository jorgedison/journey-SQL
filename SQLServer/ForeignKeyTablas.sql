USE [DATABASE]
GO

SELECT CAST(f.name  AS VARCHAR(255)) AS foreign_key_name
    , r.keycnt
    , CAST(c.name AS  VARCHAR(255)) AS foreign_table
    , CAST(fc.name AS VARCHAR(255)) AS  foreign_column_1
    ,  CAST(p.name AS VARCHAR(255)) AS primary_table
    , CAST(rc.name AS VARCHAR(255))  AS primary_column_1

    from sysobjects f
    inner join sysobjects c ON  f.parent_obj = c.id
    inner join sysreferences r ON f.id =  r.cONstid
    inner join sysobjects p ON r.rkeyid = p.id
    inner  join syscolumns rc ON r.rkeyid = rc.id and r.rkey1 = rc.colid
    inner  join syscolumns fc ON r.fkeyid = fc.id and r.fkey1 = fc.colid
    left join  syscolumns rc2 ON r.rkeyid = rc2.id and r.rkey2 = rc.colid
    left join  syscolumns fc2 ON r.fkeyid = fc2.id and r.fkey2 = fc.colid
    where f.type =  'F'
 ORDER BY CAST(f.name AS VARCHAR(255))

 GO

 -- CONSULTA ALTERNATIVA

 SELECT FK.NAME AS FK,
       OBJECT_NAME(FK.PARENT_OBJECT_ID) AS TABLENAME,
       COL_NAME(FC.PARENT_OBJECT_ID,FC.PARENT_COLUMN_ID) AS COLUMNNAME,
       OBJECT_NAME (FK.REFERENCED_OBJECT_ID) AS REFERENCETABLENAME,
       COL_NAME(FC.REFERENCED_OBJECT_ID, FC.REFERENCED_COLUMN_ID) AS REFERENCECOLUMNNAME
FROM SYS.FOREIGN_KEYS AS FK
INNER JOIN SYS.FOREIGN_KEY_COLUMNS AS FC ON FK.OBJECT_ID = FC.CONSTRAINT_OBJECT_ID
