CREATE PROCEDURE prtn_deploy_table
	@partition_table_name	VARCHAR(200),
	@pk_columns				VARCHAR(200),
	@partition_schema		VARCHAR(100),
	@partition_column		VARCHAR(32),
	@apply_uk_tables		BIT = 0
AS
BEGIN
	DECLARE @found_partition_schema  VARCHAR(100),
	        @error_message           VARCHAR(300),
	        @sql_command             VARCHAR(MAX)
	BEGIN TRY

		IF dbo.IsSystemPartitioned() = 0
			RAISERROR('Partitioning not enabled', 16, 1)
		
		IF @partition_table_name IS NULL
		   OR @partition_table_name = ''
			RAISERROR ('Table name wasn''t specified', 16, 1)
		
		IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @partition_table_name)
		BEGIN
			SET @error_message = 'Table "' + @partition_table_name + '" does not exist'
			RAISERROR (@error_message, 16, 1)
		END
			
		IF NOT EXISTS(SELECT * FROM sys.partition_schemes ps WHERE ps.name = @partition_schema)
		BEGIN
			SET @error_message = '"' + @partition_schema +
				'" schema was not created. Partitioning cannot be applied for table "' + @partition_table_name + '".'	    
			RAISERROR (@error_message, 16, 1)
		END
		
		IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @partition_table_name AND COLUMN_NAME = @partition_column)
		BEGIN
			SET @error_message = 'Table "' + @partition_table_name
			+ '" does not contain a partition column "'+ @partition_column + '". This field is required for partitioning.'	    
			RAISERROR (@error_message, 16, 1)
		END
		
		IF OBJECT_ID('RecreateIndexes') IS NULL
		BEGIN
			SET @error_message = 'Stored procedure "RecreateIndexes" does not exist in database'	    
			RAISERROR (@error_message, 16, 1)
		END
		
		SELECT DISTINCT @found_partition_schema = ps.name
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
		WHERE  o.name = @partition_table_name
		
		BEGIN TRANSACTION
		
		IF @found_partition_schema IS NULL
		BEGIN
			DECLARE @pk_name NVARCHAR(50)
			SELECT @pk_name = CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE = 'PRIMARY KEY' AND TABLE_NAME = @partition_table_name
			
			IF @pk_name IS NOT NULL
			BEGIN
				SET @sql_command = 'ALTER TABLE ' + @partition_table_name + ' DROP CONSTRAINT ' + @pk_name
				EXEC(@sql_command)
			END
			
			SET @sql_command = 'ALTER TABLE ' + @partition_table_name + ' ADD CONSTRAINT pk_' + @partition_table_name
							 + ' PRIMARY KEY CLUSTERED( '+ @pk_columns +' )
								WITH (
									 PAD_INDEX = OFF,
									 STATISTICS_NORECOMPUTE = OFF,
									 IGNORE_DUP_KEY = OFF,
									 ALLOW_ROW_LOCKS = ON,
									 ALLOW_PAGE_LOCKS = ON
								 ) ON ' + @partition_schema + '('+ @partition_column +')'
			EXEC(@sql_command)
			
			/* For now only Usage tables supports Non-Clustered Unique Constraints.
			't_uk_*' table is created for each Non-Clustered Unique constraint. */
			IF @apply_uk_tables = 1
			BEGIN
				/*
				* Cannot use DropUniqueConstraints for t_acc_usage, cause of missmach in constraint names.
				* Stored in t_unique_cons name:	"uk_acc_usage_tx_uid"
				* Real name: "C_t_acc_usage"
				*/
				IF @partition_table_name = 't_acc_usage'
					ALTER TABLE t_acc_usage DROP CONSTRAINT C_t_acc_usage
				ELSE
					EXEC DropUniqueConstraints @partition_table_name
			END
			
			EXEC RecreateIndexes @partition_table_name
			
		END
		ELSE
		BEGIN
			IF @found_partition_schema <> @partition_schema
			BEGIN
				SET @error_message = 'Table "' + @partition_table_name
					+ '" already under "' + @found_partition_schema
					+ '". Could not apply for "' + @partition_schema + '"'
				RAISERROR (@error_message, 16, 1)
			END
		END
		
		/* Now - for Usage tables only */
		IF @apply_uk_tables = 1
		BEGIN
			DECLARE @ret INT
			EXEC @ret = CreateUniqueKeyTables @partition_table_name
			IF (@ret <> 0)
				RAISERROR('Cannot create unique keys for table [%s]',16,1,@partition_table_name)
		END
		
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT
		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
		ROLLBACK
	END CATCH
END
