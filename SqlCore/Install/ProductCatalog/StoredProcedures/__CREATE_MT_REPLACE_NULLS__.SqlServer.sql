
/* replaces NULLs in ICB schedules with real values from hierarchy rows... */
CREATE PROCEDURE mt_replace_nulls(
	@new_id_sched int,
	@id_sched int,
	@v_id_pt int
)
AS
BEGIN
	SET NOCOUNT ON

    DECLARE @l_src_i  int
    DECLARE @l_tgt_i  int
    DECLARE @l_prm_i  int
    DECLARE @l_src_v  nvarchar(100)
    DECLARE @l_tgt_v  nvarchar(100)
    DECLARE @l_p_cnt  int
    DECLARE @l_v_cnt  int
    DECLARE @l_isnull int

	SET @l_isnull = 1


	DECLARE @id_rate int
	DECLARE v_rates_high CURSOR FOR
		SELECT r.id_rate
		FROM   #tmp_schedule_rates r
		WHERE  id_sched = @id_sched
    
	OPEN v_rates_high
	FETCH NEXT FROM v_rates_high INTO @id_rate

	WHILE @@FETCH_STATUS = 0
    BEGIN
		DECLARE @id_param_table_prop int
		DECLARE @is_rate_key int
		DECLARE v_param_defs CURSOR FOR
			SELECT id_param_table_prop, is_rate_key
			FROM   #tmp_param_defs
			WHERE  id_pt = @v_id_pt

		OPEN v_param_defs
		FETCH NEXT FROM v_param_defs INTO @id_param_table_prop, @is_rate_key

		SET @l_isnull = 0
		
		WHILE @@FETCH_STATUS = 0 /* see if we have any nulls first */
		BEGIN
			SELECT @l_src_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate and id_param = @id_param_table_prop
			
			IF (@is_rate_key = 0 AND @l_src_v IS NULL)
				SET @l_isnull = @l_isnull + 1

			FETCH NEXT FROM v_param_defs INTO @id_param_table_prop, @is_rate_key
		END

		CLOSE v_param_defs
		DEALLOCATE v_param_defs

		DECLARE @id_rate_low int
		IF (@l_isnull <> 0)
		BEGIN
			DECLARE v_rates_low CURSOR FOR
				SELECT r.id_rate
				FROM   #tmp_schedule_rates r
				WHERE  id_sched = @new_id_sched

			OPEN v_rates_low
			FETCH NEXT FROM v_rates_low INTO @id_rate_low

			WHILE (@l_isnull <> 0 AND @@FETCH_STATUS = 0)
			BEGIN
				DECLARE v_param_defs2 CURSOR FOR
					SELECT id_param_table_prop, is_rate_key
					FROM   #tmp_param_defs
					WHERE  id_pt = @v_id_pt

				OPEN v_param_defs2
				FETCH NEXT FROM v_param_defs2 INTO @id_param_table_prop, @is_rate_key

				SET @l_p_cnt = 0
				SET @l_v_cnt = 0
				WHILE (@@FETCH_STATUS = 0)  /* see if our keys match (always wildcard) */
				BEGIN
					SELECT @l_src_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate and id_param = @id_param_table_prop
					SELECT @l_tgt_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate_low and id_param = @id_param_table_prop

					IF (@is_rate_key <> 0)
					BEGIN
						SET @l_p_cnt = @l_p_cnt + 1
						IF (@l_src_v IS NULL)
							SET @l_v_cnt = @l_v_cnt + 1
						ELSE IF (@l_tgt_v IS NOT NULL AND @l_src_v = @l_tgt_v)
							SET @l_v_cnt = @l_v_cnt + 1
					END
					
					FETCH NEXT FROM v_param_defs2 INTO @id_param_table_prop, @is_rate_key
				END

				CLOSE v_param_defs2
				DEALLOCATE v_param_defs2

				IF (@l_p_cnt = @l_v_cnt AND @l_isnull <> 0)
				BEGIN
					UPDATE #tmp_schedule_rates
					SET    updated = 1
					WHERE  id_rate = @id_rate_low

					DECLARE v_param_defs3 CURSOR FOR
						SELECT id_param_table_prop, is_rate_key
						FROM   #tmp_param_defs
						WHERE  id_pt = @v_id_pt

					OPEN v_param_defs3
					FETCH NEXT FROM v_param_defs3 INTO @id_param_table_prop, @is_rate_key

					/* replace nulls */
					WHILE (@l_isnull <> 0 AND @@FETCH_STATUS = 0)
					BEGIN
						IF (@is_rate_key = 0)
						BEGIN
							SELECT @l_src_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate and id_param = @id_param_table_prop
							SELECT @l_tgt_v = MAX(nm_param) FROM #tmp_schedule_rate_params WHERE id_rate = @id_rate_low and id_param = @id_param_table_prop
							
							IF (@l_src_v IS NULL AND @l_tgt_v IS NOT NULL)
							BEGIN
								UPDATE #tmp_schedule_rate_params
								SET    nm_param = @l_tgt_v
								WHERE id_rate = @id_rate AND id_param = @id_param_table_prop
								SET @l_isnull = @l_isnull - 1
							END
						END
						
						FETCH NEXT FROM v_param_defs3 INTO @id_param_table_prop, @is_rate_key
					END
				END

				FETCH NEXT FROM v_rates_low INTO @id_rate_low
			END
		END
		
		INSERT INTO #tmp_rates
					(id_rate, id_sched, id_sched_key, id_audit, n_order, updated)
		SELECT id_rate, id_sched, id_sched_key, id_audit, n_order, updated
		FROM   #tmp_schedule_rates
		WHERE  id_rate = @id_rate

		FETCH NEXT FROM v_rates_high INTO @id_rate
    END

	CLOSE v_rates_high
	DEALLOCATE v_rates_high
END
