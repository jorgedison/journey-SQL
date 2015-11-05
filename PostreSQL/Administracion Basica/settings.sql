--Database Type	PostgreSQL
--Script Location	Basic Administration
--Script Type	SQL File
--Script Name	settings
--Script Description	Shows current server settings as configured in the postgresql.conf file.

SELECT 
	NAME AS NOMBRE, 
	SETTING AS CONFIGURACION, 
	UNIT AS UNIDAD, 
	CONTEXT AS CONTENIDO
FROM PG_SETTINGS
ORDER BY 1;