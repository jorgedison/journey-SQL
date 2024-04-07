SELECT 
    'CREATE LOGIN [' + name + '] WITH PASSWORD = ' + CONVERT(VARCHAR(MAX), password_hash, 1) + ' HASHED, SID = ' + CONVERT(VARCHAR(MAX), sid, 1) + ', DEFAULT_DATABASE=[' + default_database_name + ']' 
FROM 
    sys.sql_logins 
WHERE 
    type_desc = 'SQL_LOGIN';
