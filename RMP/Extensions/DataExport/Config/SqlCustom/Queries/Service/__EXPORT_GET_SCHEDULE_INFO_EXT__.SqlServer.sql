
				SELECT			tsch.id_rp_schedule, tsch.c_sch_type, tschD.c_exec_time AS [c_daily_exec_time], 
								tschD.c_repeat_hour, tschD.c_exec_start_time, tschD.c_exec_end_time, tschD.c_skip_last_day_month, 
								tschD.c_skip_first_day_month, tschD.c_days_interval, tschD.c_month_to_date, 
								tschW.c_exec_time AS [c_weekly_exec_time], tschW.c_exec_week_days, tschW.c_skip_week_days, 
								tschW.c_month_to_date AS [c_weekly_month_to_date], tschM.c_exec_day, tschM.c_exec_time AS [c_monthly_exec_time], 
								tschM.c_exec_first_month_day, tschM.c_exec_last_month_day, tschM.c_skip_months
				FROM			t_export_schedule tsch 
				INNER JOIN		t_export_report_instance trpi ON tsch.id_rep_instance_id = trpi.id_rep_instance_id 
				INNER JOIN		t_export_reports trp ON trpi.id_rep = trp.id_rep 
				LEFT OUTER JOIN	t_sch_daily tschD ON tsch.id_schedule = tschD.id_schedule_daily 
				LEFT OUTER JOIN	t_sch_weekly tschW ON tsch.id_schedule = tschW.id_schedule_weekly 
				LEFT OUTER JOIN	t_sch_monthly tschM ON tsch.id_schedule = tschM.id_schedule_monthly
				WHERE tsch.id_rp_schedule = %%ID_RP_SCHEDULE%%
			