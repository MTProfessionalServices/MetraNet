
          select ui.id_interval as "Interval",ui.dt_start as "Start", ui.dt_end as "End", uc.id_cycle_type as "TypeId", uct.tx_desc as "Type",
          	CASE ui.tx_interval_status
          		WHEN 'H' THEN 'Hard Closed'
          		WHEN 'N' THEN 'New'
          		WHEN 'O' THEN 'Open'
          		WHEN 'E' THEN 'Soft Close Pending'
          		WHEN 'S' THEN 'Hard Close Pending'
          		WHEN 'C' THEN 'Soft Closed'
          		ELSE 'INVALID STATUS'
          	END as "State"
          from t_usage_interval ui left outer join t_usage_cycle uc on ui.id_usage_cycle=uc.id_usage_cycle
          join t_usage_cycle_type uct on uc.id_cycle_type=uct.id_cycle_type
          where ui.tx_interval_status = 'H'
        