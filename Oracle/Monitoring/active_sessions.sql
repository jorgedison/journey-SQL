-- -----------------------------------------------------------------------------------
-- Author       : Jorge Rodriguez
-- Description  : Displays information on all active database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @active_sessions
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000

COLUMN username FORMAT A15
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20

SELECT NVL(s.username, '(oracle)') AS username,
       s.osuser,
       s.sid,
       s.serial#,
       p.spid,
       s.lockwait,
       s.status,
       s.module,
       s.machine,
       s.program,
       TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
FROM   v$session s,
       v$process p
WHERE  s.paddr  = p.addr
AND    s.status = 'ACTIVE'
ORDER BY s.username, s.osuser;

SET PAGESIZE 14