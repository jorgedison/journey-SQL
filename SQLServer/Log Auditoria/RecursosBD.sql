USE [AuditBD]
GO

/****** Object:  Table [dbo].[RecursosServidor]    Script Date: 09/03/2016 03:01:11 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[RecursosServidor](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[memory_usage] [float] NOT NULL,
	[cpu_usage] [float] NOT NULL,
	[datetime_usage] [datetime] NOT NULL,
 CONSTRAINT [PK_RecursosServidor] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

USE master
GO

SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON

DECLARE @memory_usage FLOAT
DECLARE @cpu_usage FLOAT

SET @memory_usage = ( SELECT    1.0 - ( available_physical_memory_kb / ( total_physical_memory_kb * 1.0 ) ) memory_usage
                        FROM      sys.dm_os_sys_memory
                    )

SET @cpu_usage = ( SELECT TOP ( 1 )
                            [CPU] / 100.0 AS [CPU_usage]
                    FROM     ( SELECT    record.value('(./Record/@id)[1]', 'int') AS record_id
                                        , record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS [CPU]
                                FROM      ( SELECT    [timestamp]
                                                    , CONVERT(XML, record) AS [record]
                                            FROM      sys.dm_os_ring_buffers WITH ( NOLOCK )
                                            WHERE     ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
                                                    AND record LIKE N'%<SystemHealth>%'
                                        ) AS x
                            ) AS y
                    ORDER BY record_id DESC
                    )
INSERT INTO AuditBD.[dbo].[RecursosServidor]
           ([memory_usage]
           ,[cpu_usage]
           ,[datetime_usage])
SELECT  @memory_usage
, @cpu_usage, GETDATE()
