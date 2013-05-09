IF OBJECT_ID('archive_queue_partition') IS NOT NULL 
	DROP PROCEDURE archive_queue_partition
GO

CREATE PROCEDURE archive_queue_partition(
    @update_stats    CHAR(1) = 'N',
    @sampling_ratio  VARCHAR(3) = '30',
    @current_time DATETIME = NULL,
    @result          NVARCHAR(4000) OUTPUT
)
AS
	/*
	How to run this stored procedure:	
	DECLARE @result NVARCHAR(2000)
	EXEC archive_queue_partition @result = @result OUTPUT
	PRINT @result
	
	Or if we want to update statistics and change current date/time also:	
	DECLARE @result			NVARCHAR(2000),
	        @current_time	DATETIME
	SET @current_time = GETDATE()
	EXEC archive_queue_partition 'Y',
	     30,
	     @current_time = @current_time,
	     @result = @result OUTPUT
	PRINT @result	
	*/
	
	SET NOCOUNT ON
	
	DECLARE @next_allow_run_time       DATETIME,
	        @current_id_partition      INT,
	        @new_current_id_partition  INT,
	        @old_id_partition          INT,
	        @no_need_to_run            BIT,
	        @meter_partition_function_name   NVARCHAR(50),
	        @meter_partition_schema_name     NVARCHAR(50),
	        @meter_partition_filegroup_name  NVARCHAR(50),
	        @meter_partition_field_name      NVARCHAR(50),
	        @sqlCommand                      NVARCHAR(MAX)
	
	IF @current_time IS NULL
	    SET @current_time = GETDATE()
	
	SET @meter_partition_filegroup_name = dbo.prtn_GetMeterPartitionFileGroupName()
	SET @meter_partition_function_name = dbo.prtn_GetMeterPartitionFunctionName()
	SET @meter_partition_schema_name = dbo.prtn_GetMeterPartitionSchemaName()
	SET @meter_partition_field_name = 'id_partition'
	
	BEGIN TRY
		IF dbo.IsSystemPartitioned() = 0
			RAISERROR('DB is not partitioned. [archive_queue_partition] SP can be executed only on paritioned DB.', 16, 1)

		EXEC archive_queue_partition_get_status @current_time = @current_time,
		     @next_allow_run_time = @next_allow_run_time OUT,
		     @current_id_partition = @current_id_partition OUT,
		     @new_current_id_partition = @new_current_id_partition OUT,
		     @old_id_partition = @old_id_partition OUT,
		     @no_need_to_run = @no_need_to_run OUT
		
		IF @no_need_to_run = 1
		    RETURN
		
		IF @next_allow_run_time IS NULL
			RAISERROR ('Partition Schema and Default "id_partition" had already been updated. Skipping this step...', 0, 1)
		ELSE
		    EXEC archive_queue_partition_apply_next_partition
		         @new_current_id_partition = @new_current_id_partition,
		         @current_time = @current_time,
		         @meter_partition_function_name = @meter_partition_function_name,
		         @meter_partition_schema_name = @meter_partition_schema_name,
		         @meter_partition_filegroup_name = @meter_partition_filegroup_name,
		         @meter_partition_field_name = @meter_partition_field_name
		
		/* If it is the 1-st time of running [archive_queue_partition] there are only 2 partitions.
		* It is early to archive data.
		* When 3-rd partition is created the oldest one is archiving.
		* So, meter tables always have 2 partition.*/
		IF (
		       (
		           SELECT COUNT(current_id_partition)
		           FROM   t_archive_queue_partition
		       ) > 2
		   )
		BEGIN
			
		    /* Append temp table ##id_sess_to_keep with IDs of sessions from the 'oldest' partition that should not be archived */
		    EXEC archive_queue_partition_get_id_sess_to_keep @old_id_partition = @old_id_partition
		    
		    /* Move data from old to current partition for all meter tables if id_sess in ##id_sess_to_keep */
		    /* Switch out data from meter tables with @old_id_partition to temp_meter_tables */
		    EXEC archive_queue_partition_switch_out_partition_all
				@number_of_partition = @old_id_partition,
				@partition_filegroup_name = @meter_partition_filegroup_name
		    
		    IF OBJECT_ID('tempdb..##id_sess_to_keep') IS NOT NULL
		        DROP TABLE ##id_sess_to_keep
		    
		    /* Drop temp_meter_tables (with data), that were switched */
		    EXEC archive_queue_partition_drop_temp_tables
		    
		    /* Remove obsolete boundary value that divides 2 empty partitions.
		    * (Ensure no data movement ) */
		    DECLARE @obsoleteRange INT
		    SET @obsoleteRange = @old_id_partition - 1
		    IF EXISTS(
		           SELECT *
		           FROM   sys.partition_functions pf
		                  JOIN sys.partition_range_values prv
		                       ON  prv.function_id = pf.function_id
		           WHERE  pf.name = @meter_partition_function_name
		                  AND prv.value = @obsoleteRange
		       )
		    BEGIN
		        SET @sqlCommand = 'ALTER PARTITION FUNCTION ' + @meter_partition_function_name 
		            + '() MERGE RANGE (' + CAST(@obsoleteRange AS NVARCHAR(20)) + ')'
		        EXEC (@sqlCommand)
		    END
		END
		
		/* Update next_allow_run value in [t_archive_queue_partition] table.
		* This is an indicator of successful archivation*/
		EXEC prtn_GetNextAllowRunDate @current_datetime = @current_time,
			 @next_allow_run_date = @next_allow_run_time OUT
		
		UPDATE t_archive_queue_partition
		SET next_allow_run = @next_allow_run_time
		WHERE current_id_partition = @new_current_id_partition
		
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
		    ROLLBACK TRANSACTION
		    
		DECLARE @ErrorSeverity  INT,
		        @ErrorState     INT
		
		SELECT @result = ERROR_MESSAGE(),
		       @ErrorSeverity = ERROR_SEVERITY(),
		       @ErrorState = ERROR_STATE()
		
		RAISERROR (@result, @ErrorSeverity, @ErrorState)
		
		RETURN
	END CATCH
		
	DECLARE @tab1                   NVARCHAR(1000),
	        @sql1                   NVARCHAR(4000),
	        @NU_varStatPercentChar  VARCHAR(255)
	
	IF (@update_stats = 'Y')
	BEGIN
	    DECLARE c1 CURSOR FAST_FORWARD 
	    FOR
	        SELECT nm_table_name
	        FROM   t_service_def_log
	    
	    OPEN c1 
	    FETCH NEXT FROM c1 INTO @tab1  
	    WHILE (@@fetch_status = 0)
	    BEGIN
	        IF @sampling_ratio < 5
	            SET @NU_varStatPercentChar = ' WITH SAMPLE 5 PERCENT '
	        ELSE 
	        IF @sampling_ratio >= 100
	            SET @NU_varStatPercentChar = ' WITH FULLSCAN '
	        ELSE
	            SET @NU_varStatPercentChar = ' WITH SAMPLE '
	                + CAST(@sampling_ratio AS VARCHAR(20)) + ' PERCENT '
	        
	        SET @sql1 = 'UPDATE STATISTICS ' + @tab1 + @NU_varStatPercentChar 
	        EXECUTE (@sql1)  
	        IF (@@error <> 0)
	        BEGIN
	            SET @result = 
	                '7000022-archive_queues operation failed-->Error in update stats'
	            
	            CLOSE c1 
	            DEALLOCATE c1 
				RAISERROR (@result, 16, 1)
	        END
	        
	        FETCH NEXT FROM c1 INTO @tab1
	    END 
	    CLOSE c1 
	    DEALLOCATE c1	    
	    SET @sql1 = 'UPDATE STATISTICS t_session ' + @NU_varStatPercentChar 
	    EXECUTE (@sql1)  
	    SET @sql1 = 'UPDATE STATISTICS t_session_set ' + @NU_varStatPercentChar 
	    EXECUTE (@sql1)  
	    SET @sql1 = 'UPDATE STATISTICS t_session_state ' + @NU_varStatPercentChar 
	    EXECUTE (@sql1)  
	    SET @sql1 = 'UPDATE STATISTICS t_message' + @NU_varStatPercentChar 
	    EXECUTE (@sql1)
	END
	
	SET @result = '0-archive_queue operation successful'
