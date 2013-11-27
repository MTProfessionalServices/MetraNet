IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns WHERE table_name = 't_message' AND column_name = 'id_partition')	
		ALTER TABLE t_message 
		ADD id_partition INT NOT NULL DEFAULT 1

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns WHERE table_name = 't_session' AND column_name = 'id_partition')	
		ALTER TABLE t_session 
		ADD id_partition INT NOT NULL DEFAULT 1

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns WHERE table_name = 't_session_set' AND column_name = 'id_partition')	
		ALTER TABLE t_session_set 
		ADD id_partition INT NOT NULL DEFAULT 1

IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns WHERE table_name = 't_session_state' AND column_name = 'id_partition')	
		ALTER TABLE t_session_state 
		ADD id_partition INT NOT NULL  DEFAULT 1


DECLARE svctablecur CURSOR FOR
	SELECT nm_table_name
	FROM t_service_def_log 
	
DECLARE @svc_table_name VARCHAR(50)

OPEN svctablecur
FETCH NEXT FROM svctablecur INTO @svc_table_name
WHILE (@@FETCH_STATUS = 0)
BEGIN
	IF OBJECT_ID(@svc_table_name) IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT column_name FROM INFORMATION_SCHEMA.columns WHERE table_name = @svc_table_name AND column_name = 'id_partition')	
		EXEC ('ALTER TABLE ' + @svc_table_name +
		' ADD id_partition INT NOT NULL DEFAULT 1')
	END  
	FETCH NEXT FROM svctablecur INTO @svc_table_name
END

CLOSE svctablecur
DEALLOCATE svctablecur
