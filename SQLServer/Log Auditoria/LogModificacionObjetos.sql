USE AUDITORIA
GO

/****** 1. Creación de Tabla ******/

/****** Object:  Table [dbo].[LogObjetos]    Script Date: 16/05/2016 09:50:11 a.m. ******/
CREATE TABLE [dbo].[LogObjetos](
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
	[ProgramName] [varchar](256) NULL,
	[IPAddressClient] [varchar](50) NULL,
 CONSTRAINT [PK_AlterLog] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

/****** 2. Creación de Trigger ******/

USE master
GO

/****** Object:  DdlTrigger [AlterObject]    Script Date: 16/05/2016 09:48:20 a.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [AlterObject]
ON ALL SERVER 
FOR CREATE_DATABASE, ALTER_DATABASE, DROP_DATABASE, CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE, CREATE_FUNCTION, ALTER_FUNCTION, DROP_FUNCTION, CREATE_TABLE, ALTER_TABLE, DROP_TABLE, CREATE_VIEW, ALTER_VIEW, DROP_VIEW, CREATE_SCHEMA, ALTER_SCHEMA, DROP_SCHEMA, CREATE_INDEX, ALTER_INDEX, DROP_INDEX, CREATE_USER, ALTER_USER, DROP_USER

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

DECLARE @IPC VARCHAR(50)
SELECT @IPC = 'IPC'
SELECT @IPC = (SELECT cli.client_net_address FROM SYS.dm_exec_connections AS cli
WHERE cli.session_id = @@SPID)

IF @IPC IS NULL OR @IPC = '<local machine>'
BEGIN 
SET @IPC = '127.0.0.1'
END

INSERT INTO AUDITORIA.dbo.LogObjetos(EventTime, EventType, ObjectName, ObjectType, TSQLCommand, LoginName, ServerName, DatabaseName, SchemaName, HostName, IPAddress, ProgramName, IPAddressClient)
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
PROGRAM_NAME(),
@IPC
)













GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

ENABLE TRIGGER [AlterObject] ON ALL SERVER
GO
