IF OBJECT_ID('archive_queue_partition_clone_table') IS NOT NULL 
	DROP PROCEDURE archive_queue_partition_clone_table
GO

CREATE PROCEDURE archive_queue_partition_clone_table(
    @source_table       NVARCHAR(255),
    @destination_table  NVARCHAR(255),
    @file_group         NVARCHAR(255)
)
AS
	SET NOCOUNT ON	
	
	DECLARE @source_schema  NVARCHAR(255),
	        @pk_schema      NVARCHAR(255),
	        @pk_name        NVARCHAR(255),
	        @pk_columns     NVARCHAR(MAX)
	
	SET @source_schema = N'dbo'
	SET @pk_columns = ''
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = @source_schema
	              AND TABLE_NAME = @destination_table
	   )
	    EXEC ('DROP TABLE ' + @destination_table)
	
	-- Clone table
	/* Possible fix for
	* CORE-6477:"archive_queue_partition will fail, if any t_svc_* table in will have large value columns" */
	
	--EXEC ('ALTER DATABASE NetMeter MODIFY FILEGROUP MeterFileGroup DEFAULT')
	
	EXEC ('SELECT TOP (0) * INTO ' + @destination_table + ' FROM ' + @source_table)
	
	--ALTER DATABASE NetMeter MODIFY FILEGROUP [PRIMARY] DEFAULT
	
	SELECT TOP 1 @pk_schema = CONSTRAINT_SCHEMA,
	       @pk_name = CONSTRAINT_NAME
	FROM   INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	WHERE  TABLE_SCHEMA = @source_schema
	       AND TABLE_NAME = @source_table
	       AND CONSTRAINT_TYPE = 'PRIMARY KEY'
	
	-- Clone primary key
	IF NOT @pk_schema IS NULL
	   AND NOT @pk_name IS NULL
	BEGIN
	    SELECT @pk_columns = @pk_columns + '[' + COLUMN_NAME + '],'
	    FROM   INFORMATION_SCHEMA.KEY_COLUMN_USAGE
	    WHERE  TABLE_NAME = @source_table
	           AND TABLE_SCHEMA = @source_schema
	           AND CONSTRAINT_SCHEMA = @pk_schema
	           AND CONSTRAINT_NAME = @pk_name
	    ORDER BY
	           ORDINAL_POSITION
	    
	    SET @pk_columns = LEFT(@pk_columns, LEN(@pk_columns) - 1)
	    
	    EXEC (
	             'ALTER TABLE ' + @destination_table
	             + ' ADD CONSTRAINT PK_' + @destination_table 
	             + ' PRIMARY KEY CLUSTERED (' + @pk_columns + ') ON ' + @file_group
	         )
	END
