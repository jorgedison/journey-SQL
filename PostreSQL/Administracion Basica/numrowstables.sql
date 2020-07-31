-- Numero de registros por tabla de una base de datos

SELECT schemaname,relname,n_live_tup  FROM pg_stat_user_tables order by 2 asc;

SELECT 
  nspname AS schemaname,relname,reltuples
FROM pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE 
  nspname NOT IN ('pg_catalog', 'information_schema') AND
  relkind='r' 
ORDER BY reltuples DESC;

SELECT 
  nspname AS schemaname,relname, CAST(coalesce(reltuples, '0') AS integer)
FROM pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE 
  nspname NOT IN ('pg_catalog', 'information_schema') AND
  relkind='r' 
ORDER BY reltuples DESC;
