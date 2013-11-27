/*__ARCH_EXPORT_AMP_TABLES_SP__*/ CREATE PROCEDURE [dbo].[arch_export_amp_tables]
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
	   IF OBJECT_ID('agg_usage_audit_trail') IS NULL
	   BEGIN
	   	PRINT('WARNING! AGG_USAGE_AUDIT_TRAIL table does not exist in database!!!!')
	   	RETURN
	   END
	   					   		
	   SET @sql = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(''bcpview'')) DROP VIEW bcpview'
	   EXEC (@sql)
	   
		
		--bcp out the t_acc_usage table
	   SELECT @sql = N'CREATE VIEW bcpview as 
							SELECT auat.* FROM agg_usage_audit_trail auat WITH (NOLOCK) 
								INNER JOIN tempdb..tmp_t_acc_usage act WITH (NOLOCK) 
									ON auat.id_sess = act.id_sess where act.bucket = ' + CAST(@acc AS VARCHAR(10)) 
										+ ' and auat.id_sess between ' + CAST(@minid AS VARCHAR(10)) 
											+ ' and '  + CAST(@maxid AS VARCHAR(10))                          
	   EXEC (@sql)
		
	   SELECT @sql = 'bcp "' + db_name() + '..bcpview" out "' +  
					   @path + '\agg_usage_audit_trail_' + CAST(@interval_id AS VARCHAR (10)) + '_' + CAST(@acc AS VARCHAR (10)) + '.txt" -T -n'
										   
	   INSERT INTO ##bcpoutput EXEC master.dbo.xp_cmdshell @sql
	  
	  
	   IF (SELECT count(*) FROM ##bcpoutput) = 0 
	   BEGIN
		  	RAISERROR('1000007-archive operation failed-->Error in bcp out amp table, check the user permissions',16,1)
		  	RETURN
	   END


	   IF EXISTS(SELECT NULL FROM ##bcpoutput 
					  WHERE OutputLine LIKE '%Error%' 
								OR OutputLine LIKE '%ODBC SQL Server Driver%'
								OR OutputLine LIKE '%is not recognized as an internal or external command%')
	   BEGIN
	   	   SELECT * FROM ##bcpoutput
		  		RAISERROR('1000008-archive operation failed-->Error in bcp out agg_usage_audit_trial table, check the archive directory or hard disk space or database name or servername',16,1)
		  		RETURN
	   END
	   
	   --Truncate the temp table after every bcp operation
	   TRUNCATE TABLE ##bcpoutput
	   
	   IF OBJECT_ID('agg_charge_audit_trail') IS NULL
	   BEGIN
	   	PRINT('WARNING! AGG_CHARGE_AUDIT_TRAIL table does not exist in database!!!!')
	   	RETURN
	   END
	   					   		
	   SET @sql = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(''bcpview'')) DROP VIEW bcpview'
	   EXEC (@sql)
	   
		
		--bcp out the t_acc_usage table
	   SELECT @sql = N'CREATE VIEW bcpview as 
							SELECT acat.* FROM agg_charge_audit_trail acat WITH (NOLOCK) 
								INNER JOIN tempdb..tmp_t_acc_usage act WITH (NOLOCK) 
									ON acat.id_sess = act.id_sess where act.bucket = ' + CAST(@acc AS VARCHAR(10)) 
										+ ' and acat.id_sess between ' + CAST(@minid AS VARCHAR(10)) 
											+ ' and '  + CAST(@maxid AS VARCHAR(10))                          
	   EXEC (@sql)
		
	   SELECT @sql = 'bcp "' + db_name() + '..bcpview" out "' +  
					   @path + '\agg_charge_audit_trail_' + CAST(@interval_id AS VARCHAR (10)) + '_' + CAST(@acc AS VARCHAR (10)) + '.txt" -T -n'
										   
	   INSERT INTO ##bcpoutput EXEC master.dbo.xp_cmdshell @sql
	  
	  
	   IF (SELECT count(*) FROM ##bcpoutput) = 0 
	   BEGIN
		  	RAISERROR('1000007-archive operation failed-->Error in bcp out amp table, check the user permissions',16,1)
		  	RETURN
	   END


	   IF EXISTS(SELECT NULL FROM ##bcpoutput 
					  WHERE OutputLine LIKE '%Error%' 
								OR OutputLine LIKE '%ODBC SQL Server Driver%'
								OR OutputLine LIKE '%is not recognized as an internal or external command%')
	   BEGIN
	   	   SELECT * FROM ##bcpoutput
		  		RAISERROR('1000008-archive operation failed-->Error in bcp out agg_charge_audit_trial table, check the archive directory or hard disk space or database name or servername',16,1)
		  		RETURN
	   END
	   
	   --Truncate the temp table after every bcp operation
	   TRUNCATE TABLE ##bcpoutput	
	    									
	END