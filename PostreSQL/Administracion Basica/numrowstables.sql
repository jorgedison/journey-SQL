-- Numero de registros por tabla de una base de datos

SELECT schemaname,relname,n_live_tup  FROM pg_stat_user_tables order by 2 asc;
