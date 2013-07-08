IF OBJECT_ID('archive_queue_partition_apply_next_partition') IS NOT NULL 
	DROP PROCEDURE archive_queue_partition_apply_next_partition
GO

CREATE PROCEDURE archive_queue_partition_apply_next_partition
	@new_current_id_partition INT,
	@current_time DATETIME,
	@meter_partition_function_name NVARCHAR(50),
	@meter_partition_schema_name NVARCHAR(50),
	@meter_partition_filegroup_name NVARCHAR(50),
	@meter_partition_field_name NVARCHAR(50)
AS
	SET NOCOUNT ON
	
	DECLARE @sqlCommand NVARCHAR(MAX)
	
	BEGIN TRAN
	
	SET @sqlCommand = 'ALTER PARTITION SCHEME ' + @meter_partition_schema_name
	    + ' NEXT USED ' + @meter_partition_filegroup_name
	EXEC (@sqlCommand)
	
	/* Adding new partition to MeterPartitionSchema*/
	SET @sqlCommand = 'ALTER PARTITION FUNCTION ' + @meter_partition_function_name 
	    + '() SPLIT RANGE (' + CAST(@new_current_id_partition AS NVARCHAR(20)) + ')'
	EXEC (@sqlCommand)
	
	/* Call for update default id_partition (@new_current_id_partition) for all meter tables*/
	EXEC archive_queue_partition_update_def_id_partition_all
	     @new_def_id_partition = @new_current_id_partition,
	     @meter_partition_field_name = @meter_partition_field_name
	
	/* Update Default id_partition in [t_archive_queue_partition] table */
	INSERT INTO t_archive_queue_partition
	VALUES
	  (
	    @new_current_id_partition,
	    @current_time,
	    NULL
	  )
	
	COMMIT TRAN

