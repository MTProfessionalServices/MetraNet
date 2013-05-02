
		create function GetCurrentIntervalID (@aDTNow datetime, @aDTSession datetime, @aAccountID int) returns int
		as
		begin
      declare @retVal as int
      SELECT  @retVal =  id_usage_interval FROM  t_acc_usage_interval aui  
         INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval
         WHERE ui.tx_interval_status <> 'H' AND
 		     @aDTSession BETWEEN ui.dt_start AND ui.dt_end AND
	      ((aui.dt_effective IS NULL) OR (aui.dt_effective <= @aDTNow))
        AND aui.id_acc = @aAccountID
      return @retVal
    end
		