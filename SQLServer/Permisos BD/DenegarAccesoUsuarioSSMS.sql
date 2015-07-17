

CREATE TRIGGER [TR_LOGON_APP]
ON ALL SERVER 
FOR LOGON
AS
BEGIN

	DECLARE @program_name nvarchar(128)
	DECLARE @host_name nvarchar(128)

	SELECT @program_name = program_name, 
		@host_name = host_name
	FROM sys.dm_exec_sessions AS c
	WHERE c.session_id = @@spid

	
	IF ORIGINAL_LOGIN() IN('jorge') 
		AND @program_name LIKE '%Management%Studio%' 
	BEGIN
		RAISERROR('This login is for application use only.',16,1)
		ROLLBACK;
	END
END;

