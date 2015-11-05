--Database Type	PostgreSQL
--Script Location	Basic Administration
--Script Type	SQL File
--Script Name	as
--Script Description	Shows active sessions using psql.

SELECT 
	DATID, 
	DATNAME,
	PID, 
	USESYSID, 
	USENAME, 
	APPLICATION_NAME, 
	CLIENT_ADDR, 
	CLIENT_HOSTNAME, 
	CLIENT_PORT, 
	BACKEND_START, 
	XACT_START, 
	QUERY_START, 
	STATE_CHANGE, 
	WAITING, 
	STATE, 
	QUERY
FROM PG_STAT_ACTIVITY

