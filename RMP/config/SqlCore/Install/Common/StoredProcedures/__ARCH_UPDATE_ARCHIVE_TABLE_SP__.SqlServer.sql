CREATE PROCEDURE arch_update_archive_table
(
	@status_to_insert CHAR(1),
	@interval_id INT,
	@result nvarchar(4000) OUTPUT
)
AS

	BEGIN
		 IF OBJECT_ID('tempdb..#id_view') IS NOT NULL
		 DROP TABLE #id_view
		 SELECT DISTINCT id_view INTO #id_view FROM t_acc_usage WHERE id_usage_interval = @interval_id
						   
		   UPDATE t_archive 
		   SET tt_end = dateadd(s,-1, getdate())
			WHERE id_interval = @interval_id 
				AND [status] = @status_to_insert 
					AND tt_end = dbo.mtmaxdate()
		   if (@@error <> 0)
		   BEGIN
			   SET @result = '1000014-archive operation failed-->Error in update t_archive table'
			   RETURN
		   END
						   
		   INSERT INTO t_archive 
		   SELECT @interval_id, id_view, null, @status_to_insert,getdate(),dbo.mtmaxdate() FROM #id_view
		   UNION ALL
				SELECT @interval_id, null, name, @status_to_insert,getdate(),dbo.mtmaxdate() FROM ##adjustment
		   IF (@@error <> 0)
		   BEGIN
			   SET @result = '1000015-archive operation failed-->Error in insert t_archive table'
			   RETURN
		   END
	END