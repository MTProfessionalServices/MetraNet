
				select ui.id_interval IntervalID, ui.dt_start StartDate,  
			  ui.dt_end EndDate, ui.tx_interval_status Status from t_usage_interval ui 
        where ui.tx_interval_status = '%%STATUS%%' order by ui.dt_start DESC
				