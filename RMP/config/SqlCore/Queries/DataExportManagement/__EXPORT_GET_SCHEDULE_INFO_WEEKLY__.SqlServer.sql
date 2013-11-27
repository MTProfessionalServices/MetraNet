
				
				/* SELECT * FROM t_sch_weekly WHERE id_schedule_weekly = %%ID_RP_SCHEDULE%% */

				SELECT
				tschW.id_schedule_weekly,
				tschW.c_exec_time,
				tschW.c_exec_week_days,
				/* for parsing skip week days string */
				CASE 
				WHEN tschw.c_skip_week_days like '%SUN%' then 'Yes'
				ELSE 'No'
				END as dbSkipSunday,
				CASE 
				WHEN tschw.c_skip_week_days like '%MON%' then 'Yes'
				ELSE 'No'
				END as dbSkipMonday,
				CASE 
				WHEN tschw.c_skip_week_days like '%TUE%' then 'Yes'
				ELSE 'No'
				END as dbSkipTuesday,
				CASE 
				WHEN tschw.c_skip_week_days like '%WED%' then 'Yes'
				ELSE 'No'
				END as dbSkipWednesday,
				CASE 
				WHEN tschw.c_skip_week_days like '%THU%' then 'Yes'
				ELSE 'No'
				END as dbSkipThursday,
				CASE 
				WHEN tschw.c_skip_week_days like '%FRI%' then 'Yes'
				ELSE 'No'
				END as dbSkipFriday,
				CASE 
				WHEN tschw.c_skip_week_days like '%SAT%' then 'Yes'
				ELSE 'No'
				END as dbSkipSaturday,
				CASE 
				WHEN tschW.c_month_to_date = 0 then 'No'
				ELSE 'Yes'
				END as monthtodate
				FROM	t_export_schedule tsch
				INNER JOIN	t_sch_weekly tschW ON tsch.id_schedule = tschW.id_schedule_weekly
				WHERE tsch.id_rp_schedule = %%ID_RP_SCHEDULE%%
                                        AND 	tsch.c_sch_type = N'weekly'
			