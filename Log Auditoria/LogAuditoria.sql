USE [DATABASE]
GO

/*	Script: Auditoria de modificación de procedimientos almacenados
	Autor: Jorge Rodriguez
*/

/*1. Crea Tabla de auditoria*/

/****** Object:  Table [dbo].[AlterLog]    Script Date: 21/05/2015 10:15:16 a.m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AlterLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AlterLog](
	[EventType] [varchar](50) NULL,
	[ObjectName] [varchar](256) NULL,
	[ObjectType] [varchar](25) NULL,
	[TSQLCommand] [text] NOT NULL,
	[EventTime] [datetime] NULL,
	[LoginName] [varchar](256) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_PADDING OFF
GO

/*2. Crea Trigger*/
/****** Object:  DdlTrigger [AlterProcs]    Script Date: 21/05/2015 05:21:10 p.m. ******/
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

INSERT INTO dbo.AlterLog(EventTime, EventType, ObjectName, ObjectType, TSQLCommand, LoginName)
VALUES(GETDATE(),@data.value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)'), 
@data.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(256)'), 
@data.value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(25)'), 
@data.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'varchar(max)'), 
@data.value('(/EVENT_INSTANCE/LoginName)[1]', 'varchar(256)')
)

GO

ENABLE TRIGGER [AlterProcs] ON DATABASE
GO
