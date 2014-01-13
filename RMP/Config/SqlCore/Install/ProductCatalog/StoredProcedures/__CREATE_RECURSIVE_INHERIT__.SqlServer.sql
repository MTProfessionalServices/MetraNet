
CREATE PROCEDURE recursive_inherit(
    @v_id_audit int,
    @my_id_acc int,
    @v_id_sub int,
    @v_id_po int,
    @v_id_pi_template int,
    @my_id_sched int,
    @my_id_pt int,
    @pass_to_children int,
    @v_id_csr int = 129
    --@cached_param_defs TP_PARAM_TABLE_DEF_ARRAY INPUT OUT
)
AS
BEGIN
	SET NOCOUNT ON

    DECLARE @my_rsched_start datetime
    DECLARE @my_rsched_end datetime
    DECLARE @my_id_sub_curs cursor
    DECLARE @my_id_sched_curs cursor
    DECLARE @my_id_gsub_curs cursor
    DECLARE @my_parent_sub_start datetime
    DECLARE @my_parent_sub_end datetime
    DECLARE @my_parent_id_sub int
    DECLARE @my_parent_sched_start datetime
    DECLARE @my_parent_sched_end datetime
    DECLARE @my_parent_id_sched int
    --DECLARE @my_param_def_array TP_PARAM_TABLE_DEF;
    --DECLARE @my_schedule_array TP_SCHEDULE_ARRAY;
    --DECLARE @my_empty_schedule_array TP_SCHEDULE_ARRAY;
    --DECLARE @my_empty_param_assoc_array TP_PARAM_ASSOC;
    --DECLARE @my_schedule TP_SCHEDULE;
    DECLARE @my_child_id_acc int
    DECLARE @my_child_id_sub int
    DECLARE @my_child_sched_start datetime
    DECLARE @my_child_sched_end datetime
    DECLARE @my_child_id_sched int
    DECLARE @my_id_pricelist int
    DECLARE @my_id_pi_template int
    DECLARE @my_id_sub int
    DECLARE @my_id_po int
    DECLARE @l_id_sched     int
    DECLARE @l_cnt int

	IF object_id('tempdb..#my_schedule_array') IS NOT NULL
		DROP TABLE #my_schedule_array
	IF object_id('tempdb..#tmp_schedule_rates') IS NOT NULL
		DROP TABLE #tmp_schedule_rates
	IF object_id('tempdb..#tmp_schedule_rate_params') IS NOT NULL
		DROP TABLE #tmp_schedule_rate_params

	CREATE TABLE #my_schedule_array /*TP_SCHEDULE_ARRAY*/
	(
		id_sched_key uniqueidentifier NOT NULL PRIMARY KEY,
		n_order int,
		id_sched int,
		tt_start datetime,
		tt_end datetime,
		chg_dates int,
		chg_rates int,
		deleted int
	)

	CREATE TABLE #tmp_schedule_rates /*TP_PARAM_ARRAY*/
	(
		id_rate int NOT NULL IDENTITY PRIMARY KEY,
		id_sched int NULL,
		id_sched_key uniqueidentifier,
		id_audit int,
		n_order int,
		updated int
	)

	CREATE INDEX #tmp_schedule_rates_idx_1 ON #tmp_schedule_rates(id_sched)
	CREATE INDEX #tmp_schedule_rates_idx_2 ON #tmp_schedule_rates(id_sched_key)

	CREATE TABLE #tmp_schedule_rate_params /*TP_PARAM_ASSOC*/
	(
		id_rate int NOT NULL,
		id_param int,
		nm_param nvarchar(100)
	)
	
	CREATE INDEX #tmp_schedule_rate_params_idx1 ON #tmp_schedule_rate_params(id_rate)
	CREATE INDEX #tmp_schedule_rate_params_idx2 ON #tmp_schedule_rate_params(id_param)

    SET @my_id_sub = @v_id_sub
    SET @my_id_po = @v_id_po

	DECLARE @mindate datetime
	DECLARE @maxdate datetime
	SET @mindate = dbo.mtmindate()
	SET @maxdate = dbo.mtmaxdate()

    IF (@my_id_sched IS NOT NULL)
	BEGIN
        SELECT @my_rsched_start = dbo.determine_absolute_dates(ed.dt_start, ed.n_begintype, ed.n_beginoffset, @my_id_acc, 1),
               @my_rsched_end = dbo.determine_absolute_dates(ed.dt_end, ed.n_endtype, ed.n_endoffset, @my_id_acc, 0),
               @my_id_pricelist = r.id_pricelist,
			   @my_id_pi_template = r.id_pi_template
        FROM   t_rsched r
		       JOIN t_effectivedate ed ON r.id_eff_date = ed.id_eff_date
        WHERE  r.id_sched = @my_id_sched
            
        IF (@my_id_sub IS NULL or @my_id_po IS NULL)
		BEGIN
            SELECT @my_id_sub = MIN(id_sub), @my_id_po = MIN(id_po)
			FROM   t_pl_map pm, t_rsched rs
            WHERE  rs.id_sched = @my_id_sched
                AND rs.id_pricelist = pm.id_pricelist
                AND rs.id_pi_template = pm.id_pi_template
                AND pm.id_paramtable = @my_id_pt
                AND rs.id_pt = pm.id_paramtable
                AND id_sub IS NOT NULL;
        END
	END
    ELSE
	BEGIN

        /* FIXME: derive id_pricelist and id_pi_template */
        SELECT @my_rsched_start = vt_start, @my_rsched_end = ISNULL(vt_end, dbo.mtmaxdate())
		FROM   t_sub
		WHERE  id_sub = @my_id_sub

        IF (@v_id_pi_template IS NULL)
            EXEC get_id_pi_template @my_id_sub, @my_id_pt, @my_id_pi_template OUT
        ELSE
            SET @my_id_pi_template = @v_id_pi_template
        
        EXEC get_id_pl_by_pt @my_id_acc, @my_id_sub, @my_id_pt, @my_id_pi_template, @my_id_pricelist OUT
    END

    EXEC mt_load_param_table_def @my_id_pt
	
    /* loop over all private scheds ORDER BY n_begin_type ASC, determine_absolute_dates(dt_start) */
    EXEC get_id_sched @my_id_sub, @my_id_pt, @my_id_pi_template, @mindate, @maxdate, @my_id_sched_curs OUT

	FETCH @my_id_sched_curs INTO @l_id_sched, @my_rsched_start, @my_rsched_end

    WHILE @@FETCH_STATUS = 0
	BEGIN
        EXEC mt_resolve_overlaps_by_sched --@my_id_acc, my_rsched_start, my_rsched_end, 1, -1, 0, @my_param_def_array, my_schedule_array, l_id_sched, my_schedule_array);
			@v_id_acc = @my_id_acc,
			@v_start = @my_rsched_start,
			@v_end = @my_rsched_end,
			@v_replace_nulls = 1,
			@v_merge_rates = -1 ,
			--@v_reuse_sched int,
			@v_id_pt = @my_id_pt,
			--@v_pt IN TP_PARAM_TABLE_DEF,
			--@v_schedules_in IN TP_SCHEDULE_ARRAY,
			@v_id_sched = @my_id_sched
		FETCH @my_id_sched_curs INTO @l_id_sched, @my_rsched_start, @my_rsched_end
    END
    CLOSE @my_id_sched_curs
	DEALLOCATE @my_id_sched_curs

    SET @my_rsched_start = dbo.mtmindate()
    SET @my_rsched_end = dbo.mtmaxdate()

    EXEC get_inherit_id_sub @my_id_acc, @my_id_po, @my_rsched_start, @my_rsched_end, @my_id_sub_curs OUT
	
	FETCH NEXT FROM @my_id_sub_curs INTO @my_parent_id_sub, @my_parent_sub_start, @my_parent_sub_end

    WHILE @@FETCH_STATUS = 0
	BEGIN
        IF (@my_parent_sub_start < @my_rsched_start)
            SET @my_parent_sub_start = @my_rsched_start
        
        IF (@my_parent_sub_end > @my_rsched_end)
            SET @my_parent_sub_end = @my_rsched_end
        
        EXEC get_id_sched_pub @my_parent_id_sub, @my_id_pt, @my_id_pi_template, @my_parent_sub_start, @my_parent_sub_end, @my_id_sched_curs OUT
		FETCH NEXT FROM @my_id_sched_curs INTO @my_parent_id_sched, @my_parent_sched_start, @my_parent_sched_end

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF (@my_parent_sched_start < @my_parent_sub_start)
                SET @my_parent_sched_start = @my_parent_sub_start
            
            IF (@my_parent_sched_end < @my_parent_sub_end)
                SET @my_parent_sched_end = @my_parent_sub_end
            
            EXEC mt_resolve_overlaps_by_sched --(my_id_acc, my_parent_sched_start, my_parent_sched_end, 1, 1, 0, @my_param_def_array, my_schedule_array, my_parent_id_sched, my_schedule_array);
				@v_id_acc = @my_id_acc,
				@v_start = @my_parent_sched_start,
				@v_end = @my_parent_sched_end,
				@v_replace_nulls = 1,
				@v_merge_rates =1 ,
				--@v_reuse_sched int,
				@v_id_pt = @my_id_pt,
				--@v_pt IN TP_PARAM_TABLE_DEF,
				--@v_schedules_in IN TP_SCHEDULE_ARRAY,
				@v_id_sched = @my_parent_id_sched
			
			FETCH NEXT FROM @my_id_sched_curs INTO @my_parent_id_sched, @my_parent_sched_start, @my_parent_sched_end
        END

		CLOSE @my_id_sched_curs
		DEALLOCATE @my_id_sched_curs

		FETCH NEXT FROM @my_id_sub_curs INTO @my_parent_id_sub, @my_parent_sub_start, @my_parent_sub_end
    END
    CLOSE @my_id_sub_curs
	DEALLOCATE @my_id_sub_curs

    EXEC templt_write_schedules --@my_id_acc, my_id_sub, v_id_audit, 1, my_id_pricelist, my_id_pi_template, @my_param_def_array, my_schedule_array, v_id_csr);
		@my_id_acc = @my_id_acc,
		@my_id_sub = @my_id_sub,
		@v_id_audit = @v_id_audit,
		@is_public = 1,
		@v_id_pricelist = @my_id_pricelist,
		@v_id_pi_template = @my_id_pi_template,
		--@v_param_table_def IN TP_PARAM_TABLE_DEF,
		@v_id_pt = @my_id_pt,
		--@v_schedules IN OUT TP_SCHEDULE_ARRAY,
		@v_id_csr = @v_id_csr

    IF (@pass_to_children = 1)
	BEGIN
        EXEC get_child_gsubs_private @my_id_acc, @my_id_po, @my_rsched_start, @my_rsched_end, @my_id_gsub_curs OUT

		FETCH NEXT FROM @my_id_gsub_curs INTO @my_child_id_acc, @my_child_id_sub

        WHILE @@FETCH_STATUS = 0
		BEGIN
            SET @l_cnt = 0
            EXEC get_id_sched @my_child_id_sub, @my_id_pt, @my_id_pi_template, @my_rsched_start, @my_rsched_end, @my_id_sched_curs OUT
			
			FETCH NEXT FROM @my_id_sched_curs INTO @my_child_id_sched, @my_child_sched_start, @my_child_sched_end

            WHILE @@FETCH_STATUS = 0
			BEGIN
                SET @l_cnt = @l_cnt + 1
                EXEC recursive_inherit --(v_id_audit, my_child_id_acc, my_child_id_sub, my_id_po, my_id_pi_template, my_child_id_sched, my_id_pt, 0, cached_param_defs, v_id_csr);
				    @v_id_audit = @v_id_audit,
					@my_id_acc = @my_child_id_acc,
					@v_id_sub = @my_child_id_sub,
					@v_id_po = @my_id_po,
					@v_id_pi_template = @my_id_pi_template,
					@my_id_sched = @my_child_id_sched,
					@my_id_pt = @my_id_pt,
					@pass_to_children = 0,
					@v_id_csr = @v_id_csr

				FETCH NEXT FROM @my_id_sched_curs INTO @my_child_id_sched, @my_child_sched_start, @my_child_sched_end
            END

			CLOSE @my_id_sched_curs
			DEALLOCATE @my_id_sched_curs

            IF @l_cnt = 0
                EXEC recursive_inherit --(v_id_audit, my_child_id_acc, my_child_id_sub, my_id_po, my_id_pi_template, NULL, my_id_pt, 0, cached_param_defs, v_id_csr);
				    @v_id_audit = @v_id_audit,
					@my_id_acc = @my_child_id_acc,
					@v_id_sub = @my_child_id_sub,
					@v_id_po = @my_id_po,
					@v_id_pi_template = @my_id_pi_template,
					@my_id_sched = NULL,
					@my_id_pt = @my_id_pt,
					@pass_to_children = 0,
					@v_id_csr = @v_id_csr
            
			FETCH NEXT FROM @my_id_gsub_curs INTO @my_child_id_acc, @my_child_id_sub
        END

        CLOSE @my_id_gsub_curs
		DEALLOCATE @my_id_gsub_curs
    END

	DROP TABLE #tmp_schedule_rate_params
	DROP TABLE #tmp_schedule_rates
	DROP TABLE #my_schedule_array
END
