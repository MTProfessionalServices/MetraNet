CREATE PROCEDURE arch_export_product_view_tables
(
	@path NVARCHAR(1000),
	@acc INT,
	@interval_id INT,
	@minid INT,
	@maxid INT
)
AS

	SET NOCOUNT ON
	
	DECLARE @table NVARCHAR(1000)
	DECLARE @sql NVARCHAR(4000)
	DECLARE @var NVARCHAR(4000)

BEGIN
	
	DECLARE  cursor_product_view CURSOR FAST_FORWARD FOR SELECT id_view from ##productViews 
	OPEN cursor_product_view
	FETCH NEXT FROM cursor_product_view INTO @var
	WHILE (@@fetch_status = 0)
	BEGIN
		  SELECT @table = nm_table_name FROM t_prod_view WHERE id_view = @var 
	
		  SET @sql = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(''bcpview'')) DROP view bcpview'
		  EXEC sp_executesql @sql
		  
		  SELECT @sql = N'CREATE VIEW bcpview as SELECT pv.* FROM ' + 
								  @table + ' pv  with (nolock) inner join tempdb..tmp_t_acc_usage au  with (nolock) on 
								  pv.id_sess=au.id_sess where au.bucket =' + CAST(@acc AS VARCHAR(10)) 
								  + ' and pv.id_sess between ' 
								  + cast(@minid AS VARCHAR(10)) 
								  + ' and '  + cast(@maxid AS VARCHAR(10)) 

		  EXEC (@sql)	
		  													  
		  --BCP out the data from product view tables
		  SELECT @sql = 'bcp "' + db_name() + '..bcpview" out "' + 
							@path + '\' + @table + '_' + cast (@interval_id AS VARCHAR (10)) + '_' + cast (@acc AS VARCHAR (10)) + '.txt" -n  -T'
		  
		  TRUNCATE TABLE ##bcpoutput
		  INSERT INTO ##bcpoutput exec master.dbo.xp_cmdshell @sql
		  
		  IF EXISTS(SELECT NULL FROM ##bcpoutput 
							WHERE OutputLine like '%Error%' 
									OR OutputLine like '%ODBC SQL Server Driver%')
		  BEGIN
		  	SELECT * FROM ##bcpoutput
			  CLOSE cursor_product_view
			  DEALLOCATE cursor_product_view
			  RAISERROR('1000009-archive operation failed-->Error in bcp out the %s product view table, check the hard disk space',16,1, @table)
			  RETURN
		  END
														  
	FETCH NEXT FROM cursor_product_view INTO @var	
    END
    CLOSE cursor_product_view
    DEALLOCATE cursor_product_view
END