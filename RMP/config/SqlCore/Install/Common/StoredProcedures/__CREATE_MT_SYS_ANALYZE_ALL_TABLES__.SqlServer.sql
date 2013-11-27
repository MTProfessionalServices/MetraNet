CREATE PROCEDURE MT_sys_analyze_all_tables 
(
    @U_float_sample_percent FLOAT = NULL,
    @NU_float_sample_percent FLOAT = NULL,
    @include_table_name  NVARCHAR(MAX) = NULL,
    @exclude_table_name  NVARCHAR(MAX) = NULL,
    @only_indexes        NVARCHAR(10) = 'ALL'
)
AS
SET NOCOUNT ON

BEGIN TRY
	
	/********************************************************************
	** Procedure Name:  MT_sys_analyze_all_tables
	** Procedure Description: Analyze all the user defined tables
	** 
	** Execute SP without specification sample rate to let SQL server calculate default SAMPLE rates:
	** exec MT_sys_analyze_all_tables
	** (recommended)
	** 
	** To set specific percent for Usage, Non-usage or both table groups:
	** exec MT_sys_analyze_all_tables @U_float_sample_percent = 0.001, @NU_float_sample_percent = 20.0
	** Note:
	** this option is relevant only if all tables in specified group (U or NU) contains approximately the same ammount of data.
	** Otherwise - execute SP parameterless 
	** 
	** Parameters:
			@U_float_sample_percent is a FLOAT usage sampling ratio,
			@NU_float_sample_percent is a FLOAT non-usage sampling ratio,
			@include_table_name is a comma-separated list of one or more tables to be included in the analysis.
			@exclude_table_name is a comma-separated list of one or more tables to be excluded in the analysis
			@only_indexes can be ALL, meaning all index and column-level statistics will be analyzed, or INDEX, meaning only indexes will be analyzed
	**
	** Returns: 0 IF successful
	**          1 IF fatal error occurred
	**
	** NOTES: 
	*********************************************************************************/
	
	DECLARE @table_name               VARCHAR(128),
	        @SQLStmtError             INT,
	        @ErrorMessage             NVARCHAR(MAX),
	        @ErrorSeverity            INT,
	        @ErrorState               INT,
	        @SqlStmt                  NVARCHAR(MAX),
	        @SqlViewStmtPattern       VARCHAR(MAX),
	        @SqlNonUsageStmtPattern   VARCHAR(MAX),
	        @SqlUsageStmtPattern      VARCHAR(MAX),
	        --DECLARE @SqlMeterStmtPattern VARCHAR(MAX)
	        @IncludeTables            VARCHAR(MAX),
	        @ExcludeTables            VARCHAR(MAX),
	        @start_time_update_stats  DATETIME,
	        @total_duration_sec       INT
	
	IF @U_float_sample_percent < 0 OR @U_float_sample_percent > 100
	   RAISERROR ('@U_float_sample_percent should be between 0 and 100.', 16, 1)
	   
	IF @NU_float_sample_percent < 0 OR @NU_float_sample_percent > 100
	   RAISERROR ('@NU_float_sample_percent should be between 0 and 100.', 16, 1)
	
	IF @only_indexes  NOT IN ( 'ALL', 'COLUMNS', 'INDEX')
		RAISERROR ('@@only_indexes may take 3 values: ''ALL'', ''COLUMNS'', ''INDEX''', 16, 1)
	
	CREATE TABLE #StatisticsHeader
	(
		 Name                   sysname,
		 Updated                datetime,
		 [Rows]                 bigint,
		 RowsSampled            bigint,
		 Steps                  tinyint,
		 Density                decimal(9,5),
		 AverageKeyLength       decimal(9,5),
		 StringIndex            nchar(3),
		 FilterExpression       nvarchar(1000),
		 UnfilteredRows         bigint
	)
	
	--Indexed Views
	SET @SqlViewStmtPattern = 'DECLARE curUserObjs CURSOR FOR
	SELECT DISTINCT obj.name FROM sysindexkeys keys 
	INNER JOIN sysobjects obj ON keys.id=obj.id
	WHERE XTYPE=''v'' {%0}'
	 
	--Non-Usage tables in NetMeter Database
	SET @SqlNonUsageStmtPattern = 'DECLARE curUserObjs CURSOR FOR
	SELECT TABLE_NAME FROM information_schema.tables
	WHERE TABLE_TYPE = ''BASE TABLE''
	AND TABLE_SCHEMA = ''dbo''
	AND TABLE_NAME NOT LIKE ''t_acc_usage''
	AND TABLE_NAME NOT LIKE ''t_pv%''
	AND TABLE_NAME NOT LIKE ''t_uk_%''
	AND TABLE_NAME NOT LIKE ''t_svc%''
	AND table_name NOT LIKE ''amplu_%'' 
	AND table_name NOT LIKE ''ampbi_%'' 
	AND table_name NOT IN (''t_session'',''t_session_state'',''t_session_set'',''t_message'', ''change_tables'', ''ddl_history'', ''lsn_time_mapping'', ''captured_columns'', ''index_columns'') {%0}
	ORDER BY TABLE_NAME'

	--Usage tables in Partition NetMeter Database		
	SET @SqlUsageStmtPattern = 'DECLARE curUserObjs CURSOR FOR
	SELECT TABLE_NAME FROM information_schema.tables
	WHERE TABLE_TYPE = ''BASE TABLE''
	AND TABLE_SCHEMA = ''dbo''
	AND (TABLE_NAME LIKE ''t_acc_usage'' 
	OR TABLE_NAME LIKE ''t_pv%''
	OR TABLE_NAME LIKE ''t_uk_%'') {%0}
	ORDER BY TABLE_NAME'

	/* 
	--Meter tables in Partition NetMeter Database		
	SET @SqlMeterStmtPattern = 'DECLARE curUserObjs CURSOR FOR
	SELECT TABLE_NAME FROM information_schema.tables
	WHERE TABLE_TYPE = ''BASE TABLE''
	AND TABLE_SCHEMA = ''dbo''
	AND (TABLE_NAME IN (''t_session'',''t_session_state'',''t_session_set'',''t_message'') 
	OR TABLE_NAME LIKE ''t_svc%'') {%0}
	ORDER BY TABLE_NAME' */

	IF (@include_table_name IS NOT NULL)
		SELECT @IncludeTables = '''' + REPLACE(@include_table_name, ',', ''',''') + ''''

	IF (@exclude_table_name IS NOT NULL)
		SELECT @ExcludeTables = '''' + REPLACE(@exclude_table_name, ',', ''',''') + ''''

	DECLARE @dbname NVARCHAR(100)
	SELECT @dbname = DB_NAME()
	SET @start_time_update_stats = GETDATE()
	
	/* sampled_rows - is an indicator of performing update statistics on specific table */
	UPDATE t_updatestatsinfo SET sampled_rows = NULL
	
	
	--Indexed Views
	
	PRINT 'Updating statistics for Indexed Views...'
	IF (@IncludeTables IS NULL) AND (@ExcludeTables IS NULL) --all view
	BEGIN
		SET @SqlStmt = REPLACE(@SqlViewStmtPattern, '{%0}', '')
	END
	ELSE IF (@IncludeTables IS NOT NULL) --include view
	BEGIN
		SET @SqlStmt = REPLACE(@SqlViewStmtPattern, '{%0}', ' AND obj.name IN (' + @IncludeTables + ')')
	END
	ELSE IF (@ExcludeTables IS NOT NULL) --exclude view
	BEGIN
		SET @SqlStmt = REPLACE(@SqlViewStmtPattern, '{%0}', ' AND obj.name NOT IN (' + @ExcludeTables + ')')
	END

	PRINT @SqlStmt
	EXEC (@SqlStmt)

	SELECT @SQLStmtError = @@ERROR
	IF @SQLStmtError <> 0
		RETURN 1
	OPEN curUserObjs
	FETCH curUserObjs INTO @table_name
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC MT_sys_analyze_single_table
		     @table_type = 'V',
		     @table_name = @table_name,
		     @float_sample_rate = @NU_float_sample_percent,
		     @only_indexes = @only_indexes
		
		FETCH curUserObjs INTO @table_name
	END
	CLOSE curUserObjs
	DEALLOCATE curUserObjs
	PRINT 'Statistics have been updated for all Indexed Views.'


	--Updating Non-Usage tables
	
	PRINT 'Updating statistics for Non-Usage tables...'
	IF (@IncludeTables IS NULL) AND (@ExcludeTables IS NULL) --all tables
		SET @SqlStmt = REPLACE (@SqlNonUsageStmtPattern, '{%0}', '')
	ELSE IF (@IncludeTables IS NOT NULL) --include view
		SET @SqlStmt = REPLACE (@SqlNonUsageStmtPattern, '{%0}', ' AND table_name IN (' + @IncludeTables + ')')
	ELSE IF (@ExcludeTables IS NOT NULL) --exclude view
		SET @SqlStmt = REPLACE (@SqlNonUsageStmtPattern, '{%0}', ' AND table_name NOT IN (' + @ExcludeTables + ')')

	PRINT @SqlStmt
	EXEC (@SqlStmt)

	SELECT @SQLStmtError = @@ERROR
	IF @SQLStmtError <> 0
		RETURN 1
	OPEN curUserObjs
	FETCH curUserObjs INTO @table_name
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC MT_sys_analyze_single_table
			 @table_type = 'N',
			 @table_name = @table_name,
			 @float_sample_rate = @NU_float_sample_percent,
			 @only_indexes = @only_indexes
			     
		FETCH curUserObjs INTO @table_name
	END
	CLOSE curUserObjs
	DEALLOCATE curUserObjs
	PRINT 'Statistics have been updated for all Non-Usage tables'

	
	--Updating Usage tables
	
	PRINT 'Updating Statistics for Usage tables...'
	IF (@IncludeTables IS NULL) AND (@ExcludeTables IS NULL) --all tables
		SET @SqlStmt = REPLACE(@SqlUsageStmtPattern, '{%0}', '') 
	ELSE IF (@IncludeTables IS NOT NULL) --include tables
		SET @SqlStmt = REPLACE(@SqlUsageStmtPattern, '{%0}', ' AND table_name IN (' + @IncludeTables + ')') 
	ELSE IF (@ExcludeTables IS NOT NULL) --exclude tables
		SET @SqlStmt = REPLACE(@SqlUsageStmtPattern, '{%0}', ' AND table_name NOT IN (' + @ExcludeTables + ')') 
	
	PRINT @SqlStmt
	EXEC (@SqlStmt)
	
	SELECT @SQLStmtError = @@ERROR
	IF @SQLStmtError <> 0
		RETURN 1
	
	OPEN curUserObjs
	FETCH curUserObjs INTO @table_name
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC MT_sys_analyze_single_table
		     @table_type = 'U',
		     @table_name = @table_name,
		     @float_sample_rate = @U_float_sample_percent,
		     @only_indexes = @only_indexes
			
		FETCH curUserObjs INTO @table_name
	END
	CLOSE curUserObjs
	DEALLOCATE curUserObjs
	PRINT 'Statistics have been updated for all Usage tables'

	/* 
	--- Update statistics for meter tables
	PRINT 'Updating Statistics for Meter tables...'
	IF (@IncludeTables IS NULL) AND (@ExcludeTables IS NULL) --all tables
		SET @SqlStmt = REPLACE(@SqlMeterStmtPattern, '{%0}', '') 
	ELSE IF (@IncludeTables IS NOT NULL) --include tables
		SET @SqlStmt = REPLACE(@SqlMeterStmtPattern, '{%0}', ' AND table_name IN (' + @IncludeTables + ')') 
	ELSE IF (@ExcludeTables IS NOT NULL) --exclude tables
		SET @SqlStmt = REPLACE(@SqlMeterStmtPattern, '{%0}', ' AND table_name NOT IN (' + @ExcludeTables + ')') 
	
	PRINT @SqlStmt
	EXEC (@SqlStmt)
	
	SELECT @SQLStmtError = @@ERROR
	IF @SQLStmtError <> 0
		RETURN 1
	OPEN curUserObjs
	FETCH curUserObjs INTO @table_name
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC MT_sys_analyze_single_table
		     @table_type = 'M',
		     @table_name = @table_name,
		     @float_sample_rate = @U_float_sample_percent,
		     @only_indexes = @only_indexes
			
		FETCH curUserObjs INTO @table_name
	END
	CLOSE curUserObjs
	DEALLOCATE curUserObjs
	PRINT 'Statistics have been updated for all Meter tables'
	*/

	DROP TABLE #StatisticsHeader
	
	DECLARE @U_total_rows     BIGINT,
			@NU_total_rows    BIGINT,
			@U_sampled_rows   BIGINT,
			@NU_sampled_rows  BIGINT,
	        @last_id          INT

	SELECT @U_total_rows = SUM(total_rows),
		   @U_sampled_rows = SUM(sampled_rows)
	FROM   t_updatestatsinfo
	WHERE  tab_type = 'U'
	
	SELECT @NU_total_rows = SUM(total_rows),
		   @NU_sampled_rows = SUM(sampled_rows)
	FROM   t_updatestatsinfo
	WHERE tab_type IN ( 'N', 'V')
	
	SET @total_duration_sec = datediff(s,@start_time_update_stats,getdate())
	
	INSERT INTO t_mt_sys_analyze_all_tables
	  (
	    execution_date,
	    stats_updated,
	    U_total_rows,
	    NU_total_rows,
	    U_sampled_rows,
	    NU_sampled_rows,
	    execution_time_sec
	  )
	SELECT @start_time_update_stats,
	       SUM(num_of_stats),
	       @U_total_rows,
	       @NU_total_rows,
	       @U_sampled_rows,
	       @NU_sampled_rows,
	       @total_duration_sec
	FROM   t_updatestatsinfo

	SELECT @last_id = MAX(id) FROM t_mt_sys_analyze_all_tables

	UPDATE t_mt_sys_analyze_all_tables
	SET    U_sampled_percent   = (CAST(U_sampled_rows AS FLOAT) / CAST(U_total_rows AS FLOAT)) * 100,
	       NU_sampled_percent  = (CAST(NU_sampled_rows AS FLOAT) / CAST(NU_total_rows AS FLOAT)) * 100,
	       execution_time      = DATEADD(second, execution_time_sec, '0:00:00')
	WHERE  id                  = @last_id

	/* Display UPDATE STATISTIC summary */
	SELECT *
	FROM   t_mt_sys_analyze_all_tables
	SELECT *
	FROM   t_updatestatsinfo
	WHERE  total_rows > 0
		   AND num_of_stats > 0
	ORDER BY
		   total_rows DESC

	RETURN 0
END TRY
BEGIN CATCH
	IF CURSOR_STATUS('global', 'curUserObjs') >= -1
	BEGIN
	    CLOSE curUserObjs
	    DEALLOCATE curUserObjs
	END

	PRINT ERROR_MESSAGE()	
	SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE()
	RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
END CATCH
