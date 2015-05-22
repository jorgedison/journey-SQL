USE [DATABASE]
GO

SELECT CAST(c.name AS  VARCHAR(255)) AS TablAS, 
COUNT( CAST(f.name  AS VARCHAR(255)) ) AS CantidadFK
FROM sysobjects c 
  left outer join sysobjects f ON  f.parent_obj = c.id AND f.type =  'F'
    WHERE c.xtype = 'U' and c.uid <> 1
GROUP by CAST(c.name AS  VARCHAR(255))
HAVING  COUNT( CAST(f.name  AS VARCHAR(255)) )  = 0

GO