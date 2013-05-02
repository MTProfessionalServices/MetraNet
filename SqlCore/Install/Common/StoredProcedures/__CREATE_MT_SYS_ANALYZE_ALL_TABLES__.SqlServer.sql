
CREATE PROCEDURE [dbo].[MT_sys_analyze_all_tables] 
(
@NU_varStatPercent INT = 30,
@U_varStatPercent INT = 30, 
@H_varStatPercent INT = 30, 
@include_table_name NVARCHAR(MAX) = NULL,
@exclude_table_name NVARCHAR(MAX) = NULL,
@only_indexes NVARCHAR(10) = 'ALL'
)
AS
BEGIN TRY
	/********************************************************************
	** Procedure Name:  MT_sys_analyze_all_tables
	** exec MT_sys_analyze_all_tables 100,30,100,null,null,'ALL'
	** Procedure Description: Analyze all the user defined tables in all the partitions
	**
	** Parameters: varStatPercent int
	**
	** Returns: 0 IF successful
	**          1 IF fatal error occurred
	**
	** NOTES: 
	*********************************************************************************/
	DECLARE 
	@varTblName VARCHAR(128), 
	@SQLStmtError INT,
	@PrintStmt VARCHAR(1000), 
	@NU_varStatPercentChar VARCHAR(255),
	@U_varStatPercentChar VARCHAR(255),
	@H_varStatPercentChar VARCHAR(255),
	@getdate DATETIME, 
	@starttime DATETIME,
	@ErrorMessage NVARCHAR(MAX),
	@ErrorSeverity INT,
	@ErrorState INT


	SET NOCOUNT ON
	DECLARE @intervalstart INT
	DECLARE @intervalend INT
	DECLARE @rowcount INT
	DECLARE @maxdate DATETIME

	SET @maxdate = dbo.MTMaxdate()
	SET @rowcount=0
	SELECT @getdate = GETDATE()
	IF @NU_varStatPercent < 5
	   SET @NU_varStatPercentChar = ' WITH SAMPLE 5 PERCENT, ' + @only_indexes
	ELSE IF @NU_varStatPercent >= 100
	   SET @NU_varStatPercentChar = ' WITH FULLSCAN, ' + @only_indexes
	ELSE SET @NU_varStatPercentChar = ' WITH SAMPLE '
	   + CAST(@NU_varStatPercent AS VARCHAR(20))
	   + ' PERCENT, ' + @only_indexes

	IF @U_varStatPercent < 5
	   SET @U_varStatPercentChar = ' WITH SAMPLE 5 PERCENT, ' + @only_indexes
	ELSE IF @U_varStatPercent >= 100
	   SET @U_varStatPercentChar = ' WITH FULLSCAN, ' + @only_indexes
	ELSE SET @U_varStatPercentChar = ' WITH SAMPLE '
	   + CAST(@U_varStatPercent AS VARCHAR(20))
	   + ' PERCENT, ' + @only_indexes

	IF @H_varStatPercent < 5
	   SET @H_varStatPercentChar = ' WITH SAMPLE 5 PERCENT, ' + @only_indexes
	ELSE IF @H_varStatPercent >= 100
	   SET @H_varStatPercentChar = ' WITH FULLSCAN, ' + @only_indexes
	ELSE SET @H_varStatPercentChar = ' WITH SAMPLE '
	   + CAST(@H_varStatPercent AS VARCHAR(20))
	   + ' PERCENT, ' + @only_indexes

	DECLARE @SqlStmt NVARCHAR(MAX)
	DECLARE @SqlViewStmtPattern VARCHAR(MAX)
	DECLARE @SqlNonUsageStmtPattern VARCHAR(MAX)
	DECLARE @SqlUsageStmtPattern VARCHAR(MAX)
	DECLARE @SqlPartitionStmtPattern VARCHAR(MAX)

	DECLARE @IncludeTables VARCHAR(MAX)
	DECLARE @ExcludeTables VARCHAR(MAX)
	 
	--Indexed Views
	SET @SqlViewStmtPattern = 'DECLARE curUserObjs CURSOR FOR
	SELECT DISTINCT obj.name FROM sysindexkeys keys 
	INNER JOIN sysobjects obj ON keys.id=obj.id
	WHERE XTYPE=''v'' {%0}'
	 
	--Non-Usage tables in NetMeter Database
	SET @SqlNonUsageStmtPattern = 'DECLARE curUserObjs CURSOR FOR
	SELECT table_name FROM information_schema.tables
	WHERE table_type = ''BASE TABLE''
	AND table_name NOT LIKE ''t_acc_usage%'' 
	AND table_name NOT LIKE ''t_pv%''
	AND table_name NOT LIKE ''t_svc%'' 
	AND table_name NOT IN (''t_session'',''t_session_state'',''t_session_set'',''t_message'')
	{%0}'

	--Usage tables in NetMeter Database
	SET @SqlUsageStmtPattern = 'DECLARE curUserObjs CURSOR FOR
	SELECT table_name FROM information_schema.tables
	WHERE table_type = ''BASE TABLE''
	AND (table_name LIKE ''t_acc_usage%'' 
	OR table_name LIKE ''t_pv%''
	OR table_name LIKE ''t_svc%'' 
	OR table_name IN (''t_session'',''t_session_state'',''t_session_set'',''t_message''))
	{%0}'

	--Partition info in NetMeter Database		
	SET @SqlPartitionStmtPattern = 'DECLARE curUserObjs CURSOR FOR
	SELECT table_name FROM {%0}.information_schema.tables
	WHERE table_type = ''BASE TABLE'' {%1}
	ORDER BY table_name'

	IF (@include_table_name IS NOT NULL)
		SELECT @IncludeTables = '''' + REPLACE(@include_table_name, ',', ''',''') + ''''

	IF (@exclude_table_name IS NOT NULL)
		SELECT @ExcludeTables = '''' + REPLACE(@exclude_table_name, ',', ''',''') + ''''

	DECLARE @dbname NVARCHAR(100)
	SELECT @dbname = DB_NAME()

	--Indexed Views
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
	FETCH curUserObjs INTO @varTblName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @starttime = getdate()
		SET @SqlStmt = 'UPDATE STATISTICS ' + @varTblName + @NU_varStatPercentChar
		PRINT @SqlStmt + ':START-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
		EXECUTE (@SqlStmt)
		PRINT 'END-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
		INSERT INTO t_updatestatsinfo VALUES (@varTblName, @NU_varStatPercentChar, DATEDIFF(ss,@starttime,GETDATE()))
		FETCH curUserObjs INTO @varTblName
	END
	CLOSE curUserObjs
	DEALLOCATE curUserObjs
	PRINT 'Statistics have been updated for all Indexed Views.'

	--Non-Usage tables in NetMeter Database
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
	FETCH curUserObjs INTO @varTblName
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @starttime = GETDATE()
		SET @SqlStmt = 'UPDATE STATISTICS ' + @varTblName + @NU_varStatPercentChar
		PRINT @SqlStmt + ':START-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
		EXECUTE (@SqlStmt)
		PRINT 'END-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
		INSERT INTO t_updatestatsinfo VALUES (@varTblName, @NU_varStatPercentChar, DATEDIFF(ss,@starttime,GETDATE()))
		FETCH curUserObjs INTO @varTblName
	END
	CLOSE curUserObjs
	DEALLOCATE curUserObjs
	INSERT INTO t_updatestats_partition(partname,partition_status,last_stats_time,Non_Usage_Sampling_Ratio)
	VALUES ( @dbname,'O',@getdate,@NU_varStatPercent)
	PRINT 'Statistics have been updated for all Non-Partitioned Non-Usage tables'

	IF (SELECT b_partitioning_enabled FROM t_usage_server) = 'N' --no partitioning
	BEGIN
		--Usage tables in NetMeter Database
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
		FETCH curUserObjs INTO @varTblName
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @starttime = getdate()
			SET @SqlStmt = 'UPDATE STATISTICS ' + @varTblName + @U_varStatPercentChar
			PRINT @SqlStmt + ':START-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
			EXECUTE (@SqlStmt)
			PRINT 'END-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
			INSERT INTO t_updatestatsinfo VALUES (@varTblName, @U_varStatPercentChar, datediff(ss,@starttime,getdate()))
			FETCH curUserObjs INTO @varTblName
		END
		CLOSE curUserObjs
		DEALLOCATE curUserObjs
		UPDATE t_updatestats_partition SET Usage_Sampling_Ratio = @U_varStatPercent
		WHERE partname = @dbname AND partition_status='O' AND last_stats_time = @getdate
		PRINT 'Statistics have been updated for all Non-Partitioned Usage tables'
	END
	ELSE
	BEGIN --contain partitioning
		--Loop over all the partitions and update stats with Usage sampling ratio
		DECLARE @partname NVARCHAR(4000)
		--create table #partition(partname NVARCHAR(4000))
		DECLARE part CURSOR FOR SELECT DISTINCT partition_name FROM t_partition 
		OPEN part
		FETCH part INTO @partname
		WHILE @@FETCH_STATUS = 0
		BEGIN
		--Check for open Intervals
			SELECT @intervalstart = id_interval_start, @intervalend= id_interval_end FROM t_partition
			WHERE partition_name = @partname
			IF EXISTS
			(
			SELECT 1 FROM t_usage_interval
			WHERE tx_interval_status <> 'H'
			AND id_interval between @intervalstart AND @intervalend
			AND not exists (SELECT 1 FROM t_archive_partition WHERE partition_name=@partname
			AND status = 'A' AND tt_end = @maxdate)
			UNION ALL
			SELECT 1 FROM t_partition WHERE partition_name = @partname AND b_default = 'Y'
			UNION ALL
			SELECT 1 FROM t_partition WHERE id_partition NOT IN
			(SELECT id_partition FROM t_partition_interval_map)
			AND partition_name = @partname)
			BEGIN
				
				SET @SqlStmt = REPLACE (@SqlPartitionStmtPattern, '{%0}', @partname) 
			
				IF (@IncludeTables IS NULL) AND (@ExcludeTables IS NULL) --all tables
					SET @SqlStmt = REPLACE(@SqlStmt, '{%1}', '') 
				ELSE IF (@IncludeTables IS NOT NULL) --include tables
					SET @SqlStmt = REPLACE(@SqlStmt, '{%1}', ' AND table_name IN (' + @IncludeTables + ')') 
				ELSE IF (@ExcludeTables IS NOT NULL) --exclude tables
					SET @SqlStmt = REPLACE(@SqlStmt, '{%1}', ' AND table_name NOT IN (' + @ExcludeTables + ')') 
		
				PRINT @SqlStmt
				EXEC (@SqlStmt)
				
				SELECT @SQLStmtError = @@ERROR
				IF @SQLStmtError <> 0
					RETURN 1
				OPEN curUserObjs
				FETCH curUserObjs INTO @varTblName
				WHILE @@FETCH_STATUS = 0
				   BEGIN
					   SET @starttime = getdate()
					   SET @SqlStmt = 'UPDATE STATISTICS ' + @partname + '..' + @varTblName + @U_varStatPercentChar
					   PRINT @SqlStmt + ':START-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
					   EXECUTE (@SqlStmt)
					   PRINT 'END-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
		   			   INSERT INTO t_updatestatsinfo VALUES (@varTblName, @U_varStatPercentChar, DATEDIFF(ss,@starttime,GETDATE()))
				   FETCH curUserObjs INTO @varTblName
				   END
				CLOSE curUserObjs
				DEALLOCATE curUserObjs
				INSERT INTO t_updatestats_partition(partname,partition_status,last_stats_time,Usage_Sampling_Ratio)
				VALUES ( @partname,'O',@getdate,@U_varStatPercent)
				SET @rowcount = @@ROWCOUNT
				PRINT 'Statistics have been updated for all tables of Open Interval Partitions.'
			END
			IF (@rowcount = 0)
			BEGIN
			--Check for Archived Intervals
				IF exists
					(SELECT 1 FROM t_partition part
					INNER JOIN t_archive_partition archive
					ON part.partition_name = archive.partition_name
					WHERE part.partition_name = @partname
					AND status ='A'
					AND tt_end = @maxdate
					AND NOT EXISTS
						(SELECT 1 FROM t_updatestats_partition back1
						WHERE part.partition_name = back1.partname
						AND
						back1.last_stats_time IS NOT NULL AND partition_status = 'A')
					)
					BEGIN
						SET @SqlStmt = REPLACE (@SqlPartitionStmtPattern, '{%0}', @partname) 
			
						IF (@IncludeTables IS NULL) AND (@ExcludeTables IS NULL) --all tables
							SET @SqlStmt = REPLACE(@SqlStmt, '{%1}', '') 
						ELSE IF (@IncludeTables IS NOT NULL) --include tables
							SET @SqlStmt = REPLACE(@SqlStmt, '{%1}', ' AND table_name IN (' + @IncludeTables + ')') 
						ELSE IF (@ExcludeTables IS NOT NULL) --exclude tables
							SET @SqlStmt = REPLACE(@SqlStmt, '{%1}', ' AND table_name NOT IN (' + @ExcludeTables + ')') 
				
						PRINT @SqlStmt
						EXEC (@SqlStmt)
							
						SELECT @SQLStmtError = @@ERROR
						IF @SQLStmtError <> 0
							RETURN 1
						OPEN curUserObjs
						FETCH curUserObjs INTO @varTblName
						WHILE @@FETCH_STATUS = 0
						   BEGIN
							  SET @starttime = getdate()
							  SET @SqlStmt = 'UPDATE STATISTICS ' + @partname + '..' + @varTblName + @H_varStatPercentChar
							  PRINT @SqlStmt + ':START-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
							  EXECUTE (@SqlStmt)
							  PRINT 'END-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
	         	   			  INSERT INTO t_updatestatsinfo VALUES (@varTblName, @H_varStatPercentChar, DATEDIFF(ss,@starttime,GETDATE()))
						   FETCH curUserObjs INTO @varTblName
						   END
						CLOSE curUserObjs
						DEALLOCATE curUserObjs
						INSERT INTO t_updatestats_partition(partname,partition_status,last_stats_time,H_Sampling_Ratio)
						VALUES ( @partname,'A',@getdate,@H_varStatPercent)
						SET @rowcount = @@ROWCOUNT
						PRINT 'Statistics have been updated for all tables of Archived Interval Partitions'
					END
			END
			IF (@rowcount = 0)
			BEGIN
			--Check for Hard-Closed Intervals
			IF EXISTS
				(SELECT 1 FROM t_partition part
				WHERE partition_name = @partname
				AND id_partition IN
				(SELECT id_partition FROM t_partition_interval_map)
				AND @partname not IN (SELECT partition_name FROM t_partition WHERE b_default = 'Y')
				AND NOT EXISTS
					(
					SELECT 1 FROM t_usage_interval usage
					WHERE tx_interval_status <> 'H'
					AND id_interval between @intervalstart AND @intervalend
					)
				AND NOT EXISTS
					(
					SELECT 1 FROM t_updatestats_partition back1
					WHERE part.partition_name = back1.partname
					AND
					((back1.last_stats_time is not null AND partition_status = 'H')
					OR (back1.last_stats_time is not null AND partition_status = 'A')))
					)
				BEGIN
					SET @SqlStmt = REPLACE(@SqlPartitionStmtPattern, '{%0}', @partname) 
		
					IF (@IncludeTables IS NULL) AND (@ExcludeTables IS NULL) --all tables
						SET @SqlStmt = REPLACE(@SqlStmt, '{%1}', '') 
					ELSE IF (@IncludeTables IS NOT NULL) --include tables
						SET @SqlStmt = REPLACE(@SqlStmt, '{%1}', ' AND table_name IN (' + @IncludeTables + ')') 
					ELSE IF (@ExcludeTables IS NOT NULL) --exclude tables
						SET @SqlStmt = REPLACE(@SqlStmt, '{%1}', ' AND table_name NOT IN (' + @ExcludeTables + ')') 
			
					PRINT @SqlStmt
					EXEC (@SqlStmt)
			
					SELECT @SQLStmtError = @@ERROR
					IF @SQLStmtError <> 0
						RETURN 1
					OPEN curUserObjs
					FETCH curUserObjs INTO @varTblName
					WHILE @@FETCH_STATUS = 0
					   BEGIN
						  SET @starttime = GETDATE()
						  SET @SqlStmt = 'UPDATE STATISTICS ' + @partname + '..' + @varTblName + @H_varStatPercentChar
						  PRINT @SqlStmt + ':START-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
						  EXECUTE (@SqlStmt)
						  PRINT 'END-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
     	   				  INSERT INTO t_updatestatsinfo VALUES (@varTblName, @H_varStatPercentChar, DATEDIFF(ss,@starttime,GETDATE()))
					   FETCH curUserObjs INTO @varTblName
					   END
					CLOSE curUserObjs
					DEALLOCATE curUserObjs
					INSERT INTO t_updatestats_partition(partname,partition_status,last_stats_time,H_Sampling_Ratio)
					VALUES ( @partname,'H',@getdate,@H_varStatPercent)
					PRINT 'Statistics have been updated for all tables of Hard closed Interval Partitions'
				END
			END
		SET @rowcount=0
		FETCH NEXT FROM part INTO @partname
		END
		CLOSE part
		DEALLOCATE part
	END

	RETURN 0
END TRY
BEGIN CATCH  
	PRINT ERROR_MESSAGE()
	
	SELECT  @ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage, -- Message text.
			   @ErrorSeverity, -- Severity.
			   @ErrorState -- State.
			   )

END CATCH

	