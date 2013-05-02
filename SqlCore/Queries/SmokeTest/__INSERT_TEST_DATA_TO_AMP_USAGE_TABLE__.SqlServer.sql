
		BEGIN

		/* This temp table will be used to cleanup 'agg_usage_audit_trail' table from test data */
		IF OBJECT_ID('tempdb..%%TABLE_WITH_TEST_IDSESS%%') IS NOT NULL			
				DROP TABLE %%TABLE_WITH_TEST_IDSESS%%								
		CREATE TABLE %%TABLE_WITH_TEST_IDSESS%%(id_sess INT)
		
		DECLARE partcur CURSOR FOR
			SELECT id_interval_start, id_interval_end
			FROM t_partition 
			
		DECLARE @id_interval_start INT,
				@id_intervar_end INT,
				@new_id_sess INT				

		OPEN partcur
		FETCH NEXT FROM partcur INTO @id_interval_start, @id_intervar_end
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			/* Append 'agg_usage_audit_trail' with test data in different partitions */
			SELECT @new_id_sess = ISNULL(MAX(id_sess), 0) + 1 FROM agg_usage_audit_trail			
			INSERT INTO agg_usage_audit_trail
			(
				id_payee, id_sess, id_usage_interval, is_realtime
			)
			VALUES
			(
				1, @new_id_sess, @id_interval_start, 1
			)
			INSERT INTO %%TABLE_WITH_TEST_IDSESS%% VALUES (@new_id_sess)
			
			FETCH NEXT FROM partcur INTO @id_interval_start, @id_intervar_end
		END

		CLOSE partcur
		DEALLOCATE partcur 	
		END
		