CREATE PROCEDURE arch_delete_usage_data_by_partition_name
(
    @partition_name  NVARCHAR(30),
    @result          NVARCHAR(4000) OUTPUT
)
AS
BEGIN
	DECLARE @sql_cmd                     NVARCHAR(MAX),
	        @partition_number            INT,
	        @acc_usage_partition_number  INT,
	        @table_name                  NVARCHAR(30),
	        @id_view_from_cur            INT,
	        @table_name_temp             NVARCHAR(30)           
	
	IF OBJECT_ID('tempdb..##id_view') IS NOT NULL
	    DROP TABLE ##id_view
	
	EXEC arch_get_prtn_number_by_prtn_name @partition_name = @partition_name,
	     @table_name = N't_acc_usage',
	     @partition_number = @acc_usage_partition_number OUTPUT
	
	SELECT DISTINCT id_view INTO ##id_view
	FROM   t_acc_usage
	WHERE  $PARTITION.UsagePartitionFunction(id_usage_interval) = @acc_usage_partition_number	
	-------------------------------------------------------------------------------------------
	---archive_delete data from product view tables by partition_name
	-------------------------------------------------------------------------------------------
	DECLARE pv_cur CURSOR FAST_FORWARD 
	FOR
	    SELECT id_view
	    FROM   ##id_view
	
	OPEN pv_cur
	FETCH NEXT FROM pv_cur INTO @id_view_from_cur
	WHILE (@@fetch_status = 0)
	BEGIN
	    SELECT @table_name = nm_table_name
	    FROM   t_prod_view
	    WHERE  id_view = @id_view_from_cur --and nm_table_name not like '%temp%'
	    
	    EXEC arch_get_prtn_number_by_prtn_name @partition_name = @partition_name,
	         @table_name = @table_name,
	         @partition_number = @partition_number OUTPUT
	    
	    SET @table_name_temp = @table_name + '_arch'
	    
	    --clone table to temp table
		EXEC Clone_Table_On_FileGroup
				@SourceSchema = N'dbo',
				@SourceTable = @table_name,
				@DestinationSchema = N'dbo',
				@DestinationTable = @table_name_temp,
				@RecreateIfExists = 1,
				@FileGroup = @partition_name
	    
	     --Delete from product view tables using switch funtionality
	    SET @sql_cmd = N'ALTER TABLE ' + @table_name + 
							' SWITCH PARTITION ' + CAST(@partition_number AS NVARCHAR(3)) + 
							'TO ' + @table_name_temp    	           
	    
	    EXEC (@sql_cmd)
	    
	    IF (@@error <> 0)
	    BEGIN
	        SET @result = '2000015-archive operation failed-->Error in product view Delete operation'
	        
	        CLOSE pv_cur
	        DEALLOCATE pv_cur
	        RETURN
	    END
	    
	    FETCH NEXT FROM pv_cur INTO @id_view_from_cur
	END
	CLOSE pv_cur
	DEALLOCATE pv_cur	
	
	-------------------------------------------------------------------------------------------
	---archive_delete data from t_acc_usage table by partition_name
	-------------------------------------------------------------------------------------------
	
	--clone t_acc_usage table to temp table
	EXEC Clone_Table_On_FileGroup
				@SourceSchema = N'dbo',
				@SourceTable = N't_acc_usage',
				@DestinationSchema = N'dbo',
				@DestinationTable = N't_acc_usage_arch',
				@RecreateIfExists = 1,
				@FileGroup = @partition_name

	--Delete from t_acc_usage table				
	SET @sql_cmd = N'ALTER TABLE t_acc_usage SWITCH PARTITION ' + CAST(@partition_number AS NVARCHAR(3)) + 
							'TO t_acc_usage_arch'
							
	EXEC (@sql_cmd)
	
	IF (@@ERROR <> 0)
	    SET @result = '2000016-archive operation failed-->Error in Delete t_acc_usage operation'
	    
    -------------------------------------------------------------------------------------------
	---archive_delete data from agg_usage_audit_trail table by partition_name
	------------------------------------------------------------------------------------------- 
    IF OBJECT_ID('agg_usage_audit_trail')IS NOT NULL
	BEGIN
		EXEC arch_get_prtn_number_by_prtn_name @partition_name = @partition_name,
		 @table_name = N'agg_usage_audit_trail',
		 @partition_number = @partition_number OUTPUT
	     
    		--clone t_acc_usage table to temp table
		EXEC Clone_Table_On_FileGroup
					@SourceSchema = N'dbo',
					@SourceTable = N'agg_usage_audit_trail',
					@DestinationSchema = N'dbo',
					@DestinationTable = N'agg_usage_audit_trail_arch',
					@RecreateIfExists = 1,
					@FileGroup = @partition_name

		--Delete from t_acc_usage table				
		SET @sql_cmd = N'ALTER TABLE agg_usage_audit_trail SWITCH PARTITION ' + CAST(@partition_number AS NVARCHAR(3)) + 
								'TO agg_usage_audit_trail_arch'
								
		EXEC (@sql_cmd)
		
		IF (@@ERROR <> 0)
			SET @result = '2000016-archive operation failed-->Error in Delete data from  agg_usage_audit_trail table'
	 END   
	-------------------------------------------------------------------------------------------
	---archive_delete data from agg_charge_audit_trail table by partition_name
	-------------------------------------------------------------------------------------------   
	IF OBJECT_ID('agg_charge_audit_trail')IS NOT NULL
	BEGIN
		EXEC arch_get_prtn_number_by_prtn_name @partition_name = @partition_name,
		 @table_name = N'agg_charge_audit_trail',
		 @partition_number = @partition_number OUTPUT
	     
    		--clone t_acc_usage table to temp table
		EXEC Clone_Table_On_FileGroup
					@SourceSchema = N'dbo',
					@SourceTable = N'agg_charge_audit_trail',
					@DestinationSchema = N'dbo',
					@DestinationTable = N'agg_charge_audit_trail_arch',
					@RecreateIfExists = 1,
					@FileGroup = @partition_name

		--Delete from t_acc_usage table				
		SET @sql_cmd = N'ALTER TABLE agg_charge_audit_trail SWITCH PARTITION ' + CAST(@partition_number AS NVARCHAR(3)) + 
								'TO agg_charge_audit_trail_arch'
								
		EXEC (@sql_cmd)
		
		IF (@@ERROR <> 0)
			SET @result = '2000016-archive operation failed-->Error in Delete data from  agg_charge_audit_trail table'
	END
	    
END