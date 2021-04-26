#Backup completo
pg_dump --host localhost --port 5432 --username usr_backup  --format plain --no-owner --inserts --column-inserts --verbose --file /tmp/database.sql database

#Backup solo datos
pg_dump --host localhost --port 5432 --username usr_backup --format plain --no-owner --section=data --column-inserts --verbose --file /tmp/database.sql database
