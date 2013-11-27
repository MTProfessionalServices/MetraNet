IF OBJECT_ID('archive_queue_partition_switch_out_partition_all') IS NOT NULL 
	DROP PROCEDURE archive_queue_partition_switch_out_partition_all
GO

CREATE PROCEDURE archive_queue_partition_switch_out_partition_all(
    @number_of_partition       INT,
    @partition_filegroup_name  NVARCHAR(50)
)
AS
	SET NOCOUNT ON
	
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session',
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session_state',
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session_set',
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	/* Using this temp table will have TEXTIMAGE_ON [PRIMARY]
	* this is caused by [tx_sc_serialized] [text] field.
	* It stores data in PRIMARY fileGroup...
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_message',
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	*/
	
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N't_message_temp_switch_partition_table')
    	DROP TABLE t_message_temp_switch_partition_table
	
	CREATE TABLE t_message_temp_switch_partition_table
	(
		id_message        INT NOT NULL,
		id_route          INT NULL,
		dt_crt            DATETIME NOT NULL,
		dt_metered        DATETIME NOT NULL,
		dt_assigned       DATETIME NULL,
		id_listener       INT NULL,
		id_pipeline       INT NULL,
		dt_completed      DATETIME NULL,
		id_feedback       INT NULL,
		tx_TransactionID  VARCHAR(256) NULL,
		tx_sc_username    VARCHAR(510) NULL,
		tx_sc_password    VARCHAR(128) NULL,
		tx_sc_namespace   VARCHAR(80) NULL,
		tx_sc_serialized  TEXT NULL,
		tx_ip_address     VARCHAR(15) NOT NULL,
		id_partition      INT NOT NULL,
		CONSTRAINT pk_t_message_temp_switch_partition_table PRIMARY KEY CLUSTERED(id_message ASC, id_partition ASC) 
		ON MeterFileGroup
	) ON MeterFileGroup

	DECLARE @sqlCommand VARCHAR(8000)
	SET @sqlCommand = 'ALTER TABLE t_message SWITCH PARTITION '+ CAST(@number_of_partition AS VARCHAR(20)) 
	    	    	+ ' TO t_message_temp_switch_partition_table'
	EXEC (@sqlCommand)

	DECLARE @tab_name NVARCHAR(100)
	DECLARE svc_cursor CURSOR FAST_FORWARD 
	FOR
	    SELECT nm_table_name
	    FROM   t_service_def_log
	
	OPEN svc_cursor 
	FETCH NEXT FROM svc_cursor INTO @tab_name
	
	WHILE (@@fetch_status = 0)
	BEGIN
	    EXEC archive_queue_partition_switch_out_partition
	         @table_name = @tab_name,
	         @number_of_partition = @number_of_partition,
	         @partition_filegroup_name = @partition_filegroup_name
	    
	    FETCH NEXT FROM svc_cursor INTO @tab_name
	END 
	CLOSE svc_cursor 
	DEALLOCATE svc_cursor  
