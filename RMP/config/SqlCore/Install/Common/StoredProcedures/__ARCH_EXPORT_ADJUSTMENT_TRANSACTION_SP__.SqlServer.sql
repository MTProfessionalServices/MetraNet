CREATE PROCEDURE arch_export_adjustment_transaction
(
	@path NVARCHAR(1000),
	@interval_id INT
)
AS
	SET NOCOUNT ON
	
	DECLARE @sql NVARCHAR(4000)
	
BEGIN
	SET @sql = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(''bcpview'')) DROP view bcpview'
	EXEC sp_executesql @sql
	
	SELECT @sql = N'CREATE VIEW bcpview as SELECT TOP 100 percent * FROM t_adjustment_transaction WHERE id_usage_interval=' + 
						CAST (@interval_id AS VARCHAR(10)) + N' order by id_sess'
	EXEC (@sql)		
					   
   --BCP out the data from t_adjustment_transaction
   SELECT @sql = 'bcp "' + db_name() + '..bcpview" out "' 
				+ @path + '\t_adjustment_transaction' + '_' + CAST (@interval_id AS VARCHAR(10)) + '.txt" -n  -T'
				
   TRUNCATE TABLE ##bcpoutput
   INSERT INTO ##bcpoutput EXEC master.dbo.xp_cmdshell @sql
						   
						   
   IF EXISTS(SELECT NULL FROM ##bcpoutput 
				   WHERE OutputLine like '%Error%' 
								  OR OutputLine like '%ODBC SQL Server Driver%')
   BEGIN
   	SELECT * FROM ##bcpoutput
	   RAISERROR('1000012-archive operation failed-->Error in bcp out adjustment transaction table, check the hard disk space',16,1)
	   RETURN
   END
   
   TRUNCATE TABLE ##bcpoutput
END