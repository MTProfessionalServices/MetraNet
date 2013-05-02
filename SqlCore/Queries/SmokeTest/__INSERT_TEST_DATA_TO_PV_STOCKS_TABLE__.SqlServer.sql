
		BEGIN

		/* This temp table will be used to cleanup 'agg_charge_audit_trail' table from test data */
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

			/* Append 't_pv_stocks' with test data in different partitions */
			SELECT @new_id_sess = ISNULL(MAX(id_sess), 0) + 1 FROM t_pv_stocks
			INSERT INTO t_pv_stocks
			(
				id_sess, id_usage_interval, c_symbol, c_quantity, c_ordertime, c_transactionid, c_broker
			)
			VALUES
			(
				@new_id_sess, @id_interval_start + 1, 'test', 1, GETDATE(), NEWID(), 'Test Broker'		
			)
			INSERT INTO %%TABLE_WITH_TEST_IDSESS%% VALUES (@new_id_sess)
				
			FETCH NEXT FROM partcur INTO @id_interval_start, @id_intervar_end
		END

		CLOSE partcur
		DEALLOCATE partcur 	
		END
		