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

-- Lista columnas, descripcion, tipos de datos

SELECT *,
 isc.table_name,
 isc.ordinal_position::integer AS ordinal_position,
 isc.column_name::character varying AS column_name,
 isc.column_default::character varying AS column_default,
 isc.data_type::character varying AS data_type,
 isc.character_maximum_length::integer AS str_length,
        CASE
            WHEN isc.udt_name::text = 'int4'::text OR isc.udt_name::text = 
'bool'::text THEN isc.data_type::character varying
            ELSE isc.udt_name::character varying
        END AS udt_name
   FROM information_schema.columns isc
  WHERE isc.table_schema::text = 'public'::text --and isc.table_name='systemformcontrols'
  ORDER BY isc.table_name, isc.ordinal_position;
