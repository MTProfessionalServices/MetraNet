IF OBJECT_ID('archive_queue_partition_update_def_id_partition') IS NOT NULL 
	DROP PROCEDURE archive_queue_partition_update_def_id_partition
GO

CREATE PROCEDURE archive_queue_partition_update_def_id_partition(
    @new_def_id_partition        INT,
    @meter_table_name            NVARCHAR(100),
    @meter_partition_field_name  NVARCHAR(50)
)
AS
	SET NOCOUNT ON
	
	DECLARE @defaultConstraint_name  NVARCHAR(100),
	        @sqlCommand              NVARCHAR(MAX)
	
	SELECT @defaultConstraint_name = cnstr.name
	FROM   sys.all_columns allclmns
	       INNER JOIN sys.tables tbls
	            ON  allclmns.object_id = tbls.object_id
	       INNER JOIN sys.default_constraints cnstr
	            ON  allclmns.default_object_id = cnstr.object_id
	WHERE  tbls.name = @meter_table_name
	       AND allclmns.name = @meter_partition_field_name
	
	IF @defaultConstraint_name IS NOT NULL
	BEGIN
	    SET @sqlCommand = 'ALTER TABLE ' + @meter_table_name + ' DROP CONSTRAINT ' + @defaultConstraint_name
	    EXEC (@sqlCommand)
	END
	
    SET @sqlCommand = 'ALTER TABLE ' + @meter_table_name
        + ' ADD CONSTRAINT DF_' + @meter_table_name + '_' + @meter_partition_field_name 
        + ' DEFAULT ' + CAST(@new_def_id_partition AS NVARCHAR(20))
        + ' FOR ' + @meter_partition_field_name
    EXEC (@sqlCommand)
