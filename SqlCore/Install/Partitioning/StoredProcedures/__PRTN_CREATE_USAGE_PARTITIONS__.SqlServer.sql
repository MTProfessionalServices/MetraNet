
				CREATE PROCEDURE prtn_create_usage_partitions
				AS
				BEGIN TRY
				IF dbo.IsSystemPartitioned() = 0
					RAISERROR('System not enabled for partitioning.', 16, 1)

				/* Vars for iterating through the new partition list
				*/
				DECLARE @cur CURSOR  
				DECLARE @dt_start DATETIME
				DECLARE @dt_end DATETIME
				DECLARE @id_interval_start INT
				DECLARE @id_interval_end INT
				DECLARE @parts TABLE (
							partition_name NVARCHAR(100),
							dt_start DATETIME,
							dt_end DATETIME,
							interval_start INT,
							interval_end INT
						)
									
				EXEC GeneratePartitionSequence @cur OUT

				/* Get first row of partition info*/
				FETCH @cur INTO	@dt_start, @dt_end, @id_interval_start, @id_interval_end

				/* pause pipeline to reduce contention */
				IF (@@FETCH_STATUS = 0) EXEC PausePipelineProcessing 1

				/* Iterate through partition sequence */
				WHILE (@@fetch_status = 0)
				BEGIN
					DECLARE @partition_name NVARCHAR(100)
					
					IF NOT EXISTS (SELECT * FROM sys.partition_schemes WHERE name = dbo.prtn_GetUsagePartitionSchemaName())
					BEGIN
						EXEC prtn_create_partition_schema @id_interval_end, @dt_end, @partition_name OUT
						
						-- insert information about default partition						
						INSERT INTO t_partition
						(partition_name, b_default, dt_start, dt_end, id_interval_start, id_interval_end, b_active)
						VALUES
						(dbo.prtn_GetDefaultPartitionName(), 'Y', DATEADD(DAY, 1, @dt_end), dbo.MTMaxdate(), @id_interval_end + 1, 2147483647, 'N')
						
						INSERT INTO @parts
						VALUES
						(dbo.prtn_GetDefaultPartitionName(), DATEADD(DAY, 1, @dt_end), dbo.MTMaxdate(), @id_interval_end + 1, 2147483647)
					END
					ELSE
					BEGIN
						EXEC prtn_alter_partition_schema @id_interval_end, @dt_end, @partition_name OUT
						
						-- update start of default partition
						UPDATE t_partition
						SET
							dt_start = DATEADD(DAY, 1, @dt_end),			
							id_interval_start = @id_interval_end + 1
						WHERE  b_default = 'Y'
					END
					
					-- insert information about created partition			
					INSERT INTO t_partition
						(partition_name, b_default, dt_start, dt_end, id_interval_start, id_interval_end, b_active)
						VALUES
						(@partition_name, 'N', @dt_start, @dt_end, @id_interval_start, @id_interval_end, 'Y')
						
					INSERT INTO @parts
						VALUES
						(@partition_name, @dt_start, @dt_end, @id_interval_start, @id_interval_end)
					
					/* Get next patition info */
					FETCH @cur INTO @dt_start, @dt_end, @id_interval_start, @id_interval_end 
				END

				/* Deallocate the cursor */
				CLOSE @cur
				DEALLOCATE @cur

				/* unpause pipeline */
				EXEC PausePipelineProcessing 0

				/* Correct default partition start if it was just created */
				UPDATE @parts
				SET							
					dt_start = DATEADD(DAY, 1, @dt_end),							
					interval_start = @id_interval_end + 1
				WHERE dt_end = dbo.MTMaxdate() 
				
				/* Returning partition info*/
				SELECT * FROM @parts ORDER BY dt_start
				
				END TRY
				BEGIN CATCH
				
				 /* unpause pipeline in any error   CORE-7640  */  
					EXEC PausePipelineProcessing 0 
				
					DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT	
					SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
					EXEC PausePipelineProcessing 0
					RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
				END CATCH
			