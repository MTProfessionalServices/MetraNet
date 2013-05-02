CREATE PROCEDURE arch_update_account_bucket_map
(
	@status_to_insert CHAR(1),
	@acc INT,
	@interval_id INT
)
AS
	BEGIN
		DECLARE @date_to_update DATETIME
		SET @date_to_update = dateadd(s,-1,getdate())
		
		UPDATE t_acc_bucket_map
		SET tt_end = @date_to_update
		WHERE id_usage_interval = @interval_id 
				AND [status] IN ('E','U')
					AND tt_end = dbo.mtmaxdate()
						AND bucket = @acc		
										  						   
		 IF (@@error <> 0)
		 BEGIN
			  RAISERROR('1000010-archive operation failed-->Error in update t_acc_bucket_map table',16,1)
			  RETURN
		 END
	 
		 INSERT INTO t_acc_bucket_map(id_usage_interval,id_acc, bucket, [status], tt_start, tt_end) 
		 SELECT @interval_id, id_acc, bucket, @status_to_insert,getdate(), dbo.mtmaxdate() 
			FROM t_acc_bucket_map
				WHERE id_usage_interval = @interval_id 
					AND [status] IN ('E','U')
						AND tt_end = @date_to_update
							AND bucket = @acc
												   
		IF (@@error <> 0)
		BEGIN
			  RAISERROR('1000011-archive operation failed-->Error in insert into t_acc_bucket_map table',16,1)
			  RETURN
		END
	END