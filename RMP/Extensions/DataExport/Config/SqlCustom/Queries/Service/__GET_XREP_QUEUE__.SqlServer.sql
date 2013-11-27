
			select 	rp.id_rep, rp.c_report_title, rp.c_report_desc, q.dt_queued, q.dt_sched_run,
					c_current_process_stage, c_processing_server, c_param_name_values, q.c_ds_id,
					c_rep_output_type, c_rep_destn, CAST(ISNULL(c_generate_control_file, 0) AS INT) AS [c_generate_control_file], 
					c_control_file_delivery_location, c_rep_distrib_type
			from		t_export_workqueue q 
			inner join	t_export_reports rp on q.id_rep = rp.id_rep
	