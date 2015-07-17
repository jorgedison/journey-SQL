USE [DATABASE]
GO

-- Creates the login jorge with password '340$Uuxwp7Mcxo7Khy'.
CREATE LOGIN jorge 
    WITH PASSWORD = '340$Uuxwp7Mcxo7Khy';
GO

-- Creates a database user for the login created above.
CREATE USER jorge FOR LOGIN jorge;
GO

