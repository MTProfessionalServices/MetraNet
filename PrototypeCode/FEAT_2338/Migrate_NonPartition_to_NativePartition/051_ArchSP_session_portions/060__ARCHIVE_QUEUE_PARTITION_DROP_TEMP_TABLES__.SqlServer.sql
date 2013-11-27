IF OBJECT_ID('archive_queue_partition_drop_temp_tables') IS NOT NULL 
	DROP PROCEDURE archive_queue_partition_drop_temp_tables
GO

CREATE PROCEDURE archive_queue_partition_drop_temp_tables
AS
	SET NOCOUNT ON
	
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'dbo'
	              AND TABLE_NAME = N't_session_temp_switch_partition_table'
	   )
	    DROP TABLE t_session_temp_switch_partition_table
	
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'dbo'
	              AND TABLE_NAME = 
	                  N't_session_state_temp_switch_partition_table'
	   )
	    DROP TABLE t_session_state_temp_switch_partition_table
	
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'dbo'
	              AND TABLE_NAME = N't_session_set_temp_switch_partition_table'
	   )
	    DROP TABLE t_session_set_temp_switch_partition_table
	
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'dbo'
	              AND TABLE_NAME = N't_message_temp_switch_partition_table'
	   )
	    DROP TABLE t_message_temp_switch_partition_table
	
	DECLARE @tab_name       NVARCHAR(100),
	        @temp_tab_name  NVARCHAR(100),
	        @sqlCommand     NVARCHAR(MAX)
	
	DECLARE svc_cursor CURSOR FAST_FORWARD 
	FOR
	    SELECT nm_table_name
	    FROM   t_service_def_log
	
	OPEN svc_cursor 
	FETCH NEXT FROM svc_cursor INTO @tab_name	
	WHILE (@@fetch_status = 0)
	BEGIN
	    SET @temp_tab_name = @tab_name + '_temp_switch_partition_table'		
	    IF EXISTS (
	           SELECT *
	           FROM   INFORMATION_SCHEMA.TABLES
	           WHERE  TABLE_SCHEMA = N'dbo'
	                  AND TABLE_NAME = @temp_tab_name
	       )
	        EXEC ('DROP TABLE ' + @temp_tab_name)
	    
	    FETCH NEXT FROM svc_cursor INTO @tab_name
	END 
	CLOSE svc_cursor 
	DEALLOCATE svc_cursor

