-- Lista de funciones

SELECT * FROM pg_proc WHERE PRONAMESPACE=2200

-- Lista de funciones con descripciones

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

-- Lista de funciones y parametros

SELECT routines.routine_name, 
	parameters.data_type, 
	parameters.ordinal_position 
FROM information_schema.routines 
JOIN information_schema.parameters ON routines.specific_name=parameters.specific_name 
WHERE routines.specific_schema='public'
-- and routine_name='nombre_funcion' 
ORDER BY routines.routine_name, parameters.ordinal_position;
