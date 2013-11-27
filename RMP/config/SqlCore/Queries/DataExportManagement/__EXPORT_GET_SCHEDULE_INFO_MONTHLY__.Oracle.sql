
					SELECT
                        tschM.id_schedule_monthly,
                        tschM.c_exec_day,
                        tschM.c_exec_time,
						CASE 
							WHEN tschM.c_exec_first_month_day = 0 then 'No'
							ELSE 'Yes'
						END as c_exec_first_month_day,
						CASE 
							WHEN tschM.c_exec_last_month_day = 0 then 'No'
							ELSE 'Yes'
						END as c_exec_last_month_day,
                        CASE 
							WHEN tschM.c_skip_months like '%01%' then 'Yes'
							ELSE 'No'
						END as dbSkipJanuary,
                        CASE 
							WHEN tschM.c_skip_months like '%02%' then 'Yes'
							ELSE 'No'
						END as dbSkipFebruary,
                        CASE 
							WHEN tschM.c_skip_months like '%03%' then 'Yes'
							ELSE 'No'
						END as dbSkipMarch,
                        CASE 
							WHEN tschM.c_skip_months like '%04%' then 'Yes'
							ELSE 'No'
						END as dbSkipApril,
                        CASE 
							WHEN tschM.c_skip_months like '%05%' then 'Yes'
							ELSE 'No'
						END as dbSkipMay,
                        CASE 
							WHEN tschM.c_skip_months like '%06%' then 'Yes'
							ELSE 'No'
						END as dbSkipJune,
                        CASE 
							WHEN tschM.c_skip_months like '%07%' then 'Yes'
							ELSE 'No'
						END as dbSkipJuly,
                        CASE 
							WHEN tschM.c_skip_months like '%08%' then 'Yes'
							ELSE 'No'
						END as dbSkipAugust,
                        CASE 
							WHEN tschM.c_skip_months like '%09%' then 'Yes'
							ELSE 'No'
						END as dbSkipSeptember,
                        CASE 
							WHEN tschM.c_skip_months like '%10%' then 'Yes'
							ELSE 'No'
						END as dbSkipOctober,
                        CASE 
							WHEN tschM.c_skip_months like '%11%' then 'Yes'
							ELSE 'No'
						END as dbSkipNovember,
                        CASE 
							WHEN tschM.c_skip_months like '%12%' then 'Yes'
							ELSE 'No'
						END as dbSkipDecember
					FROM    t_export_schedule tsch
                        INNER JOIN  t_sch_monthly tschM ON tsch.id_schedule = tschM.id_schedule_monthly 
						WHERE tsch.id_rp_schedule = %%ID_RP_SCHEDULE%% AND LOWER(tsch.c_sch_type) = N'monthly'
                        