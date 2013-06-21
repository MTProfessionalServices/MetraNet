
CREATE PROCEDURE templt_write_schedules(
	@my_id_acc int,
	@my_id_sub int,
	@v_id_audit int,
	@is_public int,
	@v_id_pricelist int,
	@v_id_pi_template int,
	--@v_param_table_def IN TP_PARAM_TABLE_DEF,
	@v_id_pt int,
	--@v_schedules IN OUT TP_SCHEDULE_ARRAY,
	@v_id_csr int = 137
)
AS
BEGIN
	DECLARE @sched_idx int
	DECLARE @rates_idx int
	--DECLARE @my_schedule TP_SCHEDULE;
	DECLARE @my_id_sched int
	DECLARE @my_chg_dates int
	DECLARE @my_chg_rates int
	DECLARE @my_tt_start datetime
	DECLARE @my_tt_end datetime
	DECLARE @my_id_sched_key uniqueidentifier
	--DECLARE @my_rates TP_PARAM_ARRAY;
	DECLARE @l_n_order  int
	DECLARE @l_sql      nvarchar (4000)
	--DECLARE @l_sql_explicit nvarchar (4000)
	DECLARE @l_i        int
	--DECLARE @l_rate     TP_PARAM_ROW;
	DECLARE @l_id_prm   int
	DECLARE @l_param_id int
	DECLARE @l_id_audit int
	DECLARE @is_persisted int
	DECLARE @my_id_pricelist int
	DECLARE @my_id_pi_template int
	--DECLARE @my_rate TP_PARAM_ROW;
	DECLARE @my_tt_date_cutoff datetime
	--DECLARE @l_vali int
	DECLARE @l_val1     nvarchar (100)
	DECLARE @l_val2     nvarchar (100)
	DECLARE @l_val3     nvarchar (100)
	DECLARE @l_val4     nvarchar (100)
	DECLARE @l_val5     nvarchar (100)
	DECLARE @l_val6     nvarchar (100)
	DECLARE @l_val7     nvarchar (100)
	DECLARE @l_val8     nvarchar (100)
	DECLARE @l_val9     nvarchar (100)
	DECLARE @l_val10     nvarchar (100)
	DECLARE @l_val11     nvarchar (100)
	DECLARE @l_val12     nvarchar (100)
	DECLARE @l_val13     nvarchar (100)
	DECLARE @l_val14     nvarchar (100)
	DECLARE @l_val15     nvarchar (100)
	DECLARE @nm_pt       nvarchar (100)
	DECLARE @audit_msg   nvarchar(256)

	SET @l_n_order = 0

	select @my_tt_date_cutoff = getutcdate()
	SET @my_id_pricelist = @v_id_pricelist
	SET @my_id_pi_template = @v_id_pi_template
	IF (@my_id_pi_template = 0 or @my_id_pi_template IS NULL)
		EXEC get_id_pi_template @my_id_sub, @v_id_pt, @my_id_pi_template OUT
	
	IF (@my_id_pricelist = 0 or @my_id_pricelist IS NULL)
		EXEC get_id_pl_by_pt @my_id_acc, @my_id_sub, @v_id_pt, @my_id_pi_template, @my_id_pricelist OUT
	
	SELECT @nm_pt = nm_pt FROM #tmp_cached_param_defs WHERE id_pt = @v_id_pt

	IF (@is_public = 1)
	BEGIN
		--my_schedule.id_sched := NULL;
		/* do not date bound it, nuke them all */
		SET @l_sql = 'DELETE ' + @nm_pt + ' WHERE id_sched in(select id_sched from t_rsched_pub a, t_pl_map c where c.id_sub = ' + CAST(@my_id_sub AS nvarchar(10)) + 
		' and c.id_paramtable = ' + CAST(@v_id_pt AS nvarchar(10)) + 
		' and c.id_pricelist = a.id_pricelist and c.id_paramtable = a.id_pt and c.id_pi_template = a.id_pi_template)';
		EXECUTE (@l_sql)
		declare @msg nvarchar(100)
		DELETE t_rsched_pub
		WHERE  id_sched in (
				SELECT id_sched
				FROM   t_rsched_pub a, t_pl_map c
				WHERE  c.id_sub = @my_id_sub
				   AND c.id_paramtable = @v_id_pt
				   AND c.id_pricelist = a.id_pricelist
				   AND c.id_paramtable = a.id_pt
				   AND a.id_pi_template = c.id_pi_template)
		set @msg = '---------DELETE t_rsched_pub: ' + cast(@@ROWCOUNT as nvarchar(10))
		print (@msg)
	END

	DECLARE @id_sched int
	DECLARE v_schedules CURSOR FOR
		SELECT id_sched, id_sched AS my_id_sched, chg_dates, chg_rates, tt_start, tt_end, id_sched_key
		FROM   #my_schedule_array

	OPEN v_schedules
	FETCH NEXT FROM v_schedules INTO @id_sched, @my_id_sched, @my_chg_dates, @my_chg_rates, @my_tt_start, @my_tt_end, @my_id_sched_key

	--sched_idx := v_schedules.first();
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		--print '----inside schedules, @my_chg_rates='+cast(@my_chg_rates as varchar(10))
		SET @is_persisted = 0
		--my_schedule := v_schedules(sched_idx);
		IF (@is_public = 1)
			SET @my_id_sched = NULL
		
		IF (@my_chg_dates > 0 and @my_id_sched IS NOT NULL and @is_public = 0)
		BEGIN
			SET @is_persisted = 1
			--print '-----EXEC templt_persist_rsched 01'
			EXEC templt_persist_rsched @my_id_acc, @v_id_pt, @my_id_sched, @my_id_pricelist, @my_id_pi_template, @my_tt_start, 1, 0, @my_tt_end, 1, 0, @is_public, @my_id_sub, @v_id_csr, @my_id_sched OUT
		END

		IF (@is_public = 1 or @my_chg_rates > 0)
		BEGIN
			DECLARE @p nvarchar(100)
			IF (@v_id_audit = 0 or @v_id_audit IS NULL)
			BEGIN
				SET @p = N'@p int OUT'
				SET @l_sql = N'SELECT @p = ISNULL(max(id_audit + 1),1) from ' + @nm_pt + N' where id_sched = ' + CAST(@my_id_sched AS nvarchar(10))
				EXEC sp_executesql @l_sql, @p, @l_id_audit OUT
			END
			ELSE
				SET @l_id_audit = @v_id_audit
			
			IF (@is_public = 0)
			BEGIN
				SET @p = N'@l_tt_end datetime, @v_id_sched int'
				SET @l_sql = N'UPDATE ' + @nm_pt + N' SET tt_end = @l_tt_end WHERE id_sched = @v_id_sched AND tt_end = dbo.mtmaxdate()'
				DECLARE @tt datetime
				SET @tt = dbo.SubtractSecond(@my_tt_date_cutoff)
				EXEC sp_executesql @l_sql, @p, @tt, @my_id_sched
			END
			SET @l_n_order = 0

			DECLARE @my_id_rate int
			DECLARE rates CURSOR FOR
				SELECT id_rate
				FROM   #tmp_schedule_rates
				WHERE  id_sched_key = @my_id_sched_key

			SET @rates_idx = 0
			OPEN rates
			FETCH NEXT FROM rates INTO @my_id_rate
			--print '--- before rates. @@FETCH_STATUS='+cast(@@FETCH_STATUS as varchar(1))
			--rates_idx := my_schedule.rates.first();
			WHILE (@@FETCH_STATUS = 0)
			BEGIN
			  IF (@is_persisted = 0 and @rates_idx = 0 and @my_id_sched IS NULL)
			  BEGIN
				SET @is_persisted = 1
				--print '------EXEC templt_persist_rsched 02'
				EXEC templt_persist_rsched @my_id_acc, @v_id_pt, @my_id_sched, @my_id_pricelist, @my_id_pi_template, @my_tt_start, 1, 0, @my_tt_end, 1, 0, @is_public, @my_id_sub, @v_id_csr, @my_id_sched OUT
			  END
			  ELSE
			  BEGIN
				IF (@is_persisted = 0 and @is_public = 0)
				BEGIN
				  SET @is_persisted = 1
				  /* insert rate schedule rules audit */
				  EXEC getcurrentid 'id_audit', @l_id_audit OUT
				  SET @audit_msg = N'MASS RATE: Updating rules for param table: ' + @nm_pt + N' Rate Schedule Id: ' + CAST(@my_id_sched AS nvarchar(10))
				  EXEC InsertAuditEvent
					@v_id_csr,
					1402,
					2,
					@my_id_sched,
					getutcdate,
					@l_id_audit,
					@audit_msg,
					@v_id_csr,
					NULL
				END
			  END

				--my_rate := my_schedule.rates(rates_idx);
				SET @l_sql = N'INSERT INTO ' + @nm_pt + N' (id_sched, id_audit, n_order, tt_start, tt_end'
				--SET @l_vali = 0
				--l_id_prm := v_param_table_def.param_defs.first ();
				SELECT @l_sql = @l_sql + N', ' + nm_column_name
				FROM   #tmp_param_defs
				WHERE  id_pt = @v_id_pt
				/*WHILE (l_id_prm IS NOT NULL)
				LOOP
					--SET @l_vali = l_vali + 1
					SET @l_sql = @l_sql + N', ' + v_param_table_def.param_defs (l_id_prm).nm_column_name;
					--SET @l_sql_explicit = @l_sql_explicit + N' l_' + @l_vali + N' NVARCHAR2(100) := :l_' + @l_vali + N';'
					SET @l_id_prm := v_param_table_def.param_defs.next (l_id_prm);
				END LOOP;*/
				SET @l_sql = @l_sql + N') VALUES (@v_id_sched, @v_id_audit, @l_n_order, @v_tt_start, dbo.mtmaxdate()'
				/*SET @l_sql_explicit = l_sql;
				SET @l_id_prm := v_param_table_def.param_defs.first ();
				SET @l_val1 = NULL
				SET @l_val2 = NULL
				SET @l_val3 = NULL
				SET @l_val4 = NULL
				SET @l_val5 = NULL
				SET @l_val6 = NULL
				SET @l_val7 = NULL
				SET @l_val8 = NULL
				SET @l_val9 = NULL
				SET @l_val10 = NULL
				SET @l_val11 = NULL
				SET @l_val12 = NULL
				SET @l_val13 = NULL
				SET @l_val14 = NULL
				SET @l_val15 = NULL*/
				--SET @l_vali = 0

				DECLARE v_param_table_def CURSOR FOR
					SELECT id_param_table_prop
					FROM   #tmp_param_defs
					WHERE  id_pt = @v_id_pt

				OPEN v_param_table_def
				FETCH NEXT FROM v_param_table_def INTO @l_param_id

				WHILE (@@FETCH_STATUS = 0)
				BEGIN
					--l_param_id := v_param_table_def.param_defs (l_id_prm).id_param_table_prop;
					--SET @l_vali = @l_vali + 1
					--IF (my_rate.params.exists (l_param_id))
					IF EXISTS (SELECT 1 FROM #tmp_schedule_rate_params WHERE id_rate = @my_id_rate AND id_param = @l_param_id)
					BEGIN
						SELECT @l_sql = @l_sql + N', ''' + nm_param + N''''
						FROM   #tmp_schedule_rate_params
						WHERE  id_rate = @my_id_rate AND id_param = @l_param_id

						/*IF (@l_vali = 1) THEN SET @l_val1 := my_rate.params (l_param_id)
						IF (@l_vali = 2) THEN SET @l_val2 := my_rate.params (l_param_id)
						IF (@l_vali = 3) THEN SET @l_val3 := my_rate.params (l_param_id)
						IF (@l_vali = 4) THEN SET @l_val4 := my_rate.params (l_param_id)
						IF (@l_vali = 5) THEN SET @l_val5 := my_rate.params (l_param_id)
						IF (@l_vali = 6) THEN SET @l_val6 := my_rate.params (l_param_id)
						IF (@l_vali = 7) THEN SET @l_val7 := my_rate.params (l_param_id)
						IF (@l_vali = 8) THEN SET @l_val8 := my_rate.params (l_param_id)
						IF (@l_vali = 9) THEN SET @l_val9 := my_rate.params (l_param_id)
						IF (@l_vali = 10) THEN SET @l_val10 := my_rate.params (l_param_id)
						IF (@l_vali = 11) THEN SET @l_val11 := my_rate.params (l_param_id)
						IF (@l_vali = 12) THEN SET @l_val12 := my_rate.params (l_param_id)
						IF (@l_vali = 13) THEN SET @l_val13 := my_rate.params (l_param_id)
						IF (@l_vali = 14) THEN SET @l_val14 := my_rate.params (l_param_id)
						IF (@l_vali = 15) THEN SET @l_val15 := my_rate.params (l_param_id)*/
					END
					ELSE
					BEGIN
						SET @l_sql = @l_sql + N', NULL'
						/*IF (@l_vali = 1) THEN SET @l_val1 = NULL
						IF (@l_vali = 2) THEN SET @l_val2 = NULL
						IF (@l_vali = 3) THEN SET @l_val3 = NULL
						IF (@l_vali = 4) THEN SET @l_val4 = NULL
						IF (@l_vali = 5) THEN SET @l_val5 = NULL
						IF (@l_vali = 6) THEN SET @l_val6 = NULL
						IF (@l_vali = 7) THEN SET @l_val7 = NULL
						IF (@l_vali = 8) THEN SET @l_val8 = NULL
						IF (@l_vali = 9) THEN SET @l_val9 = NULL
						IF (@l_vali = 10) THEN SET @l_val10 = NULL
						IF (@l_vali = 11) THEN SET @l_val11 = NULL
						IF (@l_vali = 12) THEN SET @l_val12 = NULL
						IF (@l_vali = 13) THEN SET @l_val13 = NULL
						IF (@l_vali = 14) THEN SET @l_val14 = NULL
						IF (@l_vali = 15) THEN SET @l_val15 = NULL*/
					END

					/*IF (@l_vali = v_param_table_def.param_defs.COUNT)
					BEGIN
						SET @l_sql_explicit = @l_sql_explicit + N', DECODE(1,1,:l_' + @l_vali
						WHILE (@l_vali < 15)
						LOOP
						  SET @l_vali = @l_vali + 1
						  SET @l_sql_explicit = @l_sql_explicit + N',' + @l_vali + N',:l_' + @l_vali
						END LOOP;
						SET @l_sql_explicit = @l_sql_explicit + N')'
					END
					ELSE
						SET @l_sql_explicit = @l_sql_explicit + N', :l_' + @l_vali*/
					
					--l_id_prm := v_param_table_def.param_defs.next (l_id_prm);
					FETCH NEXT FROM v_param_table_def INTO @l_param_id
				END

				CLOSE v_param_table_def
				DEALLOCATE v_param_table_def

				SET @l_sql = @l_sql + N')'
				--SET @l_sql_explicit = @l_sql_explicit + N')'
				--IF (v_param_table_def.param_defs.COUNT > 15)
				  --EXECUTE IMMEDIATE l_sql USING my_schedule.id_sched, l_id_audit, l_n_order, my_tt_date_cutoff;
				SET @p = N'@v_id_sched int, @v_id_audit int, @l_n_order int, @v_tt_start datetime'
				EXEC sp_executesql @l_sql, @p, @my_id_sched, @l_id_audit, @l_n_order, @my_tt_date_cutoff

				/*ELSE
				  EXECUTE IMMEDIATE l_sql_explicit USING my_schedule.id_sched, l_id_audit, l_n_order, my_tt_date_cutoff,
														 l_val1, l_val2, l_val3, l_val4, l_val5, l_val6, l_val7, l_val8,
														 l_val9, l_val10, l_val11, l_val12, l_val13, l_val14, l_val15;*/
				
				SET @l_n_order = @l_n_order + 1
				SET @rates_idx = @rates_idx + 1
				--rates_idx := my_schedule.rates.next(rates_idx);
				FETCH NEXT FROM rates INTO @my_id_rate
			END

			CLOSE rates
			DEALLOCATE rates
		END
		--v_schedules(sched_idx) := my_schedule;
		UPDATE #my_schedule_array
		SET		tt_start = @my_tt_start,
				tt_end = @my_tt_end,
				chg_dates = @my_chg_dates,
				chg_rates = @my_chg_rates,
				id_sched = @my_id_sched
		WHERE  id_sched_key = @my_id_sched_key

		--sched_idx := v_schedules.next(sched_idx);
		FETCH NEXT FROM v_schedules INTO @id_sched, @my_id_sched, @my_chg_dates, @my_chg_rates, @my_tt_start, @my_tt_end, @my_id_sched_key
	END

	CLOSE v_schedules
	DEALLOCATE v_schedules
END
