IF OBJECT_ID('prtn_CreatePartitionSchema') IS NOT NULL 
DROP PROCEDURE prtn_CreatePartitionSchema
GO
                CREATE PROCEDURE prtn_CreatePartitionSchema
					@interval_id_end INT,
                	@dt_end DATETIME,
                	@partition_name NVARCHAR(100) OUTPUT
				AS
				BEGIN TRY
					IF @interval_id_end IS NULL
						RAISERROR ('End interval ID of first partition wasn''t specified', 16, 1)
					IF @dt_end IS NULL OR @dt_end = ''
						RAISERROR ('End date of first partition wasn''t specified', 16, 1)
					
					DECLARE @default_partition_name  NVARCHAR(100),
							@partition_function_name  NVARCHAR(50),
							@partition_schema_name    NVARCHAR(50),
							@sqlCommand             NVARCHAR(MAX)
					
            	    SET @partition_name = DB_NAME() + '_' + CONVERT(VARCHAR, @dt_end, 102)
            	    SET @partition_name = REPLACE(@partition_name, '.', '')
            	    SET @default_partition_name = dbo.prtn_GetDefaultPartitionName()
					SET @partition_function_name = dbo.Prtn_GetUsagePartitionFunctionName()
					SET @partition_schema_name = dbo.prtn_GetUsagePartitionSchemaName()
					
            	    EXEC prtn_AddFileGroup @partition_name
            	    EXEC prtn_AddFileGroup @default_partition_name
            	    
					SET @sqlCommand = 'CREATE PARTITION FUNCTION ' + @partition_function_name 
						+ ' (int) AS RANGE LEFT FOR VALUES (' + CAST(@interval_id_end AS NVARCHAR(20)) + ')'		
					EXEC (@sqlCommand)
					
					SET @sqlCommand = 'CREATE PARTITION SCHEME ' + @partition_schema_name
						+ ' AS PARTITION ' + @partition_function_name
						+ ' TO  (' + @partition_name + ',' + @default_partition_name + ')'		
					EXEC (@sqlCommand)					
				END TRY
				BEGIN CATCH
					DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT		
					SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()		
					RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
				END CATCH
                