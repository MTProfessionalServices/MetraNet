
CREATE PROCEDURE recursive_inherit_sub(
	@v_id_audit int,
	@v_id_acc int,
	@v_id_sub int,
	@v_id_group int
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @my_id_sub int
	DECLARE @my_id_audit int
	DECLARE @my_id_po int
	DECLARE @my_id_pt int
	DECLARE @my_id_pt_curs CURSOR
	DECLARE @my_id_sched_curs CURSOR
	DECLARE @my_child_id_sched int
	DECLARE @my_child_sched_start datetime
	DECLARE @my_child_sched_end datetime
	DECLARE @my_counter int
	DECLARE @my_id_pi_template int
	DECLARE @audit_msg nvarchar(255)

	IF object_id('tempdb..#tmp_cached_param_defs') IS NOT NULL
		DROP TABLE #tmp_cached_param_defs
	IF object_id('tempdb..#tmp_param_defs') IS NOT NULL
		DROP TABLE #tmp_param_defs
	IF object_id('tempdb..#tmp_filter_vals') IS NOT NULL
		DROP TABLE #tmp_filter_vals
	
	CREATE TABLE #tmp_cached_param_defs
	(
		id_pt int NOT NULL PRIMARY KEY,
		nm_pt nvarchar(100)
	)

	CREATE TABLE #tmp_param_defs
	(
		id_param_defs int NOT NULL IDENTITY PRIMARY KEY,
		id_pt int not null,
		nm_column_name nvarchar(255),
        is_rate_key int,
        id_param_table_prop int
	)

	CREATE INDEX #tmp_param_defs_idx ON #tmp_param_defs (id_pt)

	CREATE TABLE #tmp_filter_vals
	(
		id_param_table_prop int NOT NULL PRIMARY KEY,
		nm_val  nvarchar(100)
	)

	SELECT @my_id_sub = @v_id_sub
	IF @my_id_sub IS NULL
		SELECT @my_id_sub = MAX(id_sub) FROM t_sub WHERE id_group = @v_id_group

	SELECT @my_id_po = MIN(id_po) FROM t_sub WHERE id_sub = @my_id_sub

	SELECT @my_id_audit = @v_id_audit --ISNULL(@v_id_audit, current_id_audit)
	IF @my_id_audit IS NULL
	BEGIN
		EXEC getcurrentid 'id_audit', @my_id_audit OUT
		SET @audit_msg = N'Creating public rate for account ' + CAST(@v_id_acc AS nvarchar(10)) + N' subscription ' + CAST(@my_id_sub AS nvarchar(10))
		DECLARE @curr_date datetime
		SET @curr_date = GETDATE()
		EXEC insertauditevent
			@id_userid           = NULL,
			@id_event            = 1451,
			@id_entity_type      = 2,
			@id_entity           = @my_id_sub,
			@dt_timestamp        = @curr_date,
			@id_audit            = @my_id_audit,
			@tx_details          = @audit_msg,
			@tx_logged_in_as     = NULL,
			@tx_application_name = NULL
	END

	DECLARE @mindate datetime
	DECLARE @maxdate datetime
	SET @mindate = dbo.mtmindate()
	SET @maxdate = dbo.mtmaxdate()

	EXEC get_all_pts_by_sub @my_id_sub, @my_id_pt_curs OUT

	FETCH @my_id_pt_curs INTO @my_id_pt, @my_id_pi_template
    
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @my_counter = 0
		EXEC get_id_sched @my_id_sub, @my_id_pt, @my_id_pi_template, @mindate, @maxdate, @my_id_sched_curs OUT
		
		FETCH @my_id_sched_curs INTO @my_child_id_sched, @my_child_sched_start, @my_child_sched_end
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @my_counter = @my_counter + 1
			EXEC recursive_inherit @my_id_audit, @v_id_acc, @my_id_sub, @my_id_po, @my_id_pi_template, @my_child_id_sched, @my_id_pt, 1
			FETCH @my_id_sched_curs INTO @my_child_id_sched, @my_child_sched_start, @my_child_sched_end
		END
		
		CLOSE @my_id_sched_curs
		DEALLOCATE @my_id_sched_curs

		IF @my_counter = 0
			EXEC recursive_inherit @my_id_audit, @v_id_acc, @my_id_sub, @my_id_po, @my_id_pi_template, NULL, @my_id_pt, 1

		FETCH @my_id_pt_curs INTO @my_id_pt, @my_id_pi_template
	END

	CLOSE @my_id_pt_curs
	DEALLOCATE @my_id_pt_curs

	DROP TABLE #tmp_filter_vals
	DROP TABLE #tmp_param_defs
	DROP TABLE #tmp_cached_param_defs
END