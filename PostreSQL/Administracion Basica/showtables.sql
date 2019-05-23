--Database Type	PostgreSQL
--Script Location	Basic Administration
--Script Type	SQL File
--Script Name	Show Tables
--Script Description	Shows Tables 

SELECT 
	SCHEMANAME, 
	TABLENAME, 
	TABLEOWNER, 
	TABLESPACE, 
	HASINDEXES, 
	HASRULES, 
	HASTRIGGERS 
FROM PG_TABLES 
WHERE SCHEMANAME = 'public'
