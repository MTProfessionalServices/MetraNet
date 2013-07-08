IF OBJECT_ID('DropUniqueConstraints') IS NOT NULL 
DROP PROCEDURE DropUniqueConstraints
GO
			
			CREATE PROCEDURE DropUniqueConstraints
				@table_name VARCHAR(128)
			AS

			DECLARE	@constraint_name NVARCHAR(400),
					@sql VARCHAR(MAX)	

			BEGIN TRY

				PRINT ('Dropping all unique constraints from partitioned table.');

				DECLARE unique_constraint_name CURSOR  
				FOR
					SELECT constraint_name
					FROM   t_unique_cons
						   JOIN t_prod_view tpv
								ON  tpv.id_prod_view = t_unique_cons.id_prod_view
					WHERE  tpv.nm_table_name = @table_name

				OPEN unique_constraint_name
				FETCH NEXT FROM unique_constraint_name INTO @constraint_name
				WHILE (@@fetch_status = 0)
				BEGIN
					SET @sql = 'ALTER TABLE ' + @table_name + ' DROP CONSTRAINT ' + @constraint_name
					EXEC (@sql)
					
					FETCH NEXT FROM unique_constraint_name INTO @constraint_name
				END
				CLOSE unique_constraint_name
				DEALLOCATE unique_constraint_name

			END TRY
			BEGIN CATCH
				DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT	
				SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
				RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
			END CATCH
			
			