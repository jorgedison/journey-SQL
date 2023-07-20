-- Primero, definimos la tabla donde queremos insertar los datos
CREATE TABLE personas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    edad INTEGER
);

-- Luego, creamos la función
CREATE OR REPLACE FUNCTION insertar_persona(nombre_param VARCHAR(50), edad_param INTEGER)
RETURNS INTEGER  -- Especificamos el tipo de dato de retorno (en este caso, un entero)
AS $$
DECLARE
    id_resultado INTEGER;  -- Variable para almacenar el identity generado
BEGIN
    -- Insertamos los datos en la tabla y obtenemos el valor del identity
    INSERT INTO personas (nombre, edad) VALUES (nombre_param, edad_param) RETURNING id INTO id_resultado;
    
    RETURN id_resultado;  -- Devolvemos el valor del identity
END;
$$
LANGUAGE plpgsql;
