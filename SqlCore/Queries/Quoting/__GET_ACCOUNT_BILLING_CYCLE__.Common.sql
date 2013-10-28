SELECT  id_cycle_type as AccountCycleType, 
        day_of_month as DayOfMonth,
		day_of_week as DayOfWeek,
		first_day_of_month as FirstDayOfMonth,
		second_day_of_month as SecondDayOfMonth,
		start_day as StartDay,
		start_month as StartMonth,
		start_year as StartYear
FROM t_acc_usage_cycle auc
JOIN t_usage_cycle uc on auc.id_usage_cycle = uc.id_usage_cycle
WHERE auc.id_acc=%%ACCOUNT_ID%%