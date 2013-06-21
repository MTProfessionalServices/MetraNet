
/* for v_merge_rates (0 means null-replacement only, < 0 means add but no merge, > 0 means full merge */
CREATE PROCEDURE mt_resolve_overlaps(
    @v_id_acc int,
    @v_replace_nulls int,
    @v_merge_rates int,
    @v_update int,
	@v_id_pt int,
    --@v_param_defs IN TP_PARAM_DEF_ARRAY,
    --@v_schedules_in IN TP_SCHEDULE_ARRAY,
	@new_id_sched_key uniqueidentifier,
    @new_id_sched int,
	@new_start datetime,
	@new_end datetime
    --@v_schedules_out OUT TP_SCHEDULE_ARRAY
)
AS
BEGIN
    --DECLARE @l_schedule     TP_SCHEDULE;
    --DECLARE @l_schedule_new TP_SCHEDULE := v_schedule_new;
    DECLARE @l_s_start      datetime
    DECLARE @l_s_end        datetime
    DECLARE @l_s_n_start    datetime
    DECLARE @l_s_n_end      datetime
    DECLARE @l_start        datetime
    DECLARE @l_last_new_i   int

	DECLARE @new_chg_dates  int
	
	SELECT @l_s_n_start = CASE WHEN @new_start IS NULL THEN dbo.determine_absolute_dates(@new_start, 4, 0, @v_id_acc, 1) ELSE @new_start END,
		   @l_s_n_end = CASE WHEN @new_end IS NULL THEN dbo.determine_absolute_dates(@new_end, 4, 0, @v_id_acc, 0) ELSE @new_end END

	DECLARE @tmp_schedules TABLE
	(
		id_sched_key uniqueidentifier NOT NULL PRIMARY KEY,
		n_order int not null identity,
		id_sched int,
		tt_start datetime,
		tt_end datetime,
		chg_dates int,
		chg_rates int,
		deleted int
	)
	
	/*INSERT INTO @tmp_schedules
	SELECT * FROM #my_schedule_array*/

	DECLARE v_schedules_in CURSOR LOCAL FOR
		SELECT id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted
		FROM   #my_schedule_array
		ORDER BY n_order
	DECLARE @id_sched int
	DECLARE @tt_start datetime
	DECLARE @tt_end datetime
	DECLARE @chg_dates int
	DECLARE @chg_rates int
	DECLARE @deleted int
	DECLARE @id_sched_key uniqueidentifier

	OPEN v_schedules_in
	FETCH NEXT FROM v_schedules_in INTO @id_sched, @tt_start, @tt_end, @chg_dates, @chg_rates, @deleted

    WHILE @@FETCH_STATUS = 0
    BEGIN
		--print '------tt_start='+cast(@tt_start as nvarchar(100))+', tt_end='+cast(@tt_end as nvarchar(100))
		SELECT @l_s_start = CASE WHEN @tt_start IS NULL THEN dbo.determine_absolute_dates(@tt_start, 4, 0, @v_id_acc, 0) ELSE @tt_start END,
		       @l_s_end = CASE WHEN @tt_end IS NULL THEN dbo.determine_absolute_dates(@tt_end, 4, 0, @v_id_acc, 0) ELSE @tt_end END

		DECLARE @id_sched_key_0 uniqueidentifier
		DECLARE @id_sched_0 int
		DECLARE @tt_start_0 datetime
		DECLARE @tt_end_0 datetime
		DECLARE @chg_dates_0 int
		DECLARE @chg_rates_0 int
		DECLARE @deleted_0 int

		DECLARE @id_sched_key_1 uniqueidentifier
		DECLARE @id_sched_1 int
		DECLARE @tt_start_1 datetime
		DECLARE @tt_end_1 datetime
		DECLARE @chg_dates_1 int
		DECLARE @chg_rates_1 int
		DECLARE @deleted_1 int

		DECLARE @id_sched_key_2 uniqueidentifier
		DECLARE @id_sched_2 int
		DECLARE @tt_start_2 datetime
		DECLARE @tt_end_2 datetime
		DECLARE @chg_dates_2 int
		DECLARE @chg_rates_2 int
		DECLARE @deleted_2 int

		DECLARE @id_sched_key_3 uniqueidentifier
		DECLARE @id_sched_3 int
		DECLARE @tt_start_3 datetime
		DECLARE @tt_end_3 datetime
		DECLARE @chg_dates_3 int
		DECLARE @chg_rates_3 int
		DECLARE @deleted_3 int

		--l_tmp_rates  TP_PARAM_ARRAY;
		IF object_id('tempdb..#tmp_rates') IS NOT NULL
			DROP TABLE #tmp_rates

		CREATE TABLE #tmp_rates /*TP_PARAM_ARRAY*/
		(
			id_rate int NOT NULL PRIMARY KEY,
			id_sched int NULL,
			id_sched_key uniqueidentifier,
			id_audit int,
			n_order int,
			updated int
		)

        IF (@tt_start IS NULL)
			SELECT @l_s_start = dbo.determine_absolute_dates(@tt_start, 4, 0, @v_id_acc, 1)
        ELSE
			SELECT @l_s_start = @tt_start;
        
        IF (@tt_end IS NULL)
			SELECT @l_s_end = dbo.determine_absolute_dates(@tt_end, 4, 0, @v_id_acc, 0)
        ELSE
			SELECT @l_s_end = @tt_end
        
        IF (@v_merge_rates <> 0 AND (@l_s_start > @l_s_n_start AND (@l_start IS NULL OR @l_start <= @l_s_n_start)))
		BEGIN
			/* gap in the existing schedules, where l_schedule_new will fit in */
			IF (@l_s_n_end < @l_s_start)
			BEGIN
				/* l_schedule_new fits into the gap cleanly, so we add it */
				/* v.start -> v.end (new) */
				SELECT @id_sched_0 = NULL
				SELECT @chg_rates_0 = 1
				
				SELECT @tt_start_0 = @new_start
				SELECT @tt_end_0 = @new_end

				SELECT @id_sched_key_0 = NEWID()
				EXEC mt_copy_tmp_rates @new_id_sched, @id_sched_key_0

				SELECT @chg_dates_0 = @new_chg_dates
				
				--print '------INTO tmp_schedules 01'
				INSERT INTO @tmp_schedules-- #my_schedule_array
							(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
					 VALUES (@id_sched_key_0, @id_sched_0, @tt_start_0, @tt_end_0, @chg_dates_0, @chg_rates_0, @deleted_0)
			END
			ELSE
			BEGIN
				/* l_schedule_new overlaps with l_schedule, so we add just the non-overlap to the gap (overlap will be handled by code below) */
				/* v.start -> l.start (new) (v.start := l.start) */
				SELECT @id_sched_0 = NULL
				SELECT @chg_rates_0 = 1

				SELECT @tt_start_0 = @new_start
				SELECT @tt_end_0 = @tt_start

				SELECT @id_sched_key_0 = NEWID()
				EXEC mt_copy_tmp_rates @new_id_sched, @id_sched_key_0

				SELECT @chg_dates_0 = 1
				--print '------INTO tmp_schedules 02'
				INSERT INTO @tmp_schedules --#my_schedule_array
							(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
					 VALUES (@id_sched_key_0, @id_sched_0, @tt_start_0, @tt_end_0, @chg_dates_0, @chg_rates_0, @deleted_0)

				SELECT @new_start = @tt_start
				IF (@new_start IS NULL)
					SELECT @l_s_n_start = dbo.determine_absolute_dates(@new_start, 4, 0, @v_id_acc, 1)
				ELSE
					SELECT @l_s_n_start = @new_start
				
				SELECT @new_chg_dates = 1
			END
        END

		IF (@l_s_n_start < @l_s_end AND @l_s_n_end > @l_s_start)
		BEGIN
			/* this means that l_schedule_new overlaps with l_schedule, so we WILL be merging and/or bisecting */
			IF (@l_s_start < @l_s_n_start)
			BEGIN
				/* l_schedule starts before l_schedule_new */
				IF (@l_s_end <= @l_s_n_end)
				BEGIN
					/* l_schedule starts and ends before l_schedule_new, so we bisect then add l_schedule (with new dates) and then portion of l_schedule_new */
					/* l.start -> v.start (orig) , v.start -> l.end (merged) (v.start := l.end) == bisect with possible leftover */
					SELECT @id_sched_1 = @id_sched
					SELECT @tt_start_1 = @tt_start
					SELECT @tt_end_1 = @new_start

					SELECT @id_sched_key_1 = NEWID()
					EXEC mt_copy_tmp_rates @id_sched, @id_sched_key_1

					SELECT @chg_rates_1 = @chg_rates
					SELECT @chg_dates_1 = 1
				
					--print '------INTO tmp_schedules 03'
					INSERT INTO @tmp_schedules --#my_schedule_array
								(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
						 VALUES (@id_sched_key_1, @id_sched_1, @tt_start_1, @tt_end_1, @chg_dates_1, @chg_rates_1, @deleted_1)

					SELECT @id_sched_2 = NULL
					SELECT @tt_start_2 = @new_start
					SELECT @tt_end_2 = @tt_end

					SELECT @id_sched_key_2 = NEWID()
					EXEC mt_copy_tmp_rates @id_sched, @id_sched_key_2
				
					SELECT @chg_rates_2 = 1
					SELECT @chg_dates_2 = 1

					EXEC mt_replace_nulls @new_id_sched, @id_sched, @v_id_pt --v_param_defs, l_schedule_new.rates, l_schedule.rates, l_tmp_rates
				
					IF (@v_merge_rates > 0)
						EXEC mt_merge_rates @v_update, @v_id_pt, @new_id_sched_key, @id_sched_key_2
						--mt_merge_rates (@v_update, v_param_defs, l_schedule_new.rates, l_tmp_rates, l_schedule_2.rates);
					ELSE
						EXEC mt_copy_tempopary_rates @id_sched_key = @id_sched_key_2
						--l_schedule_2.rates := l_tmp_rates;
				
					--print '------INTO tmp_schedules 04'
					INSERT INTO @tmp_schedules --#my_schedule_array
								(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
						 VALUES (@id_sched_key_2, @id_sched_2, @tt_start_2, @tt_end_2, @chg_dates_2, @chg_rates_2, @deleted_2)

					SELECT @new_start = @tt_end
					IF (@new_start IS NULL)
						SELECT @l_s_n_start = dbo.determine_absolute_dates(@new_start, 4, 0, @v_id_acc, 1)
					ELSE
						SELECT @l_s_n_start = @new_start
				
					SELECT @new_chg_dates = 1
				END
				ELSE
				BEGIN
					/* l_schedule starts before l_schedule_new, and ends after it, so we trisect then add l_schedule (with new dates) then l_schedule_new, then remainder of l_schedule */
					/* l.start -> v.start (orig), v.start -> v.end (merged), v.end -> l.end (orig) == trisect */
					SELECT @id_sched_1 = @id_sched
					SELECT @tt_start_1 = @tt_start
					SELECT @tt_end_1 = @new_start

					SELECT @id_sched_key_1 = NEWID()
					EXEC mt_copy_tmp_rates @id_sched, @id_sched_key_1

					SELECT @chg_rates_1 = @chg_rates
					SELECT @chg_dates_1 = 1
				
					--print '------INTO tmp_schedules 05'
					INSERT INTO @tmp_schedules --#my_schedule_array
								(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
						 VALUES (@id_sched_key_1, @id_sched_1, @tt_start_1, @tt_end_1, @chg_dates_1, @chg_rates_1, @deleted_1)
				
					SELECT @id_sched_2 = NULL
					SELECT @tt_start_2 = @new_start
					SELECT @tt_end_2 = @new_end
					SELECT @chg_rates_2 = 1
					SELECT @chg_dates_2 = @new_chg_dates
					SELECT @id_sched_key_2 = NEWID()
					
					EXEC mt_replace_nulls @new_id_sched, @id_sched, @v_id_pt --v_param_defs, l_schedule_new.rates, l_schedule.rates, l_tmp_rates
				
					--print '------INTO tmp_schedules 06'
					INSERT INTO @tmp_schedules --#my_schedule_array
								(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
						 VALUES (@id_sched_key_2, @id_sched_2, @tt_start_2, @tt_end_2, @chg_dates_2, @chg_rates_2, @deleted_2)

					IF (@v_merge_rates > 0)
						EXEC mt_merge_rates @v_update, @v_id_pt, @new_id_sched_key, @id_sched_key_2
						--mt_merge_rates v_update, v_param_defs, l_schedule_new.rates, l_tmp_rates, l_schedule_2.rates
					ELSE
						EXEC mt_copy_tempopary_rates @id_sched_key = @id_sched_key_2
						--l_schedule_2.rates := l_tmp_rates;
				
					SELECT @id_sched_3 = NULL
					SELECT @tt_start_3 = @new_end
					SELECT @tt_end_3 = @tt_end

					SELECT @id_sched_key_3 = NEWID()
					EXEC mt_copy_tmp_rates @id_sched, @id_sched_key_3
				
					SELECT @chg_rates_3 = 1
					SELECT @chg_dates_3 = 1
				
					--print '------INTO tmp_schedules 07'
					INSERT INTO @tmp_schedules --#my_schedule_array
								(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
						 VALUES (@id_sched_key_3, @id_sched_3, @tt_start_3, @tt_end_3, @chg_dates_3, @chg_rates_3, @deleted_3)
				END
			END
			ELSE
			BEGIN
				/* l_schedule starts after (or same as) l_schedule_new */
				IF (@l_s_end <= @l_s_n_end)
				BEGIN
					/* l_schedule is completely encompassed by l_schedule_new */
					/* l.start -> l.end (merged) (v.start := l.end) == merge with possible leftover */
					SELECT @tt_start_1 = @tt_start
					SELECT @tt_end_1 = @tt_end
					SELECT @id_sched_1 = @id_sched
					SELECT @chg_dates_1 = @chg_dates
					SELECT @chg_rates_1 = 1
					SELECT @id_sched_key_1 = NEWID()
					
					EXEC mt_replace_nulls @new_id_sched, @id_sched, @v_id_pt --v_param_defs, l_schedule_new.rates, l_schedule.rates, l_tmp_rates
				
					--print '------INTO tmp_schedules 08'
					INSERT INTO @tmp_schedules --#my_schedule_array
								(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
						 VALUES (@id_sched_key_1, @id_sched_1, @tt_start_1, @tt_end_1, @chg_dates_1, @chg_rates_1, @deleted_1)
					
					IF (@v_merge_rates > 0)
						EXEC mt_merge_rates @v_update, @v_id_pt, @new_id_sched_key, @id_sched_key_1
						--mt_merge_rates v_update, v_param_defs, l_schedule_new.rates, l_tmp_rates, l_schedule_1.rates
					ELSE
						EXEC mt_copy_tempopary_rates @id_sched_key = @id_sched_key_1
						--l_schedule_1.rates := l_tmp_rates;
				
					SELECT @new_start = @tt_end
					IF (@new_start IS NULL)
					BEGIN
						SELECT @l_s_n_start = dbo.determine_absolute_dates(@new_start, 4, 0, @v_id_acc, 1)
					END
					ELSE
					BEGIN
						SELECT @l_s_n_start = @new_start
					END
				
					SELECT @new_chg_dates = 1
				END
				ELSE
				BEGIN
					IF (@v_merge_rates > 0)
					BEGIN
						/* l_schedule starts after, and ends after l_schedule_new, we bisect, with first portion merged, second portion original */
						/* l.start -> v.end (merged), v.end -> l.end (orig) == bisect */
						SELECT @tt_start_1 = @tt_start
						SELECT @tt_end_1 = @new_end
						SELECT @id_sched_1 = @id_sched
						SELECT @chg_rates_1 = 1
						SELECT @chg_dates_1 = @chg_dates
						SELECT @id_sched_key_1 = NEWID()

						EXEC mt_replace_nulls @new_id_sched, @id_sched, @v_id_pt --v_param_defs, l_schedule_new.rates, l_schedule.rates, l_tmp_rates

						--print '------INTO tmp_schedules 09'
						INSERT INTO @tmp_schedules --#my_schedule_array
									(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
							 VALUES (@id_sched_key_1, @id_sched_1, @tt_start_1, @tt_end_1, @chg_dates_1, @chg_rates_1, @deleted_1)
						
						IF (@v_merge_rates > 0)
							EXEC mt_merge_rates @v_update, @v_id_pt, @new_id_sched_key, @id_sched_key_1
							--mt_merge_rates (v_update, v_param_defs, l_schedule_new.rates, l_tmp_rates, l_schedule_1.rates);
						ELSE
							EXEC mt_copy_tempopary_rates @id_sched_key = @id_sched_key_1
							--l_schedule_1.rates := l_tmp_rates;

						SELECT @tt_start_2 = @new_end
						SELECT @tt_end_2 = @tt_end

						SELECT @id_sched_key_2 = NEWID()
						EXEC mt_copy_tmp_rates @id_sched, @id_sched_key_2
						
						SELECT @id_sched_2 = NULL
						SELECT @chg_rates_2 = 1
						SELECT @chg_dates_2 = 1

						--print '------INTO tmp_schedules 10'
						INSERT INTO @tmp_schedules --#my_schedule_array
									(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
							 VALUES (@id_sched_key_2, @id_sched_2, @tt_start_2, @tt_end_2, @chg_dates_2, @chg_rates_2, @deleted_2)
					END
					ELSE
					BEGIN
						/* no merge, or low-profile public merge, which hides the new row */
						SELECT @id_sched_key = NEWID()
						EXEC mt_copy_tmp_rates @id_sched, @id_sched_key
				
						--print '------INTO tmp_schedules 11'
						INSERT INTO @tmp_schedules --#my_schedule_array
									(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
							 VALUES (@id_sched_key, @id_sched, @tt_start, @tt_end, @chg_dates, @chg_rates, @deleted)
					END
				END
			END
		END
		ELSE
		BEGIN
			/* l_schedule does not overlap with l_schedule_new so we just add l_schedule */
			SELECT @id_sched_key = NEWID()
			EXEC mt_copy_tmp_rates @id_sched, @id_sched_key
				
			--print '------INTO tmp_schedules 12'
			INSERT INTO @tmp_schedules --#my_schedule_array
						(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
				VALUES  (@id_sched_key, @id_sched, @tt_start, @tt_end, @chg_dates, @chg_rates, @deleted)
		END
		
		DROP TABLE #tmp_rates
		SET @l_start = @l_s_end  /* just marking how far we have traversed */
		--select * from @tmp_schedules
		FETCH NEXT FROM v_schedules_in INTO @id_sched, @tt_start, @tt_end, @chg_dates, @chg_rates, @deleted
    END

    IF (@v_merge_rates <> 0)
	BEGIN
		--IF (v_schedules_in IS NULL OR v_schedules_in.COUNT = 0)
		IF NOT EXISTS (SELECT 1 FROM #my_schedule_array)
		BEGIN
			/* if we didnt use v_schedules_new, then add it (e.g., if v_schedules_in was empty) */
			--l_schedule_new.id_sched := NULL;
			
			--v_schedules_out (v_schedules_out.COUNT) := l_schedule_new;
			SET @id_sched_key_0 = NULL

			--print '------INTO tmp_schedules 13'
			INSERT INTO @tmp_schedules
						(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
				VALUES  (@new_id_sched_key, @new_id_sched, @new_start, @new_end, @new_chg_dates, NULL, NULL)

			--select * from @tmp_schedules
		END
		ELSE
		BEGIN
			--print '---14 condition 01'
			IF (@l_start IS NULL OR (@l_start <= @l_s_n_start AND @l_s_n_end > @l_start))
			BEGIN
				--print '---14 condition 02'
				--DECLARE @l_schedule_0 TP_SCHEDULE
				
				/* leftover new schedule starts and ends after end of v_schedules and overlaps with v_start/v_end */
				
				--l_schedule_0.rates := l_schedule_new.rates;
				--v_schedules_out (v_schedules_out.COUNT) := l_schedule_0;
				SET @id_sched_key_0 = NEWID()
				EXEC mt_copy_tmp_rates_by_key
					@id_sched_key = @new_id_sched_key,
					@id_sched_out_key = @id_sched_key_0

			--print '------INTO tmp_schedules 14'
				INSERT INTO @tmp_schedules
							(id_sched_key, id_sched, tt_start, tt_end, chg_dates, chg_rates, deleted)
					VALUES  (@id_sched_key_0, NULL, @new_start, @new_end, @new_chg_dates, 1, NULL)
			END
		END
    END

	DELETE from #my_schedule_array

	INSERT INTO #my_schedule_array
	SELECT * FROM @tmp_schedules ts

END
