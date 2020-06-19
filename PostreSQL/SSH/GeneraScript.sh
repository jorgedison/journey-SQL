-- Obtener ruta de pg_dump

which pg_dump
/usr/pgsql-9.4/bin/pg_dump -- Varia segun version de pg_dump

-- IP de Servidor: 192.168.10.100
-- Nombre de base de datos: DATABASE
-- Genera Script de objetos y datos

/usr/pgsql-9.4/bin/pg_dump --host 192.168.10.100 --port 5432  --username "postgres" --no-password  --format plain --no-owner --inserts --column-inserts --verbose --file  "/home/nombre_archivo.sql" "DATABASE"

/usr/pgsql-9.4/bin/pg_dump --host 192.168.10.100 --port 5432  --username "postgres" --no-password  --format plain --no-owner --inserts --column-inserts --verbose --file  "/home/nombre_archivo.backup" "DATABASE"

-- Genera Script de Objetos
 
/usr/pgsql-9.4/bin/pg_dump --host 192.168.10.100 --port 5432  --username "postgres" --no-password  --format plain --schema-only --no-owner --verbose --file  "/home/nombre_archivo.sql" "DATABASE"

/usr/pgsql-9.4/bin/pg_dump --host 192.168.10.100 --port 5432  --username "postgres" --no-password  --format plain --schema-only --no-owner --verbose --file  "/home/nombre_archivo.backup" "DATABASE" 
 
-- Genera datos de tablas

/usr/pgsql-9.4/bin/pg_dump --host 192.168.10.100 --port 5432 --username "postgres" --no-password  --format plain --data-only --inserts --verbose --file "/home/nombre_archivo.sql" "DATABASE"

/usr/pgsql-9.4/bin/pg_dump --host 192.168.10.100 --port 5432 --username "postgres" --no-password  --format plain --data-only --inserts --verbose --file "/home/nombre_archivo.backup" "DATABASE"
