	
			SELECT		rp_prms.id_rep, tpdfv.id_rep_instance_id, rp_names.c_param_name, tpdfv.c_param_value
			FROM		t_export_report_params rp_prms 
				INNER JOIN	t_export_param_names rp_names ON rp_prms.id_param_name = rp_names.id_param_name 
				INNER JOIN	t_export_default_param_values tpdfv ON rp_prms.id_param_name = tpdfv.id_param_name
			WHERE     	rp_prms.id_rep = %%REPORT_ID%%
				AND 		tpdfv.id_rep_instance_id = %%REPORT_INSTANCE_ID%%
	