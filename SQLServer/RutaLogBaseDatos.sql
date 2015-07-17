USE [master] 
GO

SET NOCOUNT ON
DECLARE @Kb float
DECLARE @PageSize float
DECLARE @SQL varchar(max)

SELECT @Kb = 1024.0
SELECT @PageSize=v.low/@Kb FROM master..spt_values v WHERE v.number=1 AND v.type='E'

IF OBJECT_ID('tempdb.dbo.#FileSize') IS NOT NULL  DROP TABLE #FileSize CREATE TABLE #FileSize (  DatabaseName sysname,  [FileName] varchar(max),  FileSize int,  FileGroupName varchar(max),  LogicalName varchar(max)
)

IF OBJECT_ID('tempdb.dbo.#FileStats') IS NOT NULL  DROP TABLE #FileStats CREATE TABLE #FileStats (  FileID int,  FileGroup int,  TotalExtents int,  UsedExtents int,  LogicalName varchar(max),  FileName varchar(max)
)

IF OBJECT_ID('tempdb.dbo.#LogSpace') IS NOT NULL  DROP TABLE #LogSpace CREATE TABLE #LogSpace (  DatabaseName sysname,  LogSize float,  SpaceUsedPercent float,  Status bit
)

INSERT #LogSpace EXEC ('DBCC sqlperf(logspace)')

DECLARE @DatabaseName sysname

DECLARE cur_Databases CURSOR FAST_FORWARD FOR  SELECT DatabaseName = [name] FROM dbo.sysdatabases WHERE [name] <> 'RVR_FSA' ORDER BY DatabaseName OPEN cur_Databases FETCH NEXT FROM cur_Databases INTO @DatabaseName WHILE @@FETCH_STATUS = 0
  BEGIN
 print @DatabaseName
 SET @SQL = '
USE [' + @DatabaseName + '];
DBCC showfilestats;
INSERT #FileSize (DatabaseName, [FileName], FileSize, FileGroupName, LogicalName) SELECT ''' +@DatabaseName + ''', filename, size, ISNULL(FILEGROUP_NAME(groupid),''LOG''), [name]  FROM dbo.sysfiles sf; '
PRINT @SQL
 INSERT #FileStats EXECUTE (@SQL)
 FETCH NEXT FROM cur_Databases INTO @DatabaseName
  END

CLOSE cur_Databases
DEALLOCATE cur_Databases


SELECT
 DatabaseName = fsi.DatabaseName,
 FileGroupName = fsi.FileGroupName,
 LogicalName = RTRIM(fsi.LogicalName),
 [FileName] = RTRIM(fsi.FileName),
 DriveLetter = LEFT(RTRIM(fsi.FileName),2),  FileSize = CAST(fsi.FileSize*@PageSize/@Kb as decimal(15,2)),  UsedSpace = CAST(ISNULL((fs.UsedExtents*@PageSize*8.0/@Kb), fsi.FileSize*@PageSize/@Kb * ls.SpaceUsedPercent/100.0) as decimal(15,2)),  FreeSpace = CAST(ISNULL(((fsi.FileSize - UsedExtents*8.0)*@PageSize/@Kb), (100.0-ls.SpaceUsedPercent)/100.0 * fsi.FileSize*@PageSize/@Kb) as decimal(15,2)),  [FreeSpace %] = CAST(ISNULL(((fsi.FileSize - UsedExtents*8.0) / fsi.FileSize * 100.0), 100-ls.SpaceUsedPercent) as decimal(15,2))  FROM #FileSize fsi  LEFT JOIN #FileStats fs  ON fs.FileName = fsi.FileName  LEFT JOIN #LogSpace ls  ON ls.DatabaseName = fsi.DatabaseName  ORDER BY 5, 8 DESC