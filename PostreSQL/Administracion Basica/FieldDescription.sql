SELECT
cols.column_name,
pg_catalog.col_description(c.oid, cols.ordinal_position::int), *
FROM pg_catalog.pg_class c, information_schema.columns cols
WHERE
cols.table_catalog = 'Databasename' and
cols.table_schema = 'public' and
cols.table_name = c.relname
