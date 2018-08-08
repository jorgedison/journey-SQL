-- CREA FUNCION PARA CONTAR NUMERO DE REGISTROS DE TABLAS

CREATE OR REPLACE FUNCTION 
COUNT_ROWS(SCHEMA TEXT, TABLENAME TEXT) RETURNS INTEGER
AS
$BODY$
DECLARE
  RESULT INTEGER;
  QUERY VARCHAR;
BEGIN
  QUERY := 'SELECT COUNT(1) FROM ' || SCHEMA || '.' || TABLENAME;
  EXECUTE QUERY INTO RESULT;
  RETURN RESULT;
END;
$BODY$
LANGUAGE PLPGSQL;

-- CONSULTA NUMERO DE REGISTROS POR TABLA

SELECT 
  TABLE_SCHEMA,
  TABLE_NAME, 
  COUNT_ROWS(TABLE_SCHEMA, TABLE_NAME)
FROM INFORMATION_SCHEMA.TABLES
WHERE 
  TABLE_SCHEMA NOT IN ('PG_CATALOG', 'INFORMATION_SCHEMA') 
  AND TABLE_TYPE='BASE TABLE'
ORDER BY 3 DESC
