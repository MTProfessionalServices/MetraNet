
                CREATE PROCEDURE prtn_create_meter_partitions
				AS
				DECLARE @meter_partition_function_name NVARCHAR(50),
						@meter_partition_schema_name NVARCHAR(50),
						@meter_partition_filegroup_name NVARCHAR(50),
						@meter_partition_id INT,
						@sqlCommand NVARCHAR(MAX)
											
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
								EXEC prtn_add_file_group @meter_partition_filegroup_name

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
				
						DECLARE @count_t_archive_queue_partition  INT
						
						SELECT @count_t_archive_queue_partition = COUNT(taqp.current_id_partition)
						FROM   t_archive_queue_partition taqp
						
						IF (@count_t_archive_queue_partition = 0)
							RAISERROR ('t_archive_queue_partition table must have at least one initial record', 16, 1)
						
					END				
				END TRY
				BEGIN CATCH
					DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT		
					SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()		
					RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
				END CATCH
                