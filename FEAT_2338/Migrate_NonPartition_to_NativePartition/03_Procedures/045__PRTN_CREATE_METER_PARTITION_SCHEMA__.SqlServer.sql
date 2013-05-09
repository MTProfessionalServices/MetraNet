IF OBJECT_ID('prtn_CreateMeterPartitionSchema') IS NOT NULL 
DROP PROCEDURE prtn_CreateMeterPartitionSchema
GO
                CREATE PROCEDURE prtn_CreateMeterPartitionSchema
					@current_dt DATETIME = NULL
				AS
				DECLARE @meter_partition_function_name NVARCHAR(50),
						@meter_partition_schema_name NVARCHAR(50),
						@meter_partition_filegroup_name NVARCHAR(50),
						@meter_partition_id INT,
						@sqlCommand NVARCHAR(MAX)
						
				IF @current_dt IS NULL
					SET @current_dt = GETDATE()
					
				BEGIN TRY

					IF dbo.IsSystemPartitioned()=0
						RAISERROR('System not enabled for partitioning.', 16, 1)

					SET @meter_partition_id = 1
					SET @meter_partition_filegroup_name = dbo.prtn_GetMeterPartitionFileGroupName()
					SET @meter_partition_function_name = dbo.prtn_GetMeterPartitionFunctionName()
					SET @meter_partition_schema_name = dbo.prtn_GetMeterPartitionSchemaName()

					IF NOT EXISTS(SELECT * FROM sys.partition_schemes ps WHERE ps.name = @meter_partition_schema_name)
					BEGIN
						------------------------------------------------------------------------------
						----------create file group for meter partition ----------------------------
						------------------------------------------------------------------------------ 
								EXEC prtn_AddFileGroup @meter_partition_filegroup_name

					    ------------------------------------------------------------------------------
						----------create meter partition function-------------------------------------------
						------------------------------------------------------------------------------ 
						SET @sqlCommand = 'CREATE PARTITION FUNCTION ' + @meter_partition_function_name 
						+ ' (int) AS RANGE LEFT FOR VALUES (' + CAST(@meter_partition_id AS NVARCHAR(20)) + ')'	
						EXEC (@sqlCommand)

						------------------------------------------------------------------------------
						----------create meter partition scheme-------------------------------------------
						------------------------------------------------------------------------------ 
						SET @sqlCommand = 'CREATE PARTITION SCHEME ' + @meter_partition_schema_name
						+ ' AS PARTITION ' + @meter_partition_function_name
						+ ' TO (' + @meter_partition_filegroup_name + ',' + @meter_partition_filegroup_name + ')'	
						EXEC (@sqlCommand)	
						
						------------------------------------------------------------------------------
						----------Insert data to t_archive_queue_partition table----------------------
						--------(requires for archive_queue_partition SP execution)-------------------					
						DECLARE @next_allow_run        DATETIME,
						        @current_id_partition  INT,
								@count_t_archive_queue_partition  INT
						
						SELECT @count_t_archive_queue_partition = COUNT(taqp.current_id_partition)
						FROM   t_archive_queue_partition taqp
						
						IF (@count_t_archive_queue_partition > 0)
							RAISERROR ('t_archive_queue_partition table is not empty', 16, 1)
						
						SET @current_id_partition = 1
						EXEC prtn_GetNextAllowRunDate @current_datetime = @current_dt,
						     @next_allow_run_date = @next_allow_run OUT
						
						INSERT INTO t_archive_queue_partition
						VALUES
						  (
						    @current_id_partition,
						    @current_dt,
						    @next_allow_run
						  )
					END				
				END TRY
				BEGIN CATCH
					DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT		
					SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()		
					RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
				END CATCH
                