
				select ui.id_interval IntervalID, ui.dt_start StartDate,  
			  ui.dt_end EndDate, ui.tx_interval_status Status, uct.tx_desc CycleType from t_usage_interval ui,  
        t_usage_cycle uc, t_usage_cycle_type uct where ui.id_usage_cycle = uc.id_usage_cycle  
        and uc.tx_period_type = '%%PERIOD_TYPE%%' and ui.tx_interval_status = '%%STATUS%%' 
        and uc.id_cycle_type = uct.id_cycle_type order by ui.dt_start ASC
				