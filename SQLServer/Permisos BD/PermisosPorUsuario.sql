# Permisos a Procedimientos almacenados

SELECT
'GRANT VIEW DEFINITION ON [' +SPECIFIC_SCHEMA + '].['+ SPECIFIC_NAME +'] to [jrodriguez];'
   from information_schema.routines 
 where routine_type = 'PROCEDURE'
GO

SELECT
'DENY ALTER ON [' +SPECIFIC_SCHEMA + '].['+ SPECIFIC_NAME +'] to [jrodriguez];'
   from information_schema.routines 
 where routine_type = 'PROCEDURE'
GO

# Permisos a vistas

SELECT
'GRANT VIEW DEFINITION ON [' +TABLE_SCHEMA + '].['+ TABLE_NAME +'] to [jrodriguez];'
   from information_schema.VIEWS 
GO

SELECT
'DENY ALTER ON [' +TABLE_SCHEMA + '].['+ TABLE_NAME +'] to [jrodriguez];'
   from information_schema.VIEWS 
GO
