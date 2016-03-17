-- -----------------------------------------------------------------------------------
-- Author       : Jorge Rodriguez
-- Description  : Displays information about datafiles.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @datafiles
-- Last Modified: 17-AUG-2005
-- -----------------------------------------------------------------------------------

SET LINESIZE 200
COLUMN file_name FORMAT A70

SELECT file_id,
       file_name,
       ROUND(bytes/1024/1024/1024) AS size_gb,
       ROUND(maxbytes/1024/1024/1024) AS max_size_gb,
       autoextensible,
       increment_by,
       status
FROM   dba_data_files
ORDER BY file_name;