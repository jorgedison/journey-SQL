SELECT 
    [sJOB].[job_id] AS [JobID]
    , [sJOB].[name] AS [JobName]
    , [sDBP].[name] AS [JobOwner]
    , [sCAT].[name] AS [JobCategory]
    , [sJOB].[description] AS [JobDescription]
    , CASE [sJOB].[enabled]
        WHEN 1 THEN 'Yes'
        WHEN 0 THEN 'No'
      END AS [IsEnabled]
    , [sJOB].[date_created] AS [JobCreatedOn]
    , [sJOB].[date_modified] AS [JobLastModifiedOn]
    , [sSVR].[name] AS [OriginatingServerName]
    , [sJSTP].[step_id] AS [JobStartStepNo]
    , [sJSTP].[step_name] AS [JobStartStepName]
    , CASE
        WHEN [sSCH].[schedule_uid] IS NULL THEN 'No'
        ELSE 'Yes'
      END AS [IsScheduled]
    , [sSCH].[schedule_uid] AS [JobScheduleID]
    , [sSCH].[name] AS [JobScheduleName]
    , CASE [sJOB].[delete_level]
        WHEN 0 THEN 'Never'
        WHEN 1 THEN 'On Success'
        WHEN 2 THEN 'On Failure'
        WHEN 3 THEN 'On Completion'
      END AS [JobDeletionCriterion]
FROM
    [msdb].[dbo].[sysjobs] AS [sJOB]
    LEFT JOIN [msdb].[sys].[servers] AS [sSVR]
        ON [sJOB].[originating_server_id] = [sSVR].[server_id]
    LEFT JOIN [msdb].[dbo].[syscategories] AS [sCAT]
        ON [sJOB].[category_id] = [sCAT].[category_id]
    LEFT JOIN [msdb].[dbo].[sysjobsteps] AS [sJSTP]
        ON [sJOB].[job_id] = [sJSTP].[job_id]
        AND [sJOB].[start_step_id] = [sJSTP].[step_id]
    LEFT JOIN [msdb].[sys].[database_principals] AS [sDBP]
        ON [sJOB].[owner_sid] = [sDBP].[sid]
    LEFT JOIN [msdb].[dbo].[sysjobschedules] AS [sJOBSCH]
        ON [sJOB].[job_id] = [sJOBSCH].[job_id]
    LEFT JOIN [msdb].[dbo].[sysschedules] AS [sSCH]
        ON [sJOBSCH].[schedule_id] = [sSCH].[schedule_id]
ORDER BY [JobName]




SELECT 
    [schedule_uid] AS [ScheduleID]
    , [name] AS [ScheduleName]
    , CASE [enabled]
        WHEN 1 THEN 'Yes'
        WHEN 0 THEN 'No'
      END AS [IsEnabled]
    , CASE 
        WHEN [freq_type] = 64 THEN 'Start automatically when SQL Server Agent starts'
        WHEN [freq_type] = 128 THEN 'Start whenever the CPUs become idle'
        WHEN [freq_type] IN (4,8,16,32) THEN 'Recurring'
        WHEN [freq_type] = 1 THEN 'One Time'
      END [ScheduleType]
    , CASE [freq_type]
        WHEN 1 THEN 'One Time'
        WHEN 4 THEN 'Daily'
        WHEN 8 THEN 'Weekly'
        WHEN 16 THEN 'Monthly'
        WHEN 32 THEN 'Monthly - Relative to Frequency Interval'
        WHEN 64 THEN 'Start automatically when SQL Server Agent starts'
        WHEN 128 THEN 'Start whenever the CPUs become idle'
      END [Occurrence]
    , CASE [freq_type]
        WHEN 4 THEN 'Occurs every ' + CAST([freq_interval] AS VARCHAR(3)) + ' day(s)'
        WHEN 8 THEN 'Occurs every ' + CAST([freq_recurrence_factor] AS VARCHAR(3)) 
                    + ' week(s) on '
                    + CASE WHEN [freq_interval] & 1 = 1 THEN 'Sunday' ELSE '' END
                    + CASE WHEN [freq_interval] & 2 = 2 THEN ', Monday' ELSE '' END
                    + CASE WHEN [freq_interval] & 4 = 4 THEN ', Tuesday' ELSE '' END
                    + CASE WHEN [freq_interval] & 8 = 8 THEN ', Wednesday' ELSE '' END
                    + CASE WHEN [freq_interval] & 16 = 16 THEN ', Thursday' ELSE '' END
                    + CASE WHEN [freq_interval] & 32 = 32 THEN ', Friday' ELSE '' END
                    + CASE WHEN [freq_interval] & 64 = 64 THEN ', Saturday' ELSE '' END
        WHEN 16 THEN 'Occurs on Day ' + CAST([freq_interval] AS VARCHAR(3)) 
                     + ' of every '
                     + CAST([freq_recurrence_factor] AS VARCHAR(3)) + ' month(s)'
        WHEN 32 THEN 'Occurs on '
                     + CASE [freq_relative_interval]
                        WHEN 1 THEN 'First'
                        WHEN 2 THEN 'Second'
                        WHEN 4 THEN 'Third'
                        WHEN 8 THEN 'Fourth'
                        WHEN 16 THEN 'Last'
                       END
                     + ' ' 
                     + CASE [freq_interval]
                        WHEN 1 THEN 'Sunday'
                        WHEN 2 THEN 'Monday'
                        WHEN 3 THEN 'Tuesday'
                        WHEN 4 THEN 'Wednesday'
                        WHEN 5 THEN 'Thursday'
                        WHEN 6 THEN 'Friday'
                        WHEN 7 THEN 'Saturday'
                        WHEN 8 THEN 'Day'
                        WHEN 9 THEN 'Weekday'
                        WHEN 10 THEN 'Weekend day'
                       END
                     + ' of every ' + CAST([freq_recurrence_factor] AS VARCHAR(3)) 
                     + ' month(s)'
      END AS [Recurrence]
    , CASE [freq_subday_type]
        WHEN 1 THEN 'Occurs once at ' 
                    + STUFF(
                 STUFF(RIGHT('000000' + CAST([active_start_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
        WHEN 2 THEN 'Occurs every ' 
                    + CAST([freq_subday_interval] AS VARCHAR(3)) + ' Second(s) between ' 
                    + STUFF(
                   STUFF(RIGHT('000000' + CAST([active_start_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
                    + ' & ' 
                    + STUFF(
                    STUFF(RIGHT('000000' + CAST([active_end_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
        WHEN 4 THEN 'Occurs every ' 
                    + CAST([freq_subday_interval] AS VARCHAR(3)) + ' Minute(s) between ' 
                    + STUFF(
                   STUFF(RIGHT('000000' + CAST([active_start_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
                    + ' & ' 
                    + STUFF(
                    STUFF(RIGHT('000000' + CAST([active_end_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
        WHEN 8 THEN 'Occurs every ' 
                    + CAST([freq_subday_interval] AS VARCHAR(3)) + ' Hour(s) between ' 
                    + STUFF(
                    STUFF(RIGHT('000000' + CAST([active_start_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
                    + ' & ' 
                    + STUFF(
                    STUFF(RIGHT('000000' + CAST([active_end_time] AS VARCHAR(6)), 6)
                                , 3, 0, ':')
                            , 6, 0, ':')
      END [Frequency]
    , STUFF(
            STUFF(CAST([active_start_date] AS VARCHAR(8)), 5, 0, '-')
                , 8, 0, '-') AS [ScheduleUsageStartDate]
    , STUFF(
            STUFF(CAST([active_end_date] AS VARCHAR(8)), 5, 0, '-')
                , 8, 0, '-') AS [ScheduleUsageEndDate]
    , [date_created] AS [ScheduleCreatedOn]
    , [date_modified] AS [ScheduleLastModifiedOn]
FROM [msdb].[dbo].[sysschedules]
ORDER BY [ScheduleName]


select 
       S.name AS JobName,
       SS.name AS ScheduleName,                    
       CASE(SS.freq_type)
            WHEN 1  THEN 'Once'
            WHEN 4  THEN 'Daily'
            WHEN 8  THEN (case when (SS.freq_recurrence_factor > 1) then  'Every ' + convert(varchar(3),SS.freq_recurrence_factor) + ' Weeks'  else 'Weekly'  end)
            WHEN 16 THEN (case when (SS.freq_recurrence_factor > 1) then  'Every ' + convert(varchar(3),SS.freq_recurrence_factor) + ' Months' else 'Monthly' end)
            WHEN 32 THEN 'Every ' + convert(varchar(3),SS.freq_recurrence_factor) + ' Months' -- RELATIVE
            WHEN 64 THEN 'SQL Startup'
            WHEN 128 THEN 'SQL Idle'
            ELSE '??'
        END AS Frequency,  
       CASE
            WHEN (freq_type = 1)                       then 'One time only'
            WHEN (freq_type = 4 and freq_interval = 1) then 'Every Day'
            WHEN (freq_type = 4 and freq_interval > 1) then 'Every ' + convert(varchar(10),freq_interval) + ' Days'
            WHEN (freq_type = 8) then (select 'Weekly Schedule' = MIN(D1+ D2+D3+D4+D5+D6+D7 )
                                        from (select SS.schedule_id,
                                                        freq_interval, 
                                                        'D1' = CASE WHEN (freq_interval & 1  <> 0) then 'Sun ' ELSE '' END,
                                                        'D2' = CASE WHEN (freq_interval & 2  <> 0) then 'Mon '  ELSE '' END,
                                                        'D3' = CASE WHEN (freq_interval & 4  <> 0) then 'Tue '  ELSE '' END,
                                                        'D4' = CASE WHEN (freq_interval & 8  <> 0) then 'Wed '  ELSE '' END,
                                                    'D5' = CASE WHEN (freq_interval & 16 <> 0) then 'Thu '  ELSE '' END,
                                                        'D6' = CASE WHEN (freq_interval & 32 <> 0) then 'Fri '  ELSE '' END,
                                                        'D7' = CASE WHEN (freq_interval & 64 <> 0) then 'Sat '  ELSE '' END
                                                    from msdb..sysschedules ss
                                                where freq_type = 8
                                            ) as F
                                        where schedule_id = SJ.schedule_id
                                    )
            WHEN (freq_type = 16) then 'Day ' + convert(varchar(2),freq_interval) 
            WHEN (freq_type = 32) then (select  freq_rel + WDAY 
                                        from (select SS.schedule_id,
                                                        'freq_rel' = CASE(freq_relative_interval)
                                                                    WHEN 1 then 'First'
                                                                    WHEN 2 then 'Second'
                                                                    WHEN 4 then 'Third'
                                                                    WHEN 8 then 'Fourth'
                                                                    WHEN 16 then 'Last'
                                                                    ELSE '??'
                                                                    END,
                                                    'WDAY'     = CASE (freq_interval)
                                                                    WHEN 1 then ' Sun'
                                                                    WHEN 2 then ' Mon'
                                                                    WHEN 3 then ' Tue'
                                                                    WHEN 4 then ' Wed'
                                                                    WHEN 5 then ' Thu'
                                                                    WHEN 6 then ' Fri'
                                                                    WHEN 7 then ' Sat'
                                                                    WHEN 8 then ' Day'
                                                                    WHEN 9 then ' Weekday'
                                                                    WHEN 10 then ' Weekend'
                                                                    ELSE '??'
                                                                    END
                                                from msdb..sysschedules SS
                                                where SS.freq_type = 32
                                                ) as WS 
                                        where WS.schedule_id = SS.schedule_id
                                        ) 
        END AS Interval,
        CASE (freq_subday_type)
            WHEN 1 then   left(stuff((stuff((replicate('0', 6 - len(active_start_time)))+ convert(varchar(6),active_start_time),3,0,':')),6,0,':'),8)
            WHEN 2 then 'Every ' + convert(varchar(10),freq_subday_interval) + ' seconds'
            WHEN 4 then 'Every ' + convert(varchar(10),freq_subday_interval) + ' minutes'
            WHEN 8 then 'Every ' + convert(varchar(10),freq_subday_interval) + ' hours'
            ELSE '??'
        END AS [Time],
        CASE SJ.next_run_date
            WHEN 0 THEN cast('n/a' as char(10))
            ELSE convert(char(10), convert(datetime, convert(char(8),SJ.next_run_date)),120)  + ' ' + left(stuff((stuff((replicate('0', 6 - len(next_run_time)))+ convert(varchar(6),next_run_time),3,0,':')),6,0,':'),8)
        END AS NextRunTime
from msdb.dbo.sysjobs S
left join msdb.dbo.sysjobschedules SJ on S.job_id = SJ.job_id  
left join msdb.dbo.sysschedules SS on SS.schedule_id = SJ.schedule_id
order by S.name
