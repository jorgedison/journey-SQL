-- Manejo de secuencias en PostgreSQL

SELECT MAX(iapplicationid) FROM application;

SELECT nextval('application_seq');

SELECT setval('application_seq', (SELECT MAX(iapplicationid) FROM application));
 
SELECT setval('application_seq', COALESCE((SELECT MAX(iapplicationid)+1 FROM application), 1), false);

-- Funcion get_sequence_last_value

CREATE FUNCTION public.get_sequence_last_value(name) RETURNS int4 AS '
DECLARE
  ls_sequence ALIAS FOR $1;
  lr_record RECORD;
  li_return INT4;
BEGIN
  FOR lr_record IN EXECUTE ''SELECT last_value FROM '' || ls_sequence LOOP
    li_return := lr_record.last_value;
  END LOOP;
  RETURN li_return;
END;'  LANGUAGE 'plpgsql' VOLATILE;

SELECT c.relname, get_sequence_last_value(c.relname)
FROM pg_class c WHERE (c.relkind = 'S');

-- Setea secuencia a ultimo valor de tabla

BEGIN;

LOCK TABLE NOMBRE_TABLA IN EXCLUSIVE MODE;

SELECT setval('NOMBRE_SECUENCIA', COALESCE((SELECT MAX(IDTABLA)+1 FROM NOMBRE_TABLA), 1), false);

COMMIT;
