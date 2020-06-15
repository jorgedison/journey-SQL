# pg_dump en docker
#!/bin/sh
HOY=`date +%Y%m%d%H%M%S`
docker exec -t -u postgres [nombre-contenedor] pg_dump --format plain --no-owner --inserts --column-inserts --verbose --file "/tmp/[base-de-datos]_$HOY.sql" [base-de-datos]
docker cp [nombre-contenedor]:/tmp/[base-de-datos]_$HOY.sql /tmp/
