CREATE PROCEDURE arch_export_adjustment_tables
(
	@path NVARCHAR(1000),
	@interval_id INT
)
AS
	SET NOCOUNT ON
	
	DECLARE @sql NVARCHAR(4000)
	DECLARE @var NVARCHAR(4000)
	
BEGIN
	IF OBJECT_ID('tempdb..tmp_t_adjustment_transaction') IS NOT NULL
	DROP TABLE tempdb..tmp_t_adjustment_transaction
	
	SELECT @sql = N'SELECT id_adj_trx into tempdb..tmp_t_adjustment_transaction FROM ' 
					+ db_name() + '..t_adjustment_transaction WHERE id_usage_interval=' 
					+ cast (@interval_id AS VARCHAR(10)) + N' order by id_sess'
	EXEC (@sql)
	CREATE UNIQUE CLUSTERED INDEX idx_tmp_t_adjustment_transaction ON tempdb..tmp_t_adjustment_transaction(id_adj_trx)

	IF OBJECT_ID('tempdb..##adjustment') IS NOT NULL
	DROP TABLE ##adjustment
	
	CREATE TABLE ##adjustment(name NVARCHAR(2000))
	
    DECLARE cursor_adjustment CURSOR FAST_FORWARD FOR 
		SELECT table_name FROM information_schema.tables WHERE 
				table_name like 't_aj_%' AND 
					table_name NOT IN ('T_AJ_TEMPLATE_REASON_CODE_MAP','t_aj_type_applic_map')
    OPEN cursor_adjustment
    
    FETCH NEXT FROM cursor_adjustment into @var
    WHILE (@@fetch_status = 0)
    BEGIN
			--Get the name of t_aj tables that have usage in this interval_id
		SET @sql = N'IF EXISTS(SELECT 1 FROM ' + @var + ' WHERE id_adjustment in 
							      (SELECT id_adj_trx FROM t_adjustment_transaction WHERE id_usage_interval = ' + CAST(@interval_id AS VARCHAR(10)) + N')) 
									  INSERT INTO ##adjustment values(''' + @var + ''')'
		EXEC sp_executesql @sql
	  
		SET @sql = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview'')) DROP view bcpview'
		EXEC sp_executesql @sql
		
   FETCH NEXT FROM cursor_adjustment into @var
   END
   CLOSE cursor_adjustment
   DEALLOCATE cursor_adjustment

   DECLARE cursor_adjustment_table CURSOR FOR SELECT name FROM ##adjustment
   OPEN cursor_adjustment_table
   FETCH NEXT FROM cursor_adjustment_table into @var
   WHILE (@@fetch_status = 0)
   BEGIN
	  SET @sql = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview'')) DROP view bcpview'
	  EXEC sp_executesql @sql
	  
	   --BCP out the data FROM t_aj tables
	  SELECT @sql = N'CREATE VIEW bcpview as SELECT top 100 percent aj.* FROM ' + db_name() + '..' + @var 
	   + ' aj inner join tempdb..tmp_t_adjustment_transaction trans on aj.id_adjustment=trans.id_adj_trx'
	  EXEC (@sql)
	  														  
	  SELECT @sql = 'bcp "' + db_name() +'..bcpview" out "' 
						+ @path + '\' + @var + '_' + CAST (@interval_id AS VARCHAR (10)) + '.txt" -n  -T'
										   									   
      TRUNCATE TABLE ##bcpoutput
      INSERT INTO ##bcpoutput EXEC master.dbo.xp_cmdshell @sql
      
	  IF EXISTS(SELECT NULL FROM ##bcpoutput 
					WHERE OutputLine like '%Error%' 
							OR OutputLine like '%ODBC SQL Server Driver%')
	  BEGIN
	  	SELECT * FROM ##bcpoutput
		  CLOSE cursor_adjustment_table
		  DEALLOCATE cursor_adjustment_table
		  RAISERROR('1000013-archive operation failed-->Error in bcp out %s table, check the hard disk space', 16, 1, @var)
		  RETURN
	  END
   FETCH NEXT FROM cursor_adjustment_table INTO @var
   END
   CLOSE cursor_adjustment_table
   DEALLOCATE cursor_adjustment_table
END