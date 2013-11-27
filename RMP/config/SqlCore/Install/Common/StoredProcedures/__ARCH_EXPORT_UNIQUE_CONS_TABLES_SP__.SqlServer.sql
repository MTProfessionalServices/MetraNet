CREATE PROCEDURE arch_export_unique_cons_tables
(
	@path NVARCHAR(1000),
	@acc INT,
	@interval_id INT
)
AS
	SET NOCOUNT ON
	
	DECLARE @table NVARCHAR(1000)
	DECLARE @sql NVARCHAR(4000)
	
	BEGIN
		DECLARE  cursor_unique_cons CURSOR FAST_FORWARD FOR SELECT nm_table_name FROM t_unique_cons
		OPEN cursor_unique_cons
		FETCH NEXT FROM cursor_unique_cons INTO @table
		WHILE (@@fetch_status = 0)
		BEGIN
			SET @sql = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview'')) DROP view bcpview'
			EXEC sp_executesql @sql
			
			SELECT @sql = N'CREATE VIEW bcpview as SELECT TOP 100 percent uq.* FROM ' + 
							db_name() + '..' + @table + ' uq 
							 inner join tempdb..tmp_t_acc_usage au on 
							 uq.id_sess = au.id_sess and uq.id_usage_interval = au.id_usage_interval
							 inner join t_acc_bucket_map act on 
							 au.id_usage_interval = act.id_usage_interval and au.id_acc = act.id_acc
							 where act.bucket =' + cast(@acc as varchar(10)) + 
							 ' and au.id_usage_interval =' + cast(@interval_id as varchar(10)) +
							 ' and act.id_usage_interval =' + cast(@interval_id as varchar(10)) +
							 ' and uq.id_usage_interval =' + cast(@interval_id as varchar(10)) +
							 ' and act.status = ''U'''																										
		   EXEC (@sql)
							  --BCP out the data from product view tables
		   SELECT @sql = 'bcp "' + db_name() + '..bcpview" out "' +
						  @path + '\' + @table + '_' + CAST (@interval_id as varchar (10)) + '_' + CAST (@acc AS VARCHAR (10)) + '.txt" -n -T'
							  
		   TRUNCATE TABLE ##bcpoutput
		   INSERT INTO ##bcpoutput EXEC master.dbo.xp_cmdshell @sql
							  
		   IF EXISTS(SELECT NULL FROM ##bcpoutput 
						WHERE OutputLine like '%Error%' 
									OR OutputLine like '%ODBC SQL Server Driver%')
		   BEGIN
		    SELECT * FROM ##bcpoutput
			  CLOSE cursor_unique_cons
			  DEALLOCATE cursor_unique_cons
			  RAISERROR('1000018-archive operation failed-->Error in bcp out the %s unique key table, check the hard disk space',16,1, @table)
			  RETURN
			END
			
		FETCH NEXT FROM cursor_unique_cons INTO @table	
		END
		CLOSE cursor_unique_cons
		DEALLOCATE cursor_unique_cons
	END