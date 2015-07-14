USE [DATABASE]
GO
/****** Object:  User [DEVCENTER\jrodriguez]    Script Date: 5/21/2015 4:32:09 PM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DEVCENTER\jrodriguez')
CREATE USER [DEVCENTER\jrodriguez] FOR LOGIN [DEVCENTER\jrodriguez] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [DEVCENTER\jrodriguez]
GO
ALTER ROLE [db_datareader] ADD MEMBER [DEVCENTER\jrodriguez]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [DEVCENTER\jrodriguez]
GO
DENY SELECT, INSERT, UPDATE, DELETE ON [dbo].[AlterLog] TO [DEVCENTER\jrodriguez]
DENY DELETE ON OBJECT::dbo.AlterLog TO [DEVCENTER\jrodriguez];

/****** Object:  User [DEVCENTER\cpalomino]    Script Date: 5/21/2015 4:32:09 PM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DEVCENTER\cpalomino')
CREATE USER [DEVCENTER\cpalomino] FOR LOGIN [DEVCENTER\cpalomino] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [DEVCENTER\cpalomino]
GO
ALTER ROLE [db_datareader] ADD MEMBER [DEVCENTER\cpalomino]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [DEVCENTER\cpalomino]
GO
DENY SELECT, INSERT, UPDATE, DELETE ON [dbo].[AlterLog] TO [DEVCENTER\cpalomino]
DENY DELETE ON OBJECT::dbo.AlterLog TO [DEVCENTER\cpalomino];

/****** Object:  User [DEVCENTER\mdiaz]    Script Date: 5/21/2015 4:32:09 PM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DEVCENTER\mdiaz')
CREATE USER [DEVCENTER\mdiaz] FOR LOGIN [DEVCENTER\mdiaz] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [DEVCENTER\mdiaz]
GO
ALTER ROLE [db_datareader] ADD MEMBER [DEVCENTER\mdiaz]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [DEVCENTER\mdiaz]
GO
DENY SELECT, INSERT, UPDATE, DELETE ON [dbo].[AlterLog] TO [DEVCENTER\mdiaz]
DENY DELETE ON OBJECT::dbo.AlterLog TO [DEVCENTER\mdiaz];

/****** Object:  User [DEVCENTER\sguinet]    Script Date: 5/21/2015 4:32:09 PM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DEVCENTER\sguinet')
CREATE USER [DEVCENTER\sguinet] FOR LOGIN [DEVCENTER\sguinet] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [DEVCENTER\sguinet]
GO
ALTER ROLE [db_datareader] ADD MEMBER [DEVCENTER\sguinet]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [DEVCENTER\sguinet]
GO
DENY SELECT, INSERT, UPDATE, DELETE ON [dbo].[AlterLog] TO [DEVCENTER\sguinet]
DENY DELETE ON OBJECT::dbo.AlterLog TO [DEVCENTER\sguinet];

/****** Object:  User [DEVCENTER\chernandez]    Script Date: 5/21/2015 4:32:09 PM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DEVCENTER\chernandez')
CREATE USER [DEVCENTER\chernandez] FOR LOGIN [DEVCENTER\chernandez] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [DEVCENTER\chernandez]
GO
ALTER ROLE [db_datareader] ADD MEMBER [DEVCENTER\chernandez]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [DEVCENTER\chernandez]
GO
DENY SELECT, INSERT, UPDATE, DELETE ON [dbo].[AlterLog] TO [DEVCENTER\chernandez]
DENY DELETE ON OBJECT::dbo.AlterLog TO [DEVCENTER\chernandez];

/****** Object:  User [DEVCENTER\jcaycho]    Script Date: 5/21/2015 4:32:09 PM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DEVCENTER\jcaycho')
CREATE USER [DEVCENTER\jcaycho] FOR LOGIN [DEVCENTER\jcaycho] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [DEVCENTER\jcaycho]
GO
ALTER ROLE [db_datareader] ADD MEMBER [DEVCENTER\jcaycho]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [DEVCENTER\jcaycho]
GO
DENY SELECT, INSERT, UPDATE, DELETE ON [dbo].[AlterLog] TO [DEVCENTER\jcaycho]
DENY DELETE ON OBJECT::dbo.AlterLog TO [DEVCENTER\jcaycho];

/****** Object:  User [DEVCENTER\jinsil]    Script Date: 5/21/2015 4:32:09 PM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DEVCENTER\jinsil')
CREATE USER [DEVCENTER\jinsil] FOR LOGIN [DEVCENTER\jinsil] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [DEVCENTER\jinsil]
GO
ALTER ROLE [db_datareader] ADD MEMBER [DEVCENTER\jinsil]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [DEVCENTER\jinsil]
GO
DENY SELECT, INSERT, UPDATE, DELETE ON [dbo].[AlterLog] TO [DEVCENTER\jinsil]
DENY DELETE ON OBJECT::dbo.AlterLog TO [DEVCENTER\jinsil];

/****** Object:  User [DEVCENTER\hvasquez]    Script Date: 5/21/2015 4:32:09 PM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'DEVCENTER\hvasquez')
CREATE USER [DEVCENTER\hvasquez] FOR LOGIN [DEVCENTER\hvasquez] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [DEVCENTER\hvasquez]
GO
ALTER ROLE [db_datareader] ADD MEMBER [DEVCENTER\hvasquez]
GO
ALTER ROLE [db_denydatawriter] ADD MEMBER [DEVCENTER\hvasquez]
GO
DENY SELECT, INSERT, UPDATE, DELETE ON [dbo].[AlterLog] TO [DEVCENTER\hvasquez]
DENY DELETE ON OBJECT::dbo.AlterLog TO [DEVCENTER\hvasquez];
