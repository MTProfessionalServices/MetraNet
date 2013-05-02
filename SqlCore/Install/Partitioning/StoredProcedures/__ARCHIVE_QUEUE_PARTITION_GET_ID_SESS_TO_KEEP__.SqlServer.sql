CREATE PROCEDURE archive_queue_partition_get_id_sess_to_keep(@old_id_partition INT)
AS
	SET NOCOUNT ON
	
	DECLARE @max_time    DATETIME,
	        @preserved_id_partition INT
	
	SELECT @max_time = dbo.mtmaxdate()
	SET @preserved_id_partition = @old_id_partition - 1
	
	IF OBJECT_ID('tempdb..##id_sess_to_keep') IS NOT NULL
	    DROP TABLE ##id_sess_to_keep
	
	SELECT DISTINCT(id_sess) INTO ##id_sess_to_keep
	FROM   t_session_state st
	WHERE  st.id_partition IN (@old_id_partition, @preserved_id_partition)
	       AND tx_state IN ('F', 'R')
	       AND dt_end = @max_time
	OPTION(MAXDOP 1)
	
	INSERT INTO ##id_sess_to_keep
	SELECT sess.id_source_sess
	FROM   t_session sess
	WHERE  sess.id_partition IN (@old_id_partition, @preserved_id_partition)
	       AND NOT EXISTS (
	               SELECT 1
	               FROM   t_session_state st
	               WHERE  st.id_partition IN (@old_id_partition, @preserved_id_partition)
	                      AND st.id_sess = sess.id_source_sess
	           )
	OPTION(MAXDOP 1)
	
	INSERT INTO ##id_sess_to_keep
	SELECT DISTINCT(ts.id_source_sess)
	FROM   t_usage_interval ui
	       JOIN t_uk_acc_usage_tx_uid au
	            ON  au.id_usage_interval = ui.id_interval
	       JOIN t_session ts
	            ON  ts.id_source_sess = au.tx_UID
	WHERE  ts.id_partition IN (@old_id_partition, @preserved_id_partition)
	       AND ui.tx_interval_status <> 'H'
	OPTION(MAXDOP 1)
	
	CREATE CLUSTERED INDEX idx_id_sess_to_keep ON ##id_sess_to_keep(id_sess)
