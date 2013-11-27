
		select uc.id_usage_cycle as cycle
		from %%%NETMETER_PREFIX%%%t_usage_cycle uc
		join  %%%NETMETER_PREFIX%%%t_usage_cycle_type uct
		on uct.id_cycle_type = uc.id_cycle_type
		where lower(uct.tx_desc) = lower('%%CYCLE_TYPE_NAME%%')
			and ((uc.id_cycle_type = 1 -- monthly
			and day_of_month = 31)
			or (uc.id_cycle_type = 4 -- weekly
				and day_of_week = 1)
			or (uc.id_cycle_type = 6  -- semi-montly
				and first_day_of_month = 14 and second_day_of_month = 31)
			or (uc.id_cycle_type = 7  -- quarterly
				and start_day = 1 and start_month = 1))
		