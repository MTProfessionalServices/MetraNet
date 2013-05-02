
				
				/* SELECT * FROM t_sch_daily WHERE id_schedule_daily = %%ID_RP_SCHEDULE%% */


				SELECT 
				tschD.id_schedule_daily,
				tschD.c_exec_time,
				tschD.c_repeat_hour,
				tschD.c_exec_start_time,
				tschD.c_exec_end_time,
				case 
					when tschD.c_skip_last_day_month = 0 then 'No'
					else 'Yes'
				end as skiplastdayofmonth,
				case 
					when tschD.c_skip_first_day_month = 0 then 'No'
					else 'Yes'
				end as skipfirstdayofmonth,
				tschD.c_days_interval,
				case 
					when tschD.c_month_to_date = 0 then 'No'
					else 'Yes'
				end as monthtodate
				FROM	t_export_schedule tsch
                                        INNER JOIN	t_sch_daily tschD ON tsch.id_schedule = tschD.id_schedule_daily 

					WHERE tsch.id_rp_schedule = %%ID_RP_SCHEDULE%%
                                        AND 	tsch.c_sch_type = N'daily'

			