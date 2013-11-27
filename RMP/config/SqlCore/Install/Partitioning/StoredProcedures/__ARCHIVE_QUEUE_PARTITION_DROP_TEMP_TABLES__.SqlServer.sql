CREATE PROCEDURE archive_queue_partition_drop_temp_tables(@temp_table_postfix NVARCHAR(50))
AS
	SET NOCOUNT ON
	DECLARE @tab_name NVARCHAR(100),
			@temp_tab_name NVARCHAR(100)
	
	SET @temp_tab_name = 't_session' + @temp_table_postfix
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'dbo'
	              AND TABLE_NAME = @temp_tab_name
	   )
	    EXEC ('DROP TABLE ' + @temp_tab_name)
	
	SET @temp_tab_name = 't_session_state' + @temp_table_postfix
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'dbo'
	              AND TABLE_NAME = @temp_tab_name
	   )
	    EXEC ('DROP TABLE ' + @temp_tab_name)
		
	SET @temp_tab_name = 't_session_set' + @temp_table_postfix
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'dbo'
	              AND TABLE_NAME = @temp_tab_name
	   )
	    EXEC ('DROP TABLE ' + @temp_tab_name)
	    
	SET @temp_tab_name = 't_message' + @temp_table_postfix
	IF EXISTS (
	       SELECT *
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'dbo'
	              AND TABLE_NAME = @temp_tab_name
	   )
	    EXEC ('DROP TABLE ' + @temp_tab_name)
		
	DECLARE svc_cursor CURSOR FAST_FORWARD 
	FOR
	    SELECT nm_table_name
	    FROM   t_service_def_log
	
	OPEN svc_cursor 
	FETCH NEXT FROM svc_cursor INTO @tab_name	
	WHILE (@@fetch_status = 0)
	BEGIN
	    SET @temp_tab_name = @tab_name + @temp_table_postfix	
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

