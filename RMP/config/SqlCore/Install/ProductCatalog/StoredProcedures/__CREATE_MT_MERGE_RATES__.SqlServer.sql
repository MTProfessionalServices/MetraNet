
/* merges low priority rates into high priority rates */
CREATE PROCEDURE mt_merge_rates(
	@v_update int,
	@v_id_pt int,
	--v_param_defs IN TP_PARAM_DEF_ARRAY,
	--v_rates_low IN TP_PARAM_ARRAY,
	@new_id_sched_key uniqueidentifier,
	--v_rates_high IN TP_PARAM_ARRAY,
	--v_rates_out OUT TP_PARAM_ARRAY
	@id_sched_out_key uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @l_src_i int
	DECLARE @l_tgt_i int
	DECLARE @l_prm_i int
	DECLARE @l_src_v nvarchar(100)
	DECLARE @l_tgt_v nvarchar(100)
	--DECLARE @l_src   TP_PARAM_ROW;
	--DECLARE @l_tgt   TP_PARAM_ROW;
	DECLARE @l_found int
	--DECLARE @l_pd    TP_PARAM_DEF;
	DECLARE @l_p_cnt int
	DECLARE @l_v_cnt int
	DECLARE @l_exact int

	--v_rates_out := v_rates_high;
	--l_src_i := v_rates_low.first ();

	DECLARE @tmp_rate_id TABLE
	(
		id_rate int
	)

	INSERT INTO @tmp_rate_id
	SELECT r.id_rate
	FROM   #tmp_schedule_rates r
	WHERE  id_sched_key = @new_id_sched_key

	DECLARE @id_rate_low int
	DECLARE v_rates_low CURSOR FOR
		SELECT r.id_rate
		FROM   @tmp_rate_id r

	OPEN v_rates_low
	FETCH NEXT FROM v_rates_low INTO @id_rate_low

	WHILE @@FETCH_Status = 0
	BEGIN
		--l_src := v_rates_low (l_src_i);
		SET @l_found = 0
		SET @l_exact = 1
		--l_tgt_i := v_rates_high.first ();

		DECLARE @id_rate int
		DECLARE v_rates_high CURSOR FOR
			SELECT r.id_rate
			FROM   #tmp_rates r

		OPEN v_rates_high
		FETCH NEXT FROM v_rates_high INTO @id_rate

		WHILE (@l_found = 0 AND @@FETCH_STATUS = 0)
		BEGIN
			--l_tgt := v_rates_high (l_tgt_i);
			--l_prm_i := v_param_defs.first ();
			SET @l_p_cnt = 0
			SET @l_v_cnt = 0

			DECLARE @id_param_table_prop int
			DECLARE @is_rate_key int
			DECLARE v_param_defs CURSOR FOR
				SELECT id_param_table_prop, is_rate_key
				FROM   #tmp_param_defs
				WHERE  id_pt = @v_id_pt

			OPEN v_param_defs
			FETCH NEXT FROM v_param_defs INTO @id_param_table_prop, @is_rate_key

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				
				IF (@is_rate_key <> 0)
				BEGIN
					SELECT @l_src_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate_low and id_param = @id_param_table_prop
					SELECT @l_src_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate and id_param = @id_param_table_prop
					
					IF (@l_tgt_v IS NULL)
					BEGIN
						SET @l_v_cnt = @l_v_cnt + 1
						IF (@l_src_v IS NOT NULL)
							SET @l_exact = 0
					END
					ELSE
					BEGIN
						IF (@l_src_v IS NOT NULL AND @l_src_v = @l_tgt_v)
						BEGIN
							SET @l_v_cnt = @l_v_cnt + 1
						END
						ELSE
						BEGIN
							SET @l_exact = 0
						END
					END
				END
				
				FETCH NEXT FROM v_param_defs INTO @id_param_table_prop, @is_rate_key
			END

			CLOSE v_param_defs
			DEALLOCATE v_param_defs

			IF (@l_p_cnt = @l_v_cnt)
			BEGIN
				SET @l_found = 1
				IF (@v_update <> 0 AND @l_exact = 1)
				BEGIN
					/* found an exact non-wildcard match, we update those */
					--l_prm_i := v_param_defs.first ();
					DECLARE v_param_defs2 CURSOR FOR
						SELECT id_param_table_prop, is_rate_key
						FROM   #tmp_param_defs
						WHERE  id_pt = @v_id_pt

					OPEN v_param_defs2
					FETCH NEXT FROM v_param_defs2 INTO @id_param_table_prop, @is_rate_key

					WHILE (@@FETCH_STATUS = 0)
					BEGIN
						--l_pd := v_param_defs (l_prm_i);
						IF (@is_rate_key = 0)
						BEGIN
							SELECT @l_src_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate_low and id_param = @id_param_table_prop

							IF (@l_src_v IS NOT NULL)
							BEGIN
								IF (UPPER(@l_src_v) = 'NULL')
								BEGIN
									DELETE #tmp_schedule_rate_params
									WHERE  id_rate = @id_rate AND id_param = @id_param_table_prop
								END
								ELSE
								BEGIN
									UPDATE #tmp_schedule_rate_params
									SET    nm_param = @l_src_v
									WHERE  id_rate = @id_rate AND id_param = @id_param_table_prop
								END
							END
						END
						
						FETCH NEXT FROM v_param_defs2 INTO @id_param_table_prop, @is_rate_key
					END

					CLOSE v_param_defs2
					DEALLOCATE v_param_defs2

					--v_rates_out (l_tgt_i) := l_tgt;
				END
			END
			--l_tgt_i := v_rates_high.next (l_tgt_i);
			FETCH NEXT FROM v_rates_high INTO @id_rate
		END

		CLOSE v_rates_high
		DEALLOCATE v_rates_high

		IF (@l_found = 0)
		BEGIN
			DECLARE @tmp_id_rate int

			INSERT INTO #tmp_schedule_rates
						(id_sched, id_sched_key, id_audit, n_order, updated)
			SELECT NULL, id_sched_key, NULL, n_order, updated
			FROM   #tmp_schedule_rates
			WHERE  id_rate = @id_rate_low

			SELECT @tmp_id_rate = SCOPE_IDENTITY()

			INSERT INTO #tmp_schedule_rate_params
						(id_rate, id_param, nm_param)
			SELECT DISTINCT @tmp_id_rate, par.id_param, par.nm_param
			FROM   #tmp_schedule_rate_params par
			WHERE  id_rate = @id_rate_low
		END
		--l_src_i := v_rates_low.next (l_src_i);
		FETCH NEXT FROM v_rates_low INTO @id_rate_low
	END

	CLOSE v_rates_low
	DEALLOCATE v_rates_low

	-- Generate the output
	EXEC mt_copy_tmp_rates_by_key
		@id_sched_key = @new_id_sched_key,
		@id_sched_out_key = @id_sched_out_key

END
