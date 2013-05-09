IF OBJECT_ID('archive_queue_partition_switch_out_with_keep_sess') IS NOT NULL 
	DROP PROCEDURE archive_queue_partition_switch_out_with_keep_sess
GO

CREATE PROCEDURE archive_queue_partition_switch_out_with_keep_sess(
    @number_of_partition       INT,
    @table_name  NVARCHAR(100),
    @temp_table_postfix_oldest  NVARCHAR(50),
    @temp_table_postfix_preserved  NVARCHAR(50),
    @partition_filegroup_name  NVARCHAR(50)
)
AS
	SET NOCOUNT ON
	
	DECLARE @table_with_sess_to_keep NVARCHAR(100),
			@preserved_partition INT,
			@sqlCommand NVARCHAR(MAX)
	
	SET @table_with_sess_to_keep = @table_name + '_sess_to_keep'
	SET @preserved_partition = @number_of_partition - 1
		
	SET @sqlCommand = 'IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N''dbo'' AND TABLE_NAME = ''' + @table_with_sess_to_keep + ''')) 
							DROP TABLE ' + @table_with_sess_to_keep
	EXEC (@sqlCommand)
		
	SET @sqlCommand = 'SELECT * INTO ' + @table_with_sess_to_keep
					+ ' FROM ' + @table_name + '
						WHERE  id_source_sess IN (SELECT id_sess
													FROM   ##id_sess_to_keep)
							AND id_partition = ' + CAST(@preserved_partition AS VARCHAR(20))
	EXEC (@sqlCommand)
	
	SET @sqlCommand = 'UPDATE ' + @table_with_sess_to_keep + ' SET id_partition = ' + CAST(@number_of_partition AS VARCHAR(20))
	EXEC (@sqlCommand)
	
	SET @sqlCommand = 'INSERT INTO ' + @table_with_sess_to_keep
					+ ' SELECT * FROM ' + @table_name + '
						WHERE  id_source_sess IN (SELECT id_sess
													FROM   ##id_sess_to_keep)
							AND id_partition = ' + CAST(@number_of_partition AS VARCHAR(20))
	EXEC (@sqlCommand)
	
	EXEC archive_queue_partition_clone_all_indexes_and_constraints
	     @SourceSchema = N'dbo',
	     @SourceTable = @table_name,
	     @DestinationSchema = N'dbo',
	     @DestinationTable = @table_with_sess_to_keep,
	     @FileGroup = @partition_filegroup_name
	
	
	SET @sqlCommand = 'ALTER TABLE ' + @table_with_sess_to_keep
					+ ' WITH CHECK ADD CONSTRAINT CK_' + @table_with_sess_to_keep
					+ ' CHECK((id_partition = ('
					+ CAST(@number_of_partition AS VARCHAR(20)) + ')))'
	EXEC (@sqlCommand)
	
	SET @sqlCommand = 'ALTER TABLE ' + @table_with_sess_to_keep + ' CHECK CONSTRAINT CK_' + @table_with_sess_to_keep
	EXEC (@sqlCommand)
	
	BEGIN TRAN
	
	/* SWITCH OUT 'old' partition */
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = @table_name,
	     @temp_table_postfix = @temp_table_postfix_oldest,
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	/* SWITCH OUT 'preserved' partition */
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = @table_name,
	     @temp_table_postfix = @temp_table_postfix_preserved,
	     @number_of_partition = @preserved_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	/* SWITCH IN new 'preserved' partition with sessions to keep */
	SET @sqlCommand = 'ALTER TABLE ' + @table_with_sess_to_keep
					+ ' SWITCH TO ' + @table_name
					+ ' PARTITION $PARTITION.MeterPartitionFunction('
					+ CAST(@number_of_partition AS VARCHAR(20)) + ')'
	EXEC (@sqlCommand)
	
	COMMIT TRAN
	
	SET @sqlCommand = 'DROP TABLE ' + @table_with_sess_to_keep
	EXEC (@sqlCommand)
