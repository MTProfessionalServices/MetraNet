
					SELECT tsch.id_rp_schedule, tsch.c_sch_type, tschD.c_exec_time
					FROM		t_export_schedule tsch 
					INNER JOIN	t_export_report_instance trpi ON tsch.id_rep_instance_id = trpi.id_rep_instance_id 
					INNER JOIN	t_export_reports trp ON trpi.id_rep = trp.id_rep 
					INNER JOIN	t_sch_daily tschD ON tsch.id_schedule = tschD.id_schedule_daily 
					WHERE 	tsch.id_rep_instance_id = %%ID_REP_INSTANCE%%
					AND 	tsch.c_sch_type = 'daily'
					UNION 
					SELECT tsch.id_rp_schedule, tsch.c_sch_type, tschW.c_exec_time
					FROM		t_export_schedule tsch 
					INNER JOIN	t_export_report_instance trpi ON tsch.id_rep_instance_id = trpi.id_rep_instance_id 
					INNER JOIN	t_export_reports trp ON trpi.id_rep = trp.id_rep 
					INNER JOIN	t_sch_weekly tschW ON tsch.id_schedule = tschW.id_schedule_weekly
					WHERE 	tsch.id_rep_instance_id = %%ID_REP_INSTANCE%%
					AND 	tsch.c_sch_type = 'weekly'
					UNION
					SELECT tsch.id_rp_schedule, tsch.c_sch_type, tschM.c_exec_time
					FROM		t_export_schedule tsch 
					INNER JOIN	t_export_report_instance trpi ON tsch.id_rep_instance_id = trpi.id_rep_instance_id 
					INNER JOIN	t_export_reports trp ON trpi.id_rep = trp.id_rep 
					INNER JOIN	t_sch_monthly tschM ON tsch.id_schedule = tschM.id_schedule_monthly
					WHERE 	tsch.id_rep_instance_id = %%ID_REP_INSTANCE%%
					AND 	tsch.c_sch_type = 'monthly'

			