
			SELECT		pn.id_param_name, pn.c_param_name, rp.descr, trpd.c_param_value
			FROM		t_export_reports r 
			INNER JOIN	t_export_report_params rp ON r.id_rep = rp.id_rep 
			INNER JOIN	t_export_param_names pn ON rp.id_param_name = pn.id_param_name 
			INNER JOIN	t_export_report_instance trpi ON r.id_rep = trpi.id_rep 
			LEFT OUTER JOIN	t_export_default_param_values trpd ON rp.id_param_name = trpd.id_param_name 
					AND trpi.id_rep_instance_id = trpd.id_rep_instance_id
			WHERE     (r.id_rep = %%ID_REP%%) AND (trpi.id_rep_instance_id = %%ID_REP_INSTANCE%%)
	