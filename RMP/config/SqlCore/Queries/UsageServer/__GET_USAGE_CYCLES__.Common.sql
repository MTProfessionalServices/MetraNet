
      select DISTINCT(uc.id_usage_cycle) CycleID,
			uc.id_cycle_type CycleTypeID, uc.day_of_month DayOfMonth,
			uc.day_of_week DayOfWeek, uc.first_day_of_month FirstDayOfMonth,
			uc.second_day_of_month SecondDayOfMonth, uc.start_day StartDay,
			uc.start_month StartMonth, uc.start_year StartYear,
			uct.tx_cycle_type_method ProgID from t_usage_cycle uc,
			t_usage_cycle_type uct, t_acc_usage_cycle auc, t_acc_usage_interval
			aui, t_usage_interval ui where uc.id_cycle_type = uct.id_cycle_type
			and auc.id_usage_cycle = uc.id_usage_cycle and aui.id_acc = auc.id_acc
			and aui.id_usage_interval = ui.id_interval and ui.id_usage_cycle =
			auc.id_usage_cycle and (aui.dt_effective is null or (aui.dt_effective
			is not null and %%UTCDATE%% > aui.dt_effective))
			