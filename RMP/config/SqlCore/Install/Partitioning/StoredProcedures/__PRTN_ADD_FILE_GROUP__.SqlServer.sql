
                CREATE PROCEDURE prtn_AddFileGroup				        
				@partition_name NVARCHAR(100)
				AS
				BEGIN TRY
					DECLARE @sql_cmd VARCHAR(max),
							@sql_file_size VARCHAR(50) = '',		
							@data_size INT,        
							@path VARCHAR(150)				

					IF @partition_name IS NULL OR @partition_name = ''
						RAISERROR('Partition name wasn''t set',16,1)

					IF NOT EXISTS (SELECT * FROM sys.filegroups f
								   WHERE f.name = @partition_name)
					BEGIN
						SELECT  @data_size = partition_data_size      			 
						FROM t_usage_server		
						
						IF @data_size IS NOT NULL
						BEGIN
							SET @sql_file_size = 'SIZE = ' + CAST(@data_size as nvarchar(10)) + 'MB'
						END	
						
						EXEC GetNextStoragePath	@path = @path OUTPUT
						 
						SET @path = RTRIM(@path)						
						
						SET @sql_cmd = 'ALTER DATABASE ' + DB_NAME() + ' ADD FILEGROUP ' + @partition_name + ';' +						
										'ALTER DATABASE ' + DB_NAME() + ' ADD FILE (NAME = ' + @partition_name + ', ' +
										'FILENAME = ''' + @path + '\' + @partition_name + '.ndf'', ' + 
										@sql_file_size + ') TO FILEGROUP ' + @partition_name   
											
						EXEC (@sql_cmd)
					END
				END TRY
				BEGIN CATCH
					IF EXISTS (SELECT * FROM sys.filegroups f
					   WHERE f.name = @partition_name)
					BEGIN
						SET @sql_cmd = 'ALTER DATABASE ' + DB_NAME() + ' REMOVE FILEGROUP ' + @partition_name
						EXEC (@sql_cmd)
					END
					DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT		
					SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()	
					IF (ERROR_NUMBER() = 5009)
						SET @ErrorMessage = 'Folder ' + @path + ' does not exist. Please create it manually'					
						
					RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
				END CATCH
                