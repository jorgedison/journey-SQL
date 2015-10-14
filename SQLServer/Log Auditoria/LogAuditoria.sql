USE [DATABASE]
GO

/*	Script: Auditoria de modificación de procedimientos almacenados
	Autor: Jorge Rodriguez
*/

/*1. Crea Tabla de auditoria*/

/****** Object:  Table [dbo].[AlterLog]    Script Date: 14/10/2015 04:07:32 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[AlterLog](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[EventType] [varchar](50) NULL,
	[ObjectName] [varchar](256) NULL,
	[ObjectType] [varchar](25) NULL,
	[TSQLCommand] [text] NOT NULL,
	[EventTime] [datetime] NULL,
	[LoginName] [varchar](256) NULL,
	[ServerName] [varchar](256) NULL,
	[DatabaseName] [varchar](256) NULL,
	[SchemaName] [varchar](256) NULL,
	[HostName] [varchar](256) NULL,
	[IPAddress] [varchar](50) NULL,
	[ProgramName] [varchar](256) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



/*2. Crea Trigger*/
--/****** Object:  DdlTrigger [AlterObject]    Script Date: 14/10/2015 03:08:36 p.m. ******/
IF EXISTS(SELECT * FROM SYS.triggers WHERE name = 'AlterObject')
BEGIN
DROP TRIGGER [AlterObject] ON DATABASE
END
GO

/****** Object:  DdlTrigger [AlterObject]    Script Date: 14/10/2015 03:08:36 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [AlterObject]
ON DATABASE
FOR CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE, CREATE_FUNCTION, ALTER_FUNCTION, DROP_FUNCTION, CREATE_TABLE, ALTER_TABLE, DROP_TABLE, CREATE_VIEW, ALTER_VIEW, DROP_VIEW, CREATE_SCHEMA, ALTER_SCHEMA, DROP_SCHEMA, CREATE_INDEX, ALTER_INDEX, DROP_INDEX, CREATE_USER, ALTER_USER, DROP_USER

AS

SET NOCOUNT ON; 

DECLARE @data XML
SET @data = EVENTDATA()

DECLARE @IP VARCHAR(50)
SELECT @IP = 'IP'
SELECT @IP = (SELECT dec.local_net_address
FROM sys.dm_exec_connections AS dec
WHERE dec.session_id = @@SPID)

If @IP IS NULL 
BEGIN
SET @IP = '127.0.0.1'
END

INSERT INTO AuditBD.dbo.AlterLog(EventTime, EventType, ObjectName, ObjectType, TSQLCommand, LoginName, ServerName, DatabaseName, SchemaName, HostName, IPAddress, ProgramName)
VALUES(GETDATE(),
@data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)'), 
@data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(256)'), 
@data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(25)'), 
@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'varchar(max)'), 
@data.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(256)'),
@data.value('(/EVENT_INSTANCE/ServerName)[1]', 'varchar(256)'),
@data.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'varchar(256)'),
@data.value('(/EVENT_INSTANCE/SchemaName)[1]', 'varchar(256)'),
HOST_NAME(),
@IP,
PROGRAM_NAME()
)





GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

ENABLE TRIGGER [AlterObject] ON DATABASE
GO

