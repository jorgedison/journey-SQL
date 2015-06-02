USE BD_SGAC_G2
GO

WITH DataBase_Size (SqlServerInstance,DatabaseName,DatabaseSize,LogSize,TotalSize)
AS
-- Define the CTE query.
(
  SELECT      @@SERVERNAME SqlServerInstance,
            db.name AS DatabaseName,
            SUM(CASE WHEN af.groupid = 0 THEN 0 ELSE af.size / 128.0E END) AS DatabaseSize,
            SUM(CASE WHEN af.groupid = 0 THEN af.size / 128.0E ELSE 0 END) AS LogSize,
            SUM(af.size / 128.0E) AS TotalSize
FROM        master..sysdatabases AS db
INNER JOIN  master..sysaltfiles AS af ON af.[dbid] = db.[dbid]
WHERE       db.name NOT IN ('distribution', 'Resource', 'master', 'tempdb', 'model', 'msdb') -- System databases
            AND db.name NOT IN ('Northwind', 'pubs', 'AdventureWorks', 'AdventureWorksDW')   -- Sample databases
GROUP BY    db.name 
)
-- Define the outer query referencing the  name.
SELECT *
FROM DataBase_Size order by TotalSize desc