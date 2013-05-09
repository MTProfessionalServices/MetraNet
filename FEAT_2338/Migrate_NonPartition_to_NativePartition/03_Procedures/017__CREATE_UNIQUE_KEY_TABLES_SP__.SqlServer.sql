IF OBJECT_ID('CreateUniqueKeyTables') IS NOT NULL 
DROP PROCEDURE CreateUniqueKeyTables
GO
			CREATE PROCEDURE CreateUniqueKeyTables
			@tabname VARCHAR(200)
			AS
			BEGIN
				
				SET NOCOUNT ON
				
				-- Abort if system isn't enabled for partitioning
				IF dbo.IsSystemPartitioned() = 0
				BEGIN
					RAISERROR('System not enabled for partitioning.', 0, 1)
					RETURN 1
				END
				
				--
				-- Create Keys
				--
				
				-- Select all unique cons for a partitioned table
				DECLARE ukcur CURSOR  
				FOR
					SELECT uc.nm_table_name
					FROM   t_unique_cons uc
						   JOIN t_prod_view pv
								ON  uc.id_prod_view = pv.id_prod_view
					WHERE  pv.nm_table_name = @tabname
					ORDER BY
						   uc.id_unique_cons
				
				-- Iterate each uk and create
				DECLARE @cons VARCHAR(300) -- unique key constraint name
				DECLARE @ins VARCHAR(1000) -- returned insert trigger component
				DECLARE @isnew CHAR(1) -- Y if uk needs inital loading
				DECLARE @cnt INT
				DECLARE @loadlist TABLE (
							-- list of uk's to load and other info
							cons VARCHAR(300),	-- name of uk
							isnew CHAR(1),	-- if it was just created
							ins VARCHAR(500) -- insert sql fragment
							)  	
				SET @ins = ''
				SET @cnt = 0
				
				OPEN ukcur
				WHILE (1 = 1)
				BEGIN
					FETCH ukcur INTO @cons
					IF (@@fetch_status <> 0)
						BREAK
					
					SET @cnt = @cnt + 1
						   
					-- Create the uk tables
					DECLARE @ret INT
					EXEC @ret = CreateUniqueKeyTable @cons,
						 @ins OUTPUT,
						 @isnew OUTPUT
					
					IF (@ret <> 0)
					BEGIN
						RAISERROR('Unique key table [%s] not created.', 16, 1, @cons)
						RETURN 1
					END
					
					-- Collect sql fragment and other info for this uk	    
					INSERT @loadlist
					VALUES
					  (
						@cons,
						@isnew,
						@ins
					  )
				END 
				DEALLOCATE ukcur
				
				-- If the partitioned table has no constraints, just ignore it
				IF (@cnt < 1)
				BEGIN
					RAISERROR('No unique constraints found for [%s]', 0, 1, @tabname)
					RETURN --0
				END
				
				--
				-- Load Keys
				--
				DECLARE uklist CURSOR  
				FOR
					SELECT cons,
						   isnew,
						   ins
					FROM   @loadlist
				
				DECLARE @uk VARCHAR(300) 
				OPEN uklist	    
				-- Iterate unique key tables and load if new
				WHILE (1 = 1)
				BEGIN
					
					FETCH uklist INTO @uk, @isnew, @ins
					IF (@@fetch_status <> 0)
						BREAK

					-- Load uk from table if new
					IF (@isnew = 'Y')
					BEGIN
						PRINT '   Loading: ' + @uk 	            
						-- The body of the insert trigger is the loading code
						DECLARE @loadcmd VARCHAR(1000)
						SET @loadcmd = REPLACE(@ins, 'inserted', @tabname)
						EXEC (@loadcmd)
						
						DECLARE @err INT
						SELECT @err = @@error
						IF (@err <> 0)
						BEGIN
							RAISERROR(
								'Cannot load unique key [%s] from [%s]',
								16,
								1,
								@uk,
								@tabname
							)
							DEALLOCATE uklist
							RETURN 1
						END
					END
				END
				DEALLOCATE uklist
			END
			