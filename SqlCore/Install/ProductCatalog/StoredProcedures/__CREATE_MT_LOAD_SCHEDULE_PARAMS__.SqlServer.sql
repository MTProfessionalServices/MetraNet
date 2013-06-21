
CREATE PROCEDURE mt_load_schedule_params(
	@v_id_sched int,
	@v_is_wildcard int,
	@v_id_pt int,
	@new_id_sched_key uniqueidentifier,
	@new_id_sched int OUT
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @l_sql        nvarchar(4000)
	--DECLARE @l_cursor     CURSOR
	DECLARE @l_first      int
	DECLARE @l_value      nvarchar(100)
	DECLARE @l_row        int
	DECLARE @l_id_param   int
	DECLARE @is_rate_key  int
	DECLARE @l_param_name nvarchar(100)
	DECLARE @l_id_sched   int
	DECLARE @l_id_audit   int
	DECLARE @l_n_order    int
	DECLARE @l_start      datetime
	DECLARE @l_end        datetime
	DECLARE @l_current    int
	DECLARE @l_id         int

	SET @l_first = 1
	SELECT @l_sql = N'INSERT INTO #tmp_cursor SELECT /*+ INDEX(A END_' + SUBSTRING(pd.nm_pt, 0, 19) + N'_IDX) */ id_sched, id_audit, n_order, tt_start, tt_end, id_param_table_prop p_id, CASE id_param_table_prop'
	FROM   #tmp_cached_param_defs pd
	WHERE  pd.id_pt = @v_id_pt

	SELECT @l_sql = @l_sql + ' WHEN ' + CAST(pd.id_param_table_prop AS nvarchar(10)) + N' THEN CAST(' + pd.nm_column_name + ' AS nvarchar)'
	FROM   #tmp_param_defs pd
	WHERE  pd.id_pt = @v_id_pt
	ORDER BY id_param_defs

	SELECT @l_sql = @l_sql + N' ELSE NULL END p_val FROM ' + pd.nm_pt +
		   N' A, T_PARAM_TABLE_PROP B WHERE id_sched = ' + CAST(@v_id_sched AS nvarchar(10)) +
		   N' AND tt_end = @maxdate AND id_param_table = ' + CAST(@v_id_pt AS nvarchar)
	FROM   #tmp_cached_param_defs pd
	WHERE  pd.id_pt = @v_id_pt

	IF EXISTS (SELECT 1 FROM #tmp_filter_vals)
	BEGIN
		DECLARE param_defs CURSOR FOR
			SELECT pd.id_param_table_prop, pd.nm_column_name, pd.is_rate_key
			FROM   #tmp_param_defs pd
			WHERE  pd.id_pt = @v_id_pt
			ORDER BY id_param_defs

		OPEN param_defs
		FETCH NEXT FROM param_defs INTO @l_id_param, @l_param_name, @is_rate_key
		WHILE @@FETCH_STATUS = 0
		BEGIN
			/* add in filtering */
			IF (@l_id_param IS NOT NULL)
			BEGIN
				IF (@is_rate_key <> 0)
				BEGIN
					SELECT @l_value = MAX(nm_val) FROM #tmp_filter_vals WHERE id_param_table_prop = @l_id_param

					IF @l_value IS NULL
					BEGIN
						IF (@v_is_wildcard = 0)
							SET @l_sql = @l_sql + N' AND ' + @l_param_name + N' IS NULL'
					END
					ELSE
						SET @l_sql = @l_sql + N' AND ' + @l_param_name + N' = ''' + @l_value + '''';
				END
			END
			FETCH NEXT FROM param_defs INTO @l_id_param, @l_value, @is_rate_key
		END

		CLOSE param_defs
		DEALLOCATE param_defs
	END
	
	IF object_id('tempdb..#tmp_cursor') IS NOT NULL
		DROP TABLE #tmp_cursor

	CREATE TABLE #tmp_cursor
	(
		id_sched int,
		id_audit int,
		n_order int,
		dt_start datetime,
		dt_end datetime,
		id_param int,
		value nvarchar(100)
	)

	SELECT @l_sql = N'DECLARE @maxdate datetime; SET @maxdate = dbo.mtmaxdate(); ' + @l_sql + N' '
	EXEC sp_executesql @l_sql

	DECLARE l_cursor CURSOR FOR
		SELECT id_sched, id_audit, n_order, dt_start, dt_end, id_param, value
		FROM   #tmp_cursor
		ORDER BY n_order ASC

	OPEN l_cursor
	FETCH NEXT FROM l_cursor INTO @l_id_sched, @l_id_audit, @l_n_order, @l_start, @l_end, @l_id_param, @l_value

	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF (@l_id_param IS NOT NULL)
		BEGIN
			IF (@l_current IS NULL OR @l_current <> @l_n_order)
			BEGIN
				SET @l_current = @l_n_order
				INSERT INTO #tmp_schedule_rates
							(id_sched_key, id_sched, id_audit, n_order, updated)
					 VALUES (@new_id_sched_key, @l_id_sched, @l_id_audit, @l_n_order, 0)
				SET @l_id = SCOPE_IDENTITY()
				SET @new_id_sched  = @l_id_sched
			END
			
			IF @l_value IS NOT NULL
				INSERT INTO #tmp_schedule_rate_params
							(id_rate, id_param, nm_param)
						VALUES (@l_id, @l_id_param, @l_value)
		END

		FETCH NEXT FROM l_cursor INTO @l_id_sched, @l_id_audit, @l_n_order, @l_start, @l_end, @l_id_param, @l_value
	END
	CLOSE l_cursor
	DEALLOCATE l_cursor

	DROP TABLE #tmp_cursor
END
