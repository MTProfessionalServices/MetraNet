CREATE PROCEDURE MT_sys_analyze_single_table(
    @table_type                    NVARCHAR(1),
    @table_name                    NVARCHAR(200),
    @float_sample_rate             FLOAT = NULL,
    @only_indexes                  NVARCHAR(10) = 'ALL'
)
AS
	SET NOCOUNT ON
	
	DECLARE @SampleArgumentString           VARCHAR(255),
	        @num_of_stats                   INT,
	        @num_of_rows                    BIGINT,
	        @default_sampled_rows			BIGINT,
	        @sampled_rows                   BIGINT,
	        @execution_time_sec             INT,
	        @starttime                      DATETIME,
	        @stat_name                      NVARCHAR(200),
	        @is_using_default_sample_rates  BIT,
	        @sql                            NVARCHAR(MAX)
	
	SET @starttime = GETDATE()
	
	IF @table_type NOT IN ( 'U', 'N', 'V')
		RAISERROR('@table_type argument may take only 3 values - ''U'', ''N'' or ''V''',16,1)
	
	IF @float_sample_rate IS NULL
	    SET @is_using_default_sample_rates = 1
	ELSE
	    SET @is_using_default_sample_rates = 0
	
	/* Inset table name on first execution of update stats */
	IF NOT EXISTS ( SELECT * FROM t_updatestatsinfo WHERE tab_type = @table_type AND tab_name = @table_name )
	    INSERT INTO t_updatestatsinfo ( tab_name, tab_type )
	    VALUES ( @table_name, @table_type )
	
	SET @sql = 'select @num_of_stats = count(*) from sys.stats s where s.object_id = object_id(''' + @table_name + ''')'
	EXECUTE sp_executesql @sql, N'@num_of_stats int output', @num_of_stats = @num_of_stats OUT
	
	SELECT @default_sampled_rows = default_sampled_rows
	FROM   t_updatestatsinfo
	WHERE  tab_type = @table_type AND tab_name = @table_name
	
	IF @is_using_default_sample_rates = 1
	    SET @SampleArgumentString = ' WITH ' + @only_indexes
	ELSE
	BEGIN
	    SELECT @num_of_rows = SUM(st.row_count)
	    FROM   sys.dm_db_partition_stats st
	    WHERE  st.object_id = OBJECT_ID(@table_name)
	           AND (index_id < 2)
	    
	    SET @sampled_rows = (@num_of_rows * @float_sample_rate) / 100
	    
	    SET @SampleArgumentString = ' WITH SAMPLE ' + CAST(@sampled_rows AS VARCHAR(200)) 
	        + ' ROWS, ' + @only_indexes
	END
	
	SET @sql = 'UPDATE STATISTICS [' + @table_name + ']' + @SampleArgumentString
	PRINT @sql + ':START-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
	EXECUTE (@sql)
	PRINT 'END-' + CONVERT(CHAR(25), CURRENT_TIMESTAMP, 131)
		
	TRUNCATE TABLE #StatisticsHeader
	
	SET @stat_name = 'pk_' + @table_name
	IF NOT EXISTS (
	       SELECT *
	       FROM   sys.stats s
	       WHERE  s.name = @stat_name
	   )
	    SELECT TOP 1 @stat_name = NAME
	    FROM   sys.stats s
	    WHERE  s.[object_id] = OBJECT_ID(@table_name)
	
	INSERT #StatisticsHeader
	EXEC ( 'DBCC SHOW_STATISTICS(''' + @table_name + ''', ''' + @stat_name + ''') WITH STAT_HEADER')
	
	SELECT @num_of_rows = ISNULL([Rows], 0),
	       @sampled_rows = ISNULL(RowsSampled,0)
	FROM   #StatisticsHeader
	
	IF @is_using_default_sample_rates = 1
	    SET @default_sampled_rows = @sampled_rows
	
	SET @execution_time_sec = DATEDIFF(s, @starttime, GETDATE())
	
	UPDATE t_updatestatsinfo
	SET    total_rows            = @num_of_rows,
	       default_sampled_rows  = @default_sampled_rows,
	       sampled_rows          = @sampled_rows,
	       num_of_stats          = @num_of_stats,
	       execution_time_sec    = @execution_time_sec
	WHERE  tab_type              = @table_type
	       AND tab_name          = @table_name
