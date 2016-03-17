-- -----------------------------------------------------------------------------------
-- Author       : Jorge Rodriguez
-- Description  : Lists all objects being accessed in the schema.
-- Call Syntax  : @access (schema-name or all) (object-name or all)
-- Requirements : Access to the v$views.
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 255
SET VERIFY OFF

COLUMN object FORMAT A30

SELECT a.object,
       a.type,
       a.sid,
       b.serial#,
       b.username,
       b.osuser,
       b.program
FROM   v$access a,
       v$session b
WHERE  a.sid    = b.sid
ORDER BY a.object;