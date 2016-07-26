SELECT n.nspname AS schema_name
      ,p.proname AS function_name,
      --,pg_get_function_arguments(p.oid) AS args
      --,pg_get_functiondef(p.oid) AS func_def, 
	c.description
FROM   pg_proc p 
INNER JOIN pg_namespace n ON n.oid = p.pronamespace
INNER JOIN pg_catalog.pg_description c ON c.objoid=p.oid
WHERE  n.nspname !~~ 'pg_%'
AND    n.nspname <> 'information_schema'
AND (c.description IS NOT NULL OR c.description IS NULL)
