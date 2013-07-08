IF OBJECT_ID('RecreateIndexes') IS NOT NULL 
DROP PROCEDURE RecreateIndexes
GO
			CREATE PROCEDURE RecreateIndexes
				@table_name VARCHAR(128)
			AS

			DECLARE	@column_name NVARCHAR(128),
					@index_name NVARCHAR(128),
					@sql VARCHAR(MAX)		

			BEGIN TRY

				PRINT ('Recreating indexes to apply partition schema on them.');

				SET @sql = '
					DECLARE index_name CURSOR  
					FOR
						SELECT DISTINCT i.name
						FROM   sys.indexes i
							   INNER JOIN sys.objects o
									ON  o.object_id = i.object_id
							   INNER JOIN sys.stats s
									ON  i.object_id = s.object_id
						WHERE  i.object_id IN (SELECT OBJECT_ID
											   FROM  sys.objects
											   WHERE  NAME = ''' + @table_name + ''')
							   AND i.is_hypothetical <> 1
							   AND i.type_desc <> ''CLUSTERED''
							   AND s.auto_created = 0
							   AND o.type = (''U'')
							   AND i.name NOT IN (SELECT constraint_name
												  FROM   information_schema.table_constraints
												  WHERE  table_name = ''' + @table_name + ''')
				'
				EXEC (@sql)

				OPEN index_name
				FETCH NEXT FROM index_name INTO @index_name
				WHILE (@@fetch_status = 0)
				BEGIN
					SET @sql = '
					DECLARE column_name CURSOR  
					FOR
						SELECT DISTINCT c.name
						FROM sys.objects o
							   INNER JOIN sys.indexes i
									ON  o.object_id = i.object_id
							   INNER JOIN sys.index_columns ic
									ON  i.object_id = ic.object_id
									AND i.index_id = ic.index_id
							   INNER JOIN sys.columns c
									ON  ic.object_id = c.object_id
									AND ic.column_id = c.column_id
							   INNER JOIN sys.stats s
									ON  i.object_id = s.object_id
						WHERE  o.type = ''U''
							   AND o.name = ''' + @table_name + '''
							   AND i.is_hypothetical <> 1
							   AND i.type_desc <> ''CLUSTERED''
							   AND s.auto_created = 0
							   AND i.name = ''' + @index_name + '''
						ORDER BY
							   c.name
					'
					EXEC (@sql)
									
					DECLARE @columns  NVARCHAR(MAX)
					SET @columns = ''
					OPEN column_name
					FETCH NEXT FROM column_name INTO @column_name
					WHILE (@@fetch_status = 0)
					BEGIN
						IF (@columns <> '')
							SET @columns = @columns + ','
						
						SET @columns = @columns + @column_name
						FETCH NEXT FROM column_name INTO @column_name
					END
					CLOSE column_name
					DEALLOCATE column_name

					SET @sql = 'DROP INDEX ' + @index_name + ' ON ' + @table_name
					EXEC (@sql)

					SET @sql = 'CREATE INDEX ' + @index_name + ' ON ' + @table_name + '(' + @columns + ')'
					EXEC (@sql)
					
					PRINT ('Index "' + @index_name + '" was recreated for table: "'+ @table_name + '". On columns:' + @columns + '.');
					
					SET @columns = ''
					FETCH NEXT FROM index_name INTO @index_name
				END
				CLOSE index_name
				DEALLOCATE index_name

			END TRY
			BEGIN CATCH
				DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT	
				SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
				RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
			END CATCH
			