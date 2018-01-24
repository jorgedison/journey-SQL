SELECT
    pg_database.datname,
    pg_size_pretty(pg_database_size(pg_database.datname)) AS size
    FROM pg_database;
    
SELECT
   relname as "Table",
   pg_size_pretty(pg_total_relation_size(relid)) As "Size",
   pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) as "External Size"
   FROM pg_catalog.pg_statio_user_tables ORDER BY pg_total_relation_size(relid) DESC;

--Table – The name of the table
--Size – The total size that this table takes
--External Size – The size that related objects of this table like indices take

SELECT
   relname AS objectname,
   relkind AS objecttype,
   reltuples AS "#entries", pg_size_pretty(relpages::bigint*8*1024) AS size
   FROM pg_class
   WHERE relpages >= 8
   ORDER BY relpages DESC;
   
--objectname – The name of the object
--objecttype – r for the table, i for an index, t for toast data, ...
--entries – The number of entries in the object (e.g. rows)
--size – The size of the object
