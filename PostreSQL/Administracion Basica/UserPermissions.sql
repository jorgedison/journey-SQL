GRANT SELECT ON ALL TABLES IN SCHEMA public TO user_dev; 
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO user_dev;

-- CREATE USER ONLY READ BD

CREATE USER USER_DEVELOPER
ALTER USER  USER_DEVELOPER WITH ENCRYPTED PASSWORD 'LDVG3DXP';
GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO USER_DEVELOPER;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO user_name;

-- EJECUTAR EN CONSOLA PGADMIN3, SELECCIONANDO BD

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "USR_NFC";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "USR_NFC";
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO "USR_NFC";

-- Dar permisos de lectura a user01 sobre esquemas configuration y operation

GRANT USAGE ON SCHEMA configuration,operation TO user01;
GRANT SELECT ON ALL TABLES IN SCHEMA configuration,operation TO user01;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA configuration,operation TO user01;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA configuration,operation TO user01;

-- Dar permisos de lectura a user01 sobre esquemas configuration y operation

GRANT USAGE ON SCHEMA configuration,operation TO user01;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO user01;
GRANT SELECT ON ALL TABLES IN SCHEMA configuration,operation TO user01;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA configuration,operation TO user01;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA configuration,operation TO user01;

-- Permisos de owner enn base de datos

GRANT ALL PRIVILEGES ON DATABASE database_name TO username;
