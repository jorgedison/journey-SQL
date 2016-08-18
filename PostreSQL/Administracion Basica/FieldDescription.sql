-- Lista de columnas

SELECT *
FROM information_schema.columns
WHERE table_schema = 'public'
 -- AND table_name   = 'your_table'
order by table_name asc, ordinal_position asc

-- Lista de columnas y descripciones

SELECT
cols.column_name,
pg_catalog.col_description(c.oid, cols.ordinal_position::int), *
FROM pg_catalog.pg_class c, information_schema.columns cols
WHERE
cols.table_catalog = 'Databasename' and
cols.table_schema = 'public' and
cols.table_name = c.relname
