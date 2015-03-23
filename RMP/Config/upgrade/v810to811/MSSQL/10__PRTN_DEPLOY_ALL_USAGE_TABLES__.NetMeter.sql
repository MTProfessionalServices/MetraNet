/*
	Proc: prtn_deploy_all_usage_partitioned_tables
	Calls prtn_deploy_usage_partitioned_table for Usage partitioned tables.
*/

IF OBJECT_ID('prtn_deploy_all_usage_tables', 'P') is not null
   drop procedure prtn_deploy_all_usage_tables
GO

PRINT N'CREATING PROCEDURE prtn_deploy_all_usage_tables'
GO

CREATE PROCEDURE prtn_deploy_all_usage_tables
AS
	SET NOCOUNT ON 
	
	DECLARE @err               INT,	-- last error
	        @rc                INT,	-- row count
	        @tab               VARCHAR(300),
	        @partition_schema  VARCHAR(100)

	SET @partition_schema = dbo.prtn_GetUsagePartitionSchemaName() 
	
	-- Abort if system isn't enabled for partitioning
	IF dbo.IsSystemPartitioned() = 0
	BEGIN
	    RAISERROR('System not enabled for partitioning.', 0, 1) 
	    RETURN 1
	END 


	PRINT '------ DEPLOYING PRODUCT VIEW TABLES ----------'

	DECLARE tabcur CURSOR  
	FOR
	    SELECT nm_table_name
	    FROM   t_prod_view
	    ORDER BY
	           nm_table_name 
	
	OPEN tabcur 
	FETCH tabcur INTO @tab

	WHILE (@@fetch_status >= 0)
	BEGIN
	    PRINT CHAR(13) + 'Deploying ' + @tab

	    EXEC prtn_deploy_usage_table @tab 
	    
	    FETCH tabcur INTO @tab
	END 
	DEALLOCATE tabcur 
	
	
	PRINT '------ DEPLOYING AMP TABLES ----------'
	
	PRINT 'DEPLOYING AGG_CHARGE_AUDIT_TRAIL TABLE'
	IF OBJECT_ID('agg_charge_audit_trail') IS NOT NULL
	    EXEC prtn_deploy_table 
	         @partition_table_name = N'agg_charge_audit_trail',
	         @pk_columns = N'id_payee ASC, id_usage_interval ASC, id_sess ASC',
	         @partition_schema = @partition_schema,
	         @partition_column = N'id_usage_interval' 
	
	PRINT 'DEPLOYING AGG_USAGE_AUDIT_TRAIL TABLE'
	IF OBJECT_ID('agg_usage_audit_trail') IS NOT NULL
	    EXEC prtn_deploy_table 
	         @partition_table_name = N'agg_usage_audit_trail',
	         @pk_columns = N'id_payee ASC, id_usage_interval ASC, id_sess ASC, is_realtime ASC',
	         @partition_schema = @partition_schema,
	         @partition_column = N'id_usage_interval'

	PRINT 'DEPLOYING AGG_PUSHED_USAGE TABLE'
	IF OBJECT_ID('agg_pushed_usage') IS NOT NULL
	    EXEC prtn_deploy_table 
	         @partition_table_name = N'agg_pushed_usage',
	         @pk_columns = N'id_acc ASC, id_sess ASC, old_usage_interval ASC',
	         @partition_schema = @partition_schema,
	         @partition_column = N'old_usage_interval'
	         
