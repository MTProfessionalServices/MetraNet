
			select top 200 a.id_audit, a.dt_queued, rp.id_rep, rp.c_report_desc, rp.c_report_title, c_xmlconfig_loc, 
					c_rep_destn, CAST(ISNULL(c_generate_control_file, 0) AS INT) AS [c_generate_control_file], 
					c_control_file_delivery_location, c_rep_distrib_type, c_rep_output_type,
					run_start_dt, run_end_dt, c_run_result_descr, c_execute_paraminfo, c_execution_backedout, c_output_file_name
			FROM t_export_execute_audit a inner join t_export_reports rp
			ON a.id_rep = rp.id_rep
			ORDER BY id_audit desc
	