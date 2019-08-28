DECLARE @alias NVARCHAR(max)
set @alias = 'jrodriguez' 

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
GO
