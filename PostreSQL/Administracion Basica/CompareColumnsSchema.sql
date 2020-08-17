-- Query below compares columns (names) in tables between two PostgreSQL schemas. It shows columns missing in either of two schema.

select COALESCE(c1.table_name, c2.table_name) as table_name,
       COALESCE(c1.column_name, c2.column_name) as table_column,
       c1.column_name as schema1,
       c2.column_name as schema2
from
    (select table_name,
            column_name
     from information_schema.columns c
     where c.table_schema = 'schema_1') c1
full join
         (select table_name,
                 column_name
          from information_schema.columns c
          where c.table_schema = 'schema_2') c2
on c1.table_name = c2.table_name and c1.column_name = c2.column_name
where c1.column_name is null
      or c2.column_name is null
order by table_name,
         table_column;
