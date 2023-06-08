SELECT pg_size_pretty(pg_total_relation_size('nombre_de_la_tabla')) AS tamaño_total
FROM nombre_de_la_tabla
WHERE condiciones_de_la_consulta;
