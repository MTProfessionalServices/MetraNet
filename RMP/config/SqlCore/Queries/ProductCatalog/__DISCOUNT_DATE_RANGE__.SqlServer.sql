
    		(%%COUNTER_TABLE%%.dt_crt >= dbo.MTMaxOfTwoDates(di.dt_start, eff.dt_start)
  			AND %%COUNTER_TABLE%%.dt_crt <= dbo.MTMinOfTwoDates(di.dt_end, eff.dt_end))
  		