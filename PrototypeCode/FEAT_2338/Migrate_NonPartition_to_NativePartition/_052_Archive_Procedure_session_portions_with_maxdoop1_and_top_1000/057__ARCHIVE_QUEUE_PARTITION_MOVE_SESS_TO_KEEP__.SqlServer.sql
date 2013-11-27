IF OBJECT_ID('archive_queue_partition_move_id_sess_to_keep') IS NOT NULL 
	DROP PROCEDURE archive_queue_partition_move_id_sess_to_keep
GO

CREATE PROCEDURE archive_queue_partition_move_id_sess_to_keep(@current_id_partition INT, @old_id_partition INT)
AS
	SET NOCOUNT ON
	
	DECLARE @svc_table_name  NVARCHAR(1000),
	        @sqlCommand      NVARCHAR(MAX),
	        @last_id_sess    BINARY(16),
	        @count_cycle     INT
	
	
	SET @count_cycle = 0
	SELECT @last_id_sess = MIN(k.id_sess)
	FROM   ##id_sess_to_keep k
	
	WHILE (@last_id_sess IS NOT NULL)
	BEGIN
	    IF OBJECT_ID('tempdb..##id_sess_current') IS NOT NULL
	        DROP TABLE ##id_sess_current
	    
	    SELECT TOP 1000 k.id_sess INTO ##id_sess_current
	    FROM   ##id_sess_to_keep k
	    WHERE  k.id_sess > @last_id_sess
		OPTION(MAXDOP 1)
	    
	    CREATE CLUSTERED INDEX idx_id_sess_current ON ##id_sess_current(id_sess)
	    
	    SELECT @last_id_sess = MAX(cc.id_sess)
	    FROM   ##id_sess_current cc
	    
	    IF @last_id_sess IS NULL
	    BEGIN
	        PRINT 'break: all session which should be moved were processed'
	        BREAK
	    END
	    
	    BEGIN TRAN
	    
	    DECLARE c1 CURSOR FAST_FORWARD 
	    FOR
	        SELECT nm_table_name
	        FROM   t_service_def_log
	    
	    OPEN c1
	    FETCH NEXT FROM c1 INTO @svc_table_name  
	    WHILE (@@fetch_status = 0)
	    BEGIN
	        SET @sqlCommand =
			'	UPDATE svc		
				SET    svc.id_partition = @current_id_partition
				FROM ' + @svc_table_name + ' svc
				JOIN  ##id_sess_current cc
				ON svc.id_source_sess = cc.id_sess
				WHERE  id_partition = @old_id_partition
				OPTION(MAXDOP 1)'
			
			EXEC sp_executesql @sqlCommand,
				 N'@old_id_partition int, @current_id_partition int',
				 @old_id_partition,
				 @current_id_partition
	        
	        FETCH NEXT FROM c1 INTO @svc_table_name
	    END
	    CLOSE c1
	    DEALLOCATE c1
	    
	    UPDATE ses
	    SET    ses.id_partition = @current_id_partition
	    FROM   t_session ses
	           JOIN ##id_sess_current cc
	                ON  ses.id_source_sess = cc.id_sess
	    WHERE  id_partition = @old_id_partition
		OPTION(MAXDOP 1)
	    
	    
	    UPDATE s_st
	    SET    s_st.id_partition = @current_id_partition
	    FROM   t_session_state s_st
	           JOIN ##id_sess_current cc
	                ON  s_st.id_sess = cc.id_sess
	    WHERE  id_partition = @old_id_partition
		OPTION(MAXDOP 1)
	    
	    
	    UPDATE ss
	    SET    ss.id_partition = @current_id_partition
	    FROM   t_session_set ss
	           JOIN t_session s
	                ON  s.id_ss = ss.id_ss
	           JOIN ##id_sess_current cc
	                ON  s.id_source_sess = cc.id_sess
	    WHERE  ss.id_partition = @old_id_partition
		OPTION(MAXDOP 1)
	    
	    UPDATE m
	    SET    m.id_partition = @current_id_partition
	    FROM   t_message m
	           JOIN t_session_set ss
	                ON  ss.id_message = m.id_message
	           JOIN t_session s
	                ON  s.id_ss = ss.id_ss
	           JOIN ##id_sess_current cc
	                ON  s.id_source_sess = cc.id_sess
	    WHERE  m.id_partition = @old_id_partition
		OPTION(MAXDOP 1)
	    
	    COMMIT TRAN
	    
	    SET @count_cycle = @count_cycle + 1
	    PRINT '# batch is ' + CAST(@count_cycle AS NVARCHAR(1000))
	END
