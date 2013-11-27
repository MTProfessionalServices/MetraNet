
				CREATE PROCEDURE DeployPartitionedTable
					@table_name VARCHAR(32)
				AS
				BEGIN
					DECLARE @pk_name_common			VARCHAR(100),
							@found_partition_scheme		VARCHAR(100),
							@usage_partition_scheme	VARCHAR(100),
							@error_message			VARCHAR(300),
							@sql_command  NVARCHAR(max)

					BEGIN TRY
						SET @pk_name_common = 'id_sess'
						SET @usage_partition_scheme = dbo.prtn_GetUsagePartitionSchemaName()
						
						IF dbo.IsSystemPartitioned() = 0
							RAISERROR('Partitioning not enabled', 16, 1)
						
						IF @table_name IS NULL
						   OR @table_name = ''
							RAISERROR ('Table name wasn''t specified', 16, 1)
						
						IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_name)
						BEGIN
							SET @error_message = 'Table "' + @table_name + '" does not exist'
							RAISERROR (@error_message, 16, 1)
						END
							
						IF NOT EXISTS(SELECT * FROM sys.partition_schemes ps WHERE ps.name = @usage_partition_scheme)
						BEGIN
							SET @error_message = '"' + @usage_partition_scheme +
								'" schema was not created. Partitioning cannot be applied for table "' + @table_name + '".'	    
							RAISERROR (@error_message, 16, 1)
						END
						
						IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @table_name AND COLUMN_NAME = N'id_usage_interval')
						BEGIN
							SET @error_message = 'Table "' + @table_name
							+ '" does not contain a partition column "id_usage_interval". This field is required for partitioning.'	    
							RAISERROR (@error_message, 16, 1)
						END
						
						IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @table_name AND COLUMN_NAME = @pk_name_common)
						BEGIN
							SET @error_message = 'Table "' + @table_name
							+ '" suggests to have PK column name - "' + @pk_name_common + '". This field is required for partitioning.'	    
							RAISERROR (@error_message, 16, 1)
						END
								
						SELECT DISTINCT @found_partition_scheme = ps.name
						FROM   sys.partitions p
							   JOIN sys.objects o
									ON  o.object_id = p.object_id
							   JOIN sys.indexes i
									ON  p.object_id = i.object_id
									AND p.index_id = i.index_id
							   JOIN sys.data_spaces ds
									ON  i.data_space_id = ds.data_space_id
							   JOIN sys.partition_schemes ps
									ON  ds.data_space_id = ps.data_space_id
							   JOIN sys.partition_functions pf
									ON  ps.function_id = pf.function_id
						WHERE  o.name = @table_name
						
						BEGIN TRANSACTION
						
						IF @found_partition_scheme IS NULL
						BEGIN
							DECLARE @pk_name NVARCHAR(50)
							SELECT @pk_name = CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'PRIMARY KEY' AND TABLE_NAME = @table_name
							
							IF @pk_name IS NOT NULL
							BEGIN
								SET @sql_command = 'ALTER TABLE ' + @table_name + ' DROP CONSTRAINT ' + @pk_name
								EXEC(@sql_command)
							END
							
							SET @sql_command = 'ALTER TABLE ' + @table_name + ' ADD CONSTRAINT pk_' + @table_name
											 + ' PRIMARY KEY CLUSTERED(id_sess ASC, id_usage_interval ASC)
												WITH (
													 PAD_INDEX = OFF,
													 STATISTICS_NORECOMPUTE = OFF,
													 IGNORE_DUP_KEY = OFF,
													 ALLOW_ROW_LOCKS = ON,
													 ALLOW_PAGE_LOCKS = ON
												 ) ON ' + @usage_partition_scheme + '(id_usage_interval)'
							EXEC(@sql_command)
							
							/*
							* Cannot use DropUniqueConstraints for t_acc_usage, cause of missmach in constraint names.
							* Stored in t_unique_cons name:	"uk_acc_usage_tx_uid"
							* Real name: "C_t_acc_usage"
							*/
							IF @table_name = 't_acc_usage'
								ALTER TABLE t_acc_usage DROP CONSTRAINT C_t_acc_usage								
							ELSE							
								EXEC DropUniqueConstraints @table_name
							
							EXEC RecreateIndexes @table_name
						END
						ELSE
						BEGIN
							IF @found_partition_scheme <> @usage_partition_scheme
							BEGIN
								SET @error_message = 'Table "' + @table_name
									+ '" already under "' + @found_partition_scheme
									+ '". Could not apply for "' + @usage_partition_scheme + '"'	        
								RAISERROR (@error_message, 16, 1)
							END
						END
						
						declare @ret int
						EXEC @ret = CreateUniqueKeyTables @table_name
						IF (@ret <> 0)
						    RAISERROR('Cannot create unique keys for table [%s]', 16, 1, @table_name)

						COMMIT
					END TRY
					BEGIN CATCH
						DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT		
						SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()		
						RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
						ROLLBACK
					END CATCH
				END
			