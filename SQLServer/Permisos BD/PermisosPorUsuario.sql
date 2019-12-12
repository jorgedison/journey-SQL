DECLARE @alias NVARCHAR(max)
set @alias = 'jrodriguez' 

SET NOCOUNT ON

-- Permisos a Procedimientos almacenados

SELECT
'GRANT VIEW DEFINITION ON [' +SPECIFIC_SCHEMA + '].['+ SPECIFIC_NAME +'] to ['+@alias+'];'
   from information_schema.routines 
 where routine_type = 'PROCEDURE'

SELECT
'DENY ALTER ON [' +SPECIFIC_SCHEMA + '].['+ SPECIFIC_NAME +'] to ['+@alias+'];'
   from information_schema.routines 
 where routine_type = 'PROCEDURE'

-- Permisos a vistas

SELECT
'GRANT VIEW DEFINITION ON [' +TABLE_SCHEMA + '].['+ TABLE_NAME +'] to ['+@alias+'];'
   from information_schema.VIEWS 


SELECT
'DENY ALTER ON [' +TABLE_SCHEMA + '].['+ TABLE_NAME +'] to ['+@alias+'];'
   from information_schema.VIEWS 


-- Permisos a Funciones

SELECT
'GRANT VIEW DEFINITION ON [' +SPECIFIC_SCHEMA + '].['+ SPECIFIC_NAME +'] to ['+@alias+'];'
   from information_schema.routines 
 where routine_type = 'FUNCTION'

SELECT
'DENY ALTER ON [' +SPECIFIC_SCHEMA + '].['+ SPECIFIC_NAME +'] to ['+@alias+'];'
   from information_schema.routines 
 where routine_type = 'FUNCTION'

 -- Permisos a Tablas

 SELECT
'GRANT VIEW DEFINITION ON [' +TABLE_SCHEMA + '].['+ TABLE_NAME +'] to ['+@alias+'];'
   from INFORMATION_SCHEMA.TABLES
 where TABLE_TYPE = 'BASE TABLE'

 SELECT
'DENY ALTER ON [' +TABLE_SCHEMA + '].['+ TABLE_NAME +'] to ['+@alias+'];'
   from INFORMATION_SCHEMA.TABLES
 where TABLE_TYPE = 'BASE TABLE'
