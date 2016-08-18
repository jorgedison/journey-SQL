-- Lista de tablas

SELECT table_schema,table_name
FROM information_schema.tables
where table_schema='public'
ORDER BY table_schema,table_name

-- Lista de Tablas y descripciones

SELECT c.relname As tname, CASE WHEN c.relkind = 'v' THEN 'view' ELSE 'table' END As type, 
    pg_get_userbyid(c.relowner) AS towner, t.spcname AS tspace, 
    n.nspname AS sname,  d.description
   FROM pg_class As c
   LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
   LEFT JOIN pg_tablespace t ON t.oid = c.reltablespace
   LEFT JOIN pg_description As d ON (d.objoid = c.oid )
   WHERE c.relkind IN('r', 'v') --AND d.description > ''
   AND pg_get_userbyid(c.relowner) = 'DATABASE'
   ORDER BY n.nspname, c.relname;
   
  
SELECT * from pg_class c WHERE c.relkind IN('r', 'v') AND pg_get_userbyid(c.relowner) = 'DATABASE'

SELECT * from pg_class WHERE table_catalog='DATABASE' and table_type='BASE TABLE' and table_schema='public';

SELECT * from information_schema.tables WHERE table_catalog='DATABASE' and table_type='BASE TABLE' and table_schema='public'
