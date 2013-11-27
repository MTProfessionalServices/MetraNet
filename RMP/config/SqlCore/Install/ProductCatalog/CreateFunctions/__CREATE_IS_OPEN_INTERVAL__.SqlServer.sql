
		CREATE  function IsIntervalOpen (@id_acc int, @aIntervalID int) returns int
		as
		begin
		declare @retVal as int
		SET @retval = 0
		SELECT  @retVal = 
		CASE WHEN  
		( 
			SELECT  ui.tx_status 
			FROM  t_acc_usage_interval ui 
			WHERE ui.id_acc = @id_acc AND ui.id_usage_interval = @aIntervalID
		)
			IN ('B', 'O') THEN 1 ELSE 0 END
			return @retVal
		end
		