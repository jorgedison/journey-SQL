USE master
GO

-- find all logins and their database access and role memberships in one row
DECLARE @dbname nvarchar(123)
, @id int
, @max int
, @cmdDBUsersRoles nvarchar(max)

-- temp table to stored the databases
IF OBJECT_ID('tempdb..#db_list') IS NOT NULL
    DROP TABLE #db_list

CREATE TABLE #db_list
(
    id int identity (1,1)
    , dbname nvarchar(123)
);

-- temp table to store the databases, users, roles that users belong to
IF OBJECT_ID('tempdb..#dbs_users_roles') IS NOT NULL
	DROP TABLE #dbs_users_roles

CREATE TABLE #dbs_users_roles
(
	dbname nvarchar(123),
	dbuser nvarchar(123),
	dbrole nvarchar(123),
	account_type nvarchar(123),
	create_date datetime,
	modify_date datetime
);

-- load the database list into the temp table
INSERT INTO #db_list
SELECT db.name
FROM sys.databases db
WHERE db.state = 0;

-- initialize the counters 
SELECT @id = 1, @max = max(id)
FROM #db_list

-- loop to process 
WHILE (@id <= @max)
BEGIN
    SELECT @dbname = dbname
    FROM #db_list
    WHERE id = @id;

	SET @cmdDBUsersRoles = 'USE ' +@dbname+
		' SELECT DB_NAME(), 
			dp.name,
			rp.name,
			dp.type_desc,
			dp.create_date,
			dp.modify_date
		FROM sys.database_role_members drm JOIN sys.database_principals rp
				ON drm.role_principal_id = rp.principal_id
			JOIN sys.database_principals dp
				ON drm.member_principal_id = dp.principal_id';

	INSERT INTO #dbs_users_roles
	EXEC (@cmdDBUsersRoles);

	SET @id = @id + 1;
END


--SELECT dsr.dbname AS [Database Name],
--	dsr.dbuser AS [Database User],
--	dsr.dbrole AS [Database Role],
--	dsr.account_type AS [Account Type],
--	dsr.create_date,
--	dsr.modify_date
--FROM #dbs_users_roles AS dsr;


IF OBJECT_ID('tempdb..#dbs_users') IS NOT NULL
	DROP TABLE #dbs_users;

SELECT dsr.dbname AS [Database Name],
	dsr.dbuser AS [Database User],
	dsr.account_type AS [Account Type],
	dsr.create_date,
	dsr.modify_date,
	STUFF((SELECT '; ' + dr.dbrole 
			FROM #dbs_users_roles AS dr
			WHERE dr.dbname = dsr.dbname AND dr.dbuser = dsr.dbuser
			FOR XML PATH('')),1,1,''
	) AS [DB Roles]
INTO #dbs_users 
FROM #dbs_users_roles AS dsr
GROUP BY dsr.dbname, dsr.dbuser, dsr.account_type, dsr.create_date, dsr.modify_date


SELECT /*u.[Database Name],*/ u.[Database User],
	u.[Account Type],
	STUFF((SELECT ' ' +'%[DB]: ' +urs.[Database Name]+ ' [DB Role(s)]:' +urs.[DB Roles]
		FROM #dbs_users urs
		WHERE urs.[Database User] = u.[Database User]
		FOR XML PATH('')),1,1,''
	) [DB Access and Roles]
FROM #dbs_users u
GROUP BY /*u.[Database Name],*/ u.[Database User], u.[Account Type]

