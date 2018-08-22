
/*************** Usuario con privilegios de lectura de tablas *******************/
/*************** Usuario no puede ejecutar ni ver SPs *******************/

IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'au_tgs')
DROP USER [au_tgs]
GO

CREATE USER [au_tgs] FOR LOGIN [au_tgs]
GO

GRANT CONNECT TO [au_tgs];

GRANT SELECT TO [au_tgs];

--DENEGAR CREAR TABLAS SP VISTAS
DENY CREATE TABLE TO au_tgs
GO
--DENEGAR ALTER TABLAS SP VISTAS
DENY ALTER TO au_tgs
GO
-- DENEGAR EXEC SP
DENY EXECUTE TO au_tgs
GO

REVOKE VIEW DEFINITION TO au_tgs
GO
