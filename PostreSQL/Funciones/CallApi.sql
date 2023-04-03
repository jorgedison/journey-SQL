
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION call_api(url text, data text, username text, password text)
  RETURNS void AS $$
  DECLARE
    auth text := format('%s:%s', username, password);
auth_header TEXT := format('Authorization: Basic %s', encode(CAST(auth as bytea), 'base64'));

    hashed_password text := crypt(password, gen_salt('bf'));
  BEGIN
    INSERT INTO api_calls (url, data, auth_header) VALUES (url, data, auth_header);
    PERFORM pg_sleep(1); -- opcional: esperar 1 segundo para simular una solicitud a la API
    
  END;
$$ LANGUAGE plpgsql;

SELECT call_api('https://reqbin.com/sample/post/json', 'parametro=valor, parametro1=valor1', 'usuario', 'contraseña');

