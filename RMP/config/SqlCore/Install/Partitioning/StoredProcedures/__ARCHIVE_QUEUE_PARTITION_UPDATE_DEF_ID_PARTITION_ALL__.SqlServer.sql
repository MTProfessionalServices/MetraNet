CREATE PROCEDURE archive_queue_partition_update_def_id_partition_all(
    @new_def_id_partition        INT,
    @meter_partition_field_name  NVARCHAR(50)
)
AS
	SET NOCOUNT ON
	
	EXEC archive_queue_partition_update_def_id_partition @new_def_id_partition = @new_def_id_partition,
	     @meter_table_name = 't_session',
	     @meter_partition_field_name = @meter_partition_field_name
	
	EXEC archive_queue_partition_update_def_id_partition @new_def_id_partition = @new_def_id_partition,
	     @meter_table_name = 't_session_state',
	     @meter_partition_field_name = @meter_partition_field_name
	
	EXEC archive_queue_partition_update_def_id_partition @new_def_id_partition = @new_def_id_partition,
	     @meter_table_name = 't_session_set',
	     @meter_partition_field_name = @meter_partition_field_name
	
	EXEC archive_queue_partition_update_def_id_partition @new_def_id_partition = @new_def_id_partition,
	     @meter_table_name = 't_message',
	     @meter_partition_field_name = @meter_partition_field_name
	
	DECLARE @tab_name NVARCHAR(100)
	DECLARE svc_cursor CURSOR FAST_FORWARD 
	FOR
	    SELECT nm_table_name
	    FROM   t_service_def_log
	
	OPEN svc_cursor 
	FETCH NEXT FROM svc_cursor INTO @tab_name
	
	WHILE (@@fetch_status = 0)
	BEGIN
	    EXEC archive_queue_partition_update_def_id_partition @new_def_id_partition = @new_def_id_partition,
	         @meter_table_name = @tab_name,
	         @meter_partition_field_name = @meter_partition_field_name
	    
	    FETCH NEXT FROM svc_cursor INTO @tab_name
	END 
	CLOSE svc_cursor 
	DEALLOCATE svc_cursor  
