
                CREATE PROCEDURE prtn_alter_partition_schema
				@interval_id_end INT,
				@interval_dt_end DATETIME,
				@partition_name NVARCHAR(100) OUTPUT
				AS
				BEGIN TRY
				IF @interval_id_end IS NULL
				RAISERROR ('End interval ID of partition wasn''t specified', 16, 1)
				IF @interval_dt_end IS NULL OR @interval_dt_end = ''
				RAISERROR ('End date of partition wasn''t specified', 16, 1)

				DECLARE @partition_schema_name    NVARCHAR(50),
				@partition_function_name  NVARCHAR(50),
				@partition_function_id    INT,
				@sqlCommand               NVARCHAR(MAX)

				SET @partition_name = DB_NAME() + '_' + CONVERT(VARCHAR, @interval_dt_end, 102)
				SET @partition_name = REPLACE(@partition_name, '.', '')                	
				SET @partition_schema_name = dbo.prtn_GetUsagePartitionSchemaName()
				SET @partition_function_name = dbo.Prtn_GetUsagePartitionFunctionName()
				SELECT @partition_function_id = function_id FROM sys.partition_functions WHERE name = @partition_function_name

				IF NOT EXISTS (SELECT * FROM sys.partition_range_values rv
				WHERE  rv.function_id = @partition_function_id
				AND rv.value = @interval_dt_end)
				BEGIN
				EXEC prtn_add_file_group @partition_name

				SET @sqlCommand = 'ALTER PARTITION SCHEME ' + @partition_schema_name
							+ ' NEXT USED ' + @partition_name	    
				EXEC (@sqlCommand)

				SET @sqlCommand = 'ALTER PARTITION FUNCTION ' + @partition_function_name + 
				'() SPLIT RANGE (' + CAST(@interval_id_end AS NVARCHAR(20)) + ')'	    
				EXEC (@sqlCommand)
				END
				END TRY
				BEGIN CATCH					
				DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT		
				SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()		
				RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
				END CATCH
                