
						SELECT 
							tschD.id_schedule_daily,
							tschD.c_exec_time,
							tschD.c_repeat_hour,
							tschD.c_exec_start_time,
							tschD.c_exec_end_time,
							CASE 
								WHEN tschD.c_skip_last_day_month = 0 THEN 'No'
								ELSE 'Yes'
							END AS skiplastdayofmonth,
							CASE 
								WHEN tschD.c_skip_first_day_month = 0 THEN 'No'
								ELSE 'Yes'
							END AS skipfirstdayofmonth,
							tschD.c_days_interval,
							CASE 
								WHEN tschD.c_month_to_date = 0 then 'No'
								ELSE 'Yes'
							END AS monthtodate
						FROM    t_export_schedule tsch
								INNER JOIN  t_sch_daily tschD ON tsch.id_schedule = tschD.id_schedule_daily 
									WHERE tsch.id_rp_schedule = %%ID_RP_SCHEDULE%%  AND  LOWER(tsch.c_sch_type) = N'daily'
                        