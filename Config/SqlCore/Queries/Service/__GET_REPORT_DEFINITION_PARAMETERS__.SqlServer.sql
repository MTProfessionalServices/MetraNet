
			SELECT		rp_prmnames.c_param_name     
			FROM		t_export_report_params rp_prms 
				INNER JOIN	t_export_param_names rp_prmnames
				ON rp_prms.id_param_name = rp_prmnames.id_param_name
			WHERE		rp_prms.id_rep = %%REPORT_ID%%
	