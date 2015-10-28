USE DATABASE
GO

/* 
EXEC dbo.JSONreturn @tblObjNameFQ='[DATABASE].[SCHEMA].[TABLE]';
*/

CREATE PROCEDURE dbo.JSONreturn
(
@committedRead BIT = 0 --> if 1 THEN committed else uncommitted read
,@debugmode BIT = 0    --> if 1 display certain outputs
,@tblObjNameFQ VARCHAR(128) --> fully qualified table object name, i.e. db.schema.object_name
,@stringJSON NVARCHAR(MAX) = null OUTPUT
)

AS
BEGIN

    IF @committedRead=0
    BEGIN
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED; --> evaluate if necessary in test phase
    END
        ELSE IF @committedRead=1
		BEGIN
			SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
		END

    SET NOCOUNT ON;

    IF (PATINDEX('%[\.]%',@tblObjNameFQ)<1 AND patindex('%#%',@tblObjNameFQ)<1) OR LEN(@tblObjNameFQ)>(3*128)
    BEGIN
        PRINT 'table (object) name not fully qualified or invalid!'
        RETURN -1
    END

    DECLARE 
    @objname VARCHAR(128)
    ,@dbname VARCHAR(128)
    ,@schema VARCHAR(128)
    ,@maxColNum INT
    ,@inc INT
    ,@dqsl_misc VARCHAR(MAX)
    ,@dsql_wrapper VARCHAR(MAX)
    ,@dsql_what VARCHAR(MAX)
    ,@dsql_where VARCHAR(MAX)
    ,@dsql_complete VARCHAR(MAX)

    CREATE TABLE #maxColNum (column_id INT)
    CREATE TABLE #ColPrep (colString VARCHAR(MAX), column_id INT)
    CREATE TABLE #JSONoutput (string nVARCHAR(MAX))

    IF PATINDEX('%#%',@tblObjNameFQ)>0
    BEGIN
        SET @objname = (PARSENAME(@tblObjNameFQ,1))
        SET @dbname = 'tempdb'
    END
    ELSE IF PATINDEX('%#%',@tblObjNameFQ)<1
        BEGIN
			SET @dbname = SUBSTRING(@tblObjNameFQ,1,PATINDEX('%[\.]%',@tblObjNameFQ)-1)
			SET @objname = CONVERT(VARCHAR,(PARSENAME(@tblObjNameFQ,1)))
			SET @schema = CONVERT(VARCHAR,(PARSENAME(@tblObjNameFQ,2)))
		END

    --SELECT @objname[@objname], @dbname[@dbname], @schema[@schema]
    --SELECT @dbname+'.'+@schema+'.'+@objname

    SET @dqsl_misc =
    '
    SELECT MAX(column_id) 
    FROM '+@dbname+'.sys.columns 
    WHERE object_id = 
    (SELECT object_id FROM '+@dbname+'.sys.objects WHERE type = ''U'' and name like ''%'+@objname+'%'')
    '
    INSERT INTO #maxColNum
    EXEC(@dqsl_misc)

    SET @maxColNum = (SELECT column_id FROM #maxColNum)
    SET @dsql_what = ''

    SET @dsql_wrapper = 
    '
    SELECT ''['' + STUFF((SELECT 
    '',{''+<<REPLACE>>
    +''}''
    '
    SET @dsql_where =
    'FROM '+@dbname+'.'+CASE WHEN @schema is null THEN '' ELSE @schema END+'.'+@objname+' t1 FOR XML PATH(''''), type
        ).value(''.'', ''VARCHAR(MAX)''), 1, 1, '''') + '']''
    '

    SET @dqsl_misc =
    'SELECT ''"''+sysc.name+''": '' +CASE WHEN syst.name like ''%time%'' or syst.collationid is not null THEN ''"''''+cast(''+sysc.name+'' as VARCHAR(MAX))+''''",'' WHEN syst.name = ''bit'' THEN ''''''+cast((CASE WHEN ''+sysc.name+''=1 THEN ''''true'''' ELSE ''''false'''' END) as VARCHAR(MAX))+'''','' ELSE ''''''+cast(''+sysc.name+'' AS VARCHAR(MAX))+'''','' END as colString, sysc.column_id FROM '+@dbname+'.sys.columns sysc JOIN '+@dbname+'.sys.systypes syst on sysc.system_type_id = syst.xtype and syst.xtype <> 240 and syst.name <> ''sysname'' WHERE object_id = (SELECT object_id FROM '+@dbname+'.sys.objects WHERE type = ''U'' and name like ''%'+@objname+'%'') order by sysc.column_id'
    INSERT INTO #ColPrep
    EXEC(@dqsl_misc)

    SET @inc = (SELECT MIN(column_id) FROM #ColPrep)


    WHILE @inc<=@maxColNum
    BEGIN
		SET @dsql_what = @dsql_what+(SELECT CASE 
		WHEN @inc = @maxColNum THEN REPLACE(colString,',','') 
	ELSE colString END 
	FROM #ColPrep WHERE column_id = @inc)

    SET @inc=@inc+1

    IF @inc>@maxColNum
	SET @dsql_what = ''''+@dsql_what+''''

    IF @inc>@maxColNum
	BREAK
        ELSE
		CONTINUE
    END

    SET @dsql_complete = REPLACE(@dsql_wrapper,'<<REPLACE>>',@dsql_what)+@dsql_where

    INSERT INTO #JSONoutput
    EXEC(@dsql_complete)

    SET @stringJSON = (SELECT string FROM #JSONoutput)

	SELECT * FROM #JSONoutput
END