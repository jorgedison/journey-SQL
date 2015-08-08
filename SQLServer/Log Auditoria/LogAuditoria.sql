USE [DATABASE]
GO

/*	Script: Auditoria de modificación de procedimientos almacenados
	Autor: Jorge Rodriguez
*/

/*1. Crea Tabla de auditoria*/

/****** Object:  Table [dbo].[AlterLog]    Script Date: 07/08/2015 04:29:33 p.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[AlterLog](
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
/****** Object:  DdlTrigger [AlterProcs]    Script Date: 07/08/2015 04:28:49 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [AlterProcs]
ON DATABASE
FOR ALTER_PROCEDURE
AS

SET NOCOUNT ON; 

DECLARE @data XML
SET @data = EVENTDATA()

INSERT INTO dbo.AlterLog(EventTime, EventType, ObjectName, ObjectType, TSQLCommand, LoginName, ServerName, DatabaseName, SchemaName, HostName, ProgramName)
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
PROGRAM_NAME()
)

GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

ENABLE TRIGGER [AlterProcs] ON DATABASE
GO
