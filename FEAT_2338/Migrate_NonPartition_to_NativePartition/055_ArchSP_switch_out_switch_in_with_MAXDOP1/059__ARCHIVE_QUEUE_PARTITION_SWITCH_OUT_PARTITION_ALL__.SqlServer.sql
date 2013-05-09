IF OBJECT_ID('archive_queue_partition_switch_out_partition_all') IS NOT NULL 
	DROP PROCEDURE archive_queue_partition_switch_out_partition_all
GO

CREATE PROCEDURE archive_queue_partition_switch_out_partition_all(
    @number_of_partition           INT,
    @partition_filegroup_name      NVARCHAR(50),
    @temp_table_postfix_oldest     NVARCHAR(50),
    @temp_table_postfix_preserved  NVARCHAR(50)
)
AS
	SET NOCOUNT ON
	
	DECLARE @preserved_partition                INT,
	        @temp_tab_for_switch_out_oldest     NVARCHAR(100),
	        @temp_tab_for_switch_out_preserved  NVARCHAR(100),
	        @mn_db_name                         NVARCHAR(100),
	        @sqlCommand                         NVARCHAR(MAX)
	
	SET @preserved_partition = @number_of_partition - 1
	SET @mn_db_name = DB_NAME()
	
	/* loop by svc_* tables */
	DECLARE @tab_name NVARCHAR(100)
	DECLARE svc_cursor CURSOR FAST_FORWARD 
	FOR
	    SELECT nm_table_name
	    FROM   t_service_def_log
	
	OPEN svc_cursor 
	FETCH NEXT FROM svc_cursor INTO @tab_name
	
	WHILE (@@fetch_status = 0)
	BEGIN
		
		EXEC archive_queue_partition_switch_out_with_keep_sess
			@number_of_partition = @number_of_partition,
			@table_name = @tab_name,
			@temp_table_postfix_oldest = @temp_table_postfix_oldest,
			@temp_table_postfix_preserved = @temp_table_postfix_preserved,
			@partition_filegroup_name = @partition_filegroup_name
		
	    FETCH NEXT FROM svc_cursor INTO @tab_name
	END
	CLOSE svc_cursor
	DEALLOCATE svc_cursor
	
	
	/* t_message */
	SET @temp_tab_for_switch_out_oldest = 't_message' + @temp_table_postfix_oldest
	SET @temp_tab_for_switch_out_preserved = 't_message' + @temp_table_postfix_preserved
		
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = @temp_tab_for_switch_out_oldest))
		EXEC ('DROP TABLE ' + @temp_tab_for_switch_out_oldest)
		
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = @temp_tab_for_switch_out_preserved))
		EXEC ('DROP TABLE ' + @temp_tab_for_switch_out_preserved)
			
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N't_message_sess_to_keep'))
		DROP TABLE t_message_sess_to_keep
	
	/* Hardcode clonning of t_message due to CORE-6477 */	
	EXEC ('ALTER DATABASE ' + @mn_db_name + ' MODIFY FILEGROUP ' + @partition_filegroup_name + ' DEFAULT')
	
	EXEC archive_queue_partition_clone_table 
		 @source_table = N't_message',
		 @destination_table = @temp_tab_for_switch_out_oldest,
		 @file_group = @partition_filegroup_name
		 
	EXEC archive_queue_partition_clone_table 
		 @source_table = N't_message',
		 @destination_table = @temp_tab_for_switch_out_preserved,
		 @file_group = @partition_filegroup_name
		 		 
	SELECT TOP (0) * INTO t_message_sess_to_keep FROM t_message
	
	EXEC ('ALTER DATABASE ' + @mn_db_name + ' MODIFY FILEGROUP [PRIMARY] DEFAULT')		
		
	INSERT INTO t_message_sess_to_keep
	SELECT *
	FROM   t_message m
	WHERE  m.id_message IN (SELECT ss.id_message
	                        FROM   t_session_set ss
	                               JOIN t_session s
	                                    ON  s.id_ss = ss.id_ss
	                               JOIN ##id_sess_to_keep t
	                                    ON  s.id_source_sess = t.id_sess)
	       AND m.id_partition = @preserved_partition
	OPTION(MAXDOP 1)
	
	UPDATE t_message_sess_to_keep SET id_partition = @number_of_partition
	OPTION(MAXDOP 1)
	
	INSERT INTO t_message_sess_to_keep
	SELECT *
	FROM   t_message m
	WHERE  m.id_message IN (SELECT ss.id_message
	                        FROM   t_session_set ss
	                               JOIN t_session s
	                                    ON  s.id_ss = ss.id_ss
	                               JOIN ##id_sess_to_keep t
	                                    ON  s.id_source_sess = t.id_sess)
	       AND m.id_partition = @number_of_partition
	OPTION(MAXDOP 1)
	
	EXEC archive_queue_partition_clone_all_indexes_and_constraints
	     @SourceSchema = N'dbo',
	     @SourceTable = N't_message',
	     @DestinationSchema = N'dbo',
	     @DestinationTable = N't_message_sess_to_keep',
	     @FileGroup = @partition_filegroup_name
	
	SET @sqlCommand = 'ALTER TABLE t_message_sess_to_keep WITH CHECK
						ADD CONSTRAINT CK_t_message_sess_to_keep CHECK((id_partition = ('
						+ CAST(@number_of_partition AS VARCHAR(20)) + ')))'
	EXEC (@sqlCommand)
	
	ALTER TABLE t_message_sess_to_keep CHECK CONSTRAINT CK_t_message_sess_to_keep
	
	BEGIN TRAN
	
	/* SWITCH OUT 'old' partition */
	SET @sqlCommand = 'ALTER TABLE t_message SWITCH PARTITION $PARTITION.MeterPartitionFunction('
					+ CAST(@number_of_partition AS VARCHAR(20))
					+ ') TO ' + @temp_tab_for_switch_out_oldest
	EXEC (@sqlCommand)
	
	/* SWITCH OUT 'preserved' partition */
	SET @sqlCommand = 'ALTER TABLE t_message SWITCH PARTITION $PARTITION.MeterPartitionFunction('
					+ CAST(@preserved_partition AS NVARCHAR(20))
					+ ') TO ' + @temp_tab_for_switch_out_preserved
	EXEC (@sqlCommand)
	
	/* SWITCH IN new 'preserved' partition with sessions to keep */
	SET @sqlCommand = 'ALTER TABLE t_message_sess_to_keep SWITCH TO t_message PARTITION
					$PARTITION.MeterPartitionFunction('
					+ CAST(@number_of_partition AS VARCHAR(20))+ ')'
	EXEC (@sqlCommand)
		
	COMMIT TRAN
	
	DROP TABLE t_message_sess_to_keep
	
	
	/* t_session_set */
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N't_session_set_sess_to_keep'))
		DROP TABLE t_session_set_sess_to_keep
			
	SELECT * INTO t_session_set_sess_to_keep
	FROM   t_session_set ss
	WHERE  ss.id_ss IN (SELECT s.id_ss
	                    FROM   ##id_sess_to_keep t
	                           JOIN t_session s
	                                ON  s.id_source_sess = t.id_sess)
	       AND ss.id_partition = @preserved_partition
	OPTION(MAXDOP 1)
	
	UPDATE t_session_set_sess_to_keep
	SET    id_partition = @number_of_partition
	OPTION(MAXDOP 1)
	
	INSERT INTO t_session_set_sess_to_keep
	SELECT * 
	FROM   t_session_set ss
	WHERE  ss.id_ss IN (SELECT s.id_ss
	                    FROM   ##id_sess_to_keep t
	                           JOIN t_session s
	                                ON  s.id_source_sess = t.id_sess)
	       AND ss.id_partition = @number_of_partition
	OPTION(MAXDOP 1)
	
	EXEC archive_queue_partition_clone_all_indexes_and_constraints
	     @SourceSchema = N'dbo',
	     @SourceTable = N't_session_set',
	     @DestinationSchema = N'dbo',
	     @DestinationTable = N't_session_set_sess_to_keep',
	     @FileGroup = N'MeterFileGroup'
		
	SET @sqlCommand = 'ALTER TABLE t_session_set_sess_to_keep WITH CHECK
						ADD CONSTRAINT CK_t_session_set_sess_to_keep CHECK((id_partition = ('
						+ CAST(@number_of_partition AS VARCHAR(20)) + ')))'
	EXEC (@sqlCommand)
	ALTER TABLE t_session_set_sess_to_keep CHECK CONSTRAINT CK_t_session_set_sess_to_keep
	
	BEGIN TRAN
	
	/* SWITCH OUT 'old' partition */
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session_set',
	     @temp_table_postfix = @temp_table_postfix_oldest,
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	/* SWITCH OUT 'preserved' partition */
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session_set',
	     @temp_table_postfix = @temp_table_postfix_preserved,
	     @number_of_partition = @preserved_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	/* SWITCH IN new 'preserved' partition with sessions to keep */
	SET @sqlCommand = 'ALTER TABLE t_session_set_sess_to_keep SWITCH TO t_session_set PARTITION 
					$PARTITION.MeterPartitionFunction('
					+ CAST(@number_of_partition AS VARCHAR(20))+ ')'
	EXEC (@sqlCommand)
		
	COMMIT TRAN
	
	DROP TABLE t_session_set_sess_to_keep
	
	
	/* t_session_state */	
	IF (EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = N'dbo' AND TABLE_NAME = N't_session_state_sess_to_keep'))
		DROP TABLE t_session_state_sess_to_keep
	
	SELECT * INTO t_session_state_sess_to_keep
	FROM   t_session_state ss
	WHERE ss.id_sess IN (SELECT t.id_sess
	                          FROM   ##id_sess_to_keep t)
	       AND ss.id_partition = @preserved_partition
	OPTION(MAXDOP 1)
	
	UPDATE t_session_state_sess_to_keep
	SET    id_partition = @number_of_partition
	OPTION(MAXDOP 1)
	
	INSERT INTO t_session_state_sess_to_keep
	SELECT *
	FROM   t_session_state ss
	WHERE ss.id_sess IN (SELECT t.id_sess
	                          FROM   ##id_sess_to_keep t)
	       AND ss.id_partition = @number_of_partition
	OPTION(MAXDOP 1)
	
	EXEC archive_queue_partition_clone_all_indexes_and_constraints
	     @SourceSchema = N'dbo',
	     @SourceTable = N't_session_state',
	     @DestinationSchema = N'dbo',
	     @DestinationTable = N't_session_state_sess_to_keep',
	     @FileGroup = N'MeterFileGroup'
	
	SET @sqlCommand = 'ALTER TABLE t_session_state_sess_to_keep WITH CHECK
						ADD CONSTRAINT CK_t_session_state_sess_to_keep CHECK((id_partition = ('
						+ CAST(@number_of_partition AS VARCHAR(20)) + ')))'
	EXEC (@sqlCommand)
	ALTER TABLE t_session_state_sess_to_keep CHECK CONSTRAINT CK_t_session_state_sess_to_keep
	
	BEGIN TRAN
	
	/* SWITCH OUT 'old' partition */
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session_state',
	     @temp_table_postfix = @temp_table_postfix_oldest,
	     @number_of_partition = @number_of_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	/* SWITCH OUT 'preserved' partition */
	EXEC archive_queue_partition_switch_out_partition
	     @table_name = N't_session_state',
	     @temp_table_postfix = @temp_table_postfix_preserved,
	     @number_of_partition = @preserved_partition,
	     @partition_filegroup_name = @partition_filegroup_name
	
	/* SWITCH IN new 'preserved' partition with sessions to keep */
	SET @sqlCommand = 'ALTER TABLE t_session_state_sess_to_keep SWITCH TO t_session_state PARTITION
					$PARTITION.MeterPartitionFunction('
					+ CAST(@number_of_partition AS VARCHAR(20)) + ')'
	EXEC (@sqlCommand)
	
	COMMIT TRAN
	
	DROP TABLE t_session_state_sess_to_keep
	
	
	/* t_session */
	exec archive_queue_partition_switch_out_with_keep_sess
		@number_of_partition = @number_of_partition,
		@table_name = 't_session',
		@temp_table_postfix_oldest = @temp_table_postfix_oldest,
		@temp_table_postfix_preserved = @temp_table_postfix_preserved,
		@partition_filegroup_name = @partition_filegroup_name
