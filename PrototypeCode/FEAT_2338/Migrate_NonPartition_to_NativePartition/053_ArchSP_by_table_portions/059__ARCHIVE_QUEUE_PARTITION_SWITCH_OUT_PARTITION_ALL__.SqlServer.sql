IF OBJECT_ID('archive_queue_partition_switch_out_partition_all') IS NOT NULL 
	DROP PROCEDURE archive_queue_partition_switch_out_partition_all
GO

CREATE PROCEDURE archive_queue_partition_switch_out_partition_all(
    @number_of_partition       INT,
    @partition_filegroup_name  NVARCHAR(50)
)
AS
	SET NOCOUNT ON
	
	DECLARE @next_partition INT,
			@sqlCommand NVARCHAR(MAX)
	SET @next_partition = @number_of_partition + 1
	
	
	/* t_session */
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N't_session_sess_to_keep'))
		DROP TABLE t_session_sess_to_keep
	
	SELECT * INTO t_session_sess_to_keep
	FROM   t_session
	WHERE  id_source_sess IN (SELECT id_sess
	                          FROM   ##id_sess_to_keep)
	       AND id_partition = @number_of_partition
	
	UPDATE t_session_sess_to_keep
	SET    id_partition = @next_partition
	
	BEGIN TRAN
	
	INSERT INTO t_session
	SELECT *
	FROM   t_session_sess_to_keep
	
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session',
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	COMMIT TRAN
	
	DROP TABLE t_session_sess_to_keep
	
	
	/* t_session_state */
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N't_session_state_sess_to_keep'))
		DROP TABLE t_session_state_sess_to_keep
		
	SELECT * INTO t_session_state_sess_to_keep
	FROM   t_session_state ss
	WHERE  ss.id_sess IN (SELECT t.id_sess
	                      FROM   ##id_sess_to_keep t)
	       AND ss.id_partition = @number_of_partition
	
	UPDATE t_session_state_sess_to_keep
	SET    id_partition = @next_partition
	
	BEGIN TRAN
	
	INSERT INTO t_session_state
	SELECT *
	FROM   t_session_state_sess_to_keep
	
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session_state',
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	COMMIT TRAN
	
	DROP TABLE t_session_state_sess_to_keep
	
	
	/* t_session_set */
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N't_session_set_sess_to_keep'))
		DROP TABLE t_session_set_sess_to_keep
		
	SELECT * INTO t_session_set_sess_to_keep
	FROM   t_session_set ss
	WHERE  ss.id_ss IN (SELECT s.id_ss
	                    FROM   ##id_sess_to_keep t
	                           JOIN t_session s
	                                ON  s.id_source_sess = t.id_sess)
	       AND ss.id_partition = @number_of_partition
	
	UPDATE t_session_set_sess_to_keep
	SET    id_partition = @next_partition
	
	BEGIN TRAN
	
	INSERT INTO t_session_set
	SELECT *
	FROM   t_session_set_sess_to_keep
	
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session_set',
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	COMMIT TRAN
	
	DROP TABLE t_session_set_sess_to_keep
	
	
	/* Hardcode clonning of t_message due to CORE-6477
	* Possible fix - inside archive_queue_partition_switch_out_partition
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_message',
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	*/
	
	/* t_message */
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

	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N't_message_sess_to_keep'))
		DROP TABLE t_message_sess_to_keep
		
	SELECT * INTO t_message_sess_to_keep
	FROM   t_message m
	WHERE  m.id_message IN (SELECT ss.id_message
	                        FROM   t_session_set ss
	                               JOIN t_session s
	                                    ON  s.id_ss = ss.id_ss
	                               JOIN ##id_sess_to_keep t
	                                    ON  s.id_source_sess = t.id_sess)
	       AND m.id_partition = @number_of_partition
	
	UPDATE t_message_sess_to_keep
	SET    id_partition = @next_partition
	
	SET @sqlCommand = 'ALTER TABLE t_message SWITCH PARTITION '+ CAST(@number_of_partition AS VARCHAR(20)) 
	    	    	+ ' TO t_message_temp_switch_partition_table'
	
	BEGIN TRAN
	
	INSERT INTO t_message SELECT * FROM t_message_sess_to_keep
	
	EXEC (@sqlCommand)
	
	COMMIT TRAN
	
	DROP TABLE t_message_sess_to_keep
	
	
	/* loop by svc_* tables */
	DECLARE @tab_name NVARCHAR(100),
			@tab_for_sess_to_keep NVARCHAR(100)
	DECLARE svc_cursor CURSOR FAST_FORWARD 
	FOR
	    SELECT nm_table_name
	    FROM   t_service_def_log
	
	OPEN svc_cursor 
	FETCH NEXT FROM svc_cursor INTO @tab_name
	
	WHILE (@@fetch_status = 0)
	BEGIN
		
		SET @tab_for_sess_to_keep = @tab_name + '_sess_to_keep'
		
		SET @sqlCommand = 'IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N''dbo'' AND TABLE_NAME = N''' + @tab_for_sess_to_keep + '''))
		DROP TABLE ' + @tab_for_sess_to_keep
		EXEC(@sqlCommand)
		
		SET @sqlCommand = 'SELECT * INTO ' + @tab_for_sess_to_keep + '
							FROM   ' + @tab_name + '
							WHERE  id_source_sess IN (SELECT id_sess
													  FROM   ##id_sess_to_keep)
								   AND id_partition = @number_of_partition'
		EXEC sp_executesql @sqlCommand, N'@number_of_partition int', @number_of_partition
		
		SET @sqlCommand = 'UPDATE ' + @tab_for_sess_to_keep + ' SET id_partition = @next_partition'
		EXEC sp_executesql @sqlCommand, N'@next_partition int', @next_partition
		
		BEGIN TRAN
		
		SET @sqlCommand = 'INSERT INTO ' + @tab_name + ' SELECT * FROM ' + @tab_for_sess_to_keep
		EXEC(@sqlCommand)
		
	    EXEC archive_queue_partition_switch_out_partition
	         @table_name = @tab_name,
	         @number_of_partition = @number_of_partition,
	         @partition_filegroup_name = @partition_filegroup_name
	    
	    COMMIT TRAN
	    
		SET @sqlCommand = 'DROP TABLE ' + @tab_for_sess_to_keep
		EXEC(@sqlCommand)
	    
	    FETCH NEXT FROM svc_cursor INTO @tab_name
	END
	CLOSE svc_cursor
	DEALLOCATE svc_cursor
