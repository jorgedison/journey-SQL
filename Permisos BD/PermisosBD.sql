--Creacion de usuario
USE master
GO
CREATE LOGIN usertest WITH PASSWORD='password', CHECK_POLICY = OFF;
GO

-- Denegar vista a todas las base de datos
USE master
GO
DENY VIEW ANY DATABASE TO usertest
GO

-- Autorizacion a base de datos
USE master
GO
ALTER AUTHORIZATION ON DATABASE::NombreBD TO usertest