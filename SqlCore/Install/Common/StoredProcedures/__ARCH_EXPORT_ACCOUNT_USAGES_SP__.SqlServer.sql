CREATE PROCEDURE arch_export_account_usages
(
	@path NVARCHAR(1000),
	@acc INT,
	@interval_id INT,
	@minid INT,
	@maxid INT
)
AS
	SET NOCOUNT ON
	
	DECLARE @sql NVARCHAR(4000)
		
	BEGIN
						   		
	   SET @sql = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(''bcpview'')) DROP VIEW bcpview'
	   EXEC (@sql)
		
		--bcp out the t_acc_usage table
	   SELECT @sql = N'CREATE VIEW bcpview as 
							SELECT au.* FROM t_acc_usage au WITH (NOLOCK) 
								INNER JOIN tempdb..tmp_t_acc_usage act WITH (NOLOCK) 
									ON au.id_sess = act.id_sess where bucket = ' + CAST(@acc AS VARCHAR(10)) 
										+ ' and au.id_sess between ' + CAST(@minid AS VARCHAR(10)) 
											+ ' and '  + CAST(@maxid AS VARCHAR(10))                          
	   EXEC (@sql)
		
	   SELECT @sql = 'bcp "' + db_name() + '..bcpview" out "' +  
					   @path + '\t_acc_usage_' + CAST(@interval_id AS VARCHAR (10)) + '_' + CAST(@acc AS VARCHAR (10)) + '.txt" -T -n'
										   
	   INSERT INTO ##bcpoutput EXEC master.dbo.xp_cmdshell @sql
	  
	  
	   IF (SELECT count(*) FROM ##bcpoutput) = 0 
	   BEGIN
		  	RAISERROR('1000007-archive operation failed-->Error in bcp out usage table, check the user permissions',16,1)
		  	RETURN
	   END


	   IF EXISTS(SELECT NULL FROM ##bcpoutput 
					  WHERE OutputLine LIKE '%Error%' 
								OR OutputLine LIKE '%ODBC SQL Server Driver%'
								OR OutputLine LIKE '%is not recognized as an internal or external command%')
	   BEGIN
	   	   SELECT * FROM ##bcpoutput
		  		RAISERROR('1000008-archive operation failed-->Error in bcp out usage table, check the archive directory or hard disk space or database name or servername',16,1)
		  		RETURN
	   END
	   
	   --Truncate the temp table after every bcp operation
	   TRUNCATE TABLE ##bcpoutput										
	END