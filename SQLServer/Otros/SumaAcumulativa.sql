USE [NAME_DATABASE]
GO
-- @NOMBRE_TABLA

SELECT T1.ID, T1.SOMENUMT, SUM(T2.SOMENUMT) AS SUM
FROM @NOMBRE_TABLA T1
INNER JOIN @NOMBRE_TABLA T2 ON T1.ID >= T2.ID
GROUP BY T1.ID, T1.SOMENUMT
ORDER BY T1.ID