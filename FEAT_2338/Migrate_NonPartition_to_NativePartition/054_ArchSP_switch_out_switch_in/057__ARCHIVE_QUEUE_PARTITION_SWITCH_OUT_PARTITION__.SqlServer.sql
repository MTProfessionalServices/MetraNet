IF OBJECT_ID('archive_queue_partition_switch_out_partition') IS NOT NULL 
	DROP PROCEDURE archive_queue_partition_switch_out_partition
GO

CREATE PROCEDURE archive_queue_partition_switch_out_partition(
    @table_name                NVARCHAR(100),
    @temp_table_postfix        NVARCHAR(50),
    @number_of_partition       INT,
    @partition_filegroup_name  NVARCHAR(50)
)
AS
	SET NOCOUNT ON
	
	DECLARE @temp_table_name  NVARCHAR(100),
	        @sqlCommand       NVARCHAR(MAX)
	
	SET @temp_table_name = @table_name + @temp_table_postfix
	
	EXEC archive_queue_partition_clone_table 
		 @source_table = @table_name,
		 @destination_table = @temp_table_name,
		 @file_group = @partition_filegroup_name

	SET @sqlCommand = 'ALTER TABLE ' + @table_name
	    + ' SWITCH PARTITION $PARTITION.MeterPartitionFunction('
		+ CAST(@number_of_partition AS VARCHAR(20)) + ') TO ' + @temp_table_name
	EXEC (@sqlCommand)
