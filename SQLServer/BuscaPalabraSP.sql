USE [DATABASE]
GO

SELECT ROUTINE_NAME 
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_DEFINITION LIKE '%NOMBRE_TABLA%'
AND ROUTINE_TYPE='PROCEDURE'
order by ROUTINE_NAME