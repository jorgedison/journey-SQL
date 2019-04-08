-- To Grant access to a Windows Login
USE Master;
GO
GRANT ALTER TRACE TO [DomainNAME\WindowsLogin]
GO

-- To Grant access to a SQL Login
USE master;
GO
GRANT ALTER TRACE TO nameuser
GO
