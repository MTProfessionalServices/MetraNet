
			SELECT pn.id_param_name, pn.c_param_name, ISNULL(pn.c_param_desc,'') as [descr]
			FROM t_export_reports r 
			INNER JOIN t_export_report_params rp ON r.id_rep = rp.id_rep 
			INNER JOIN t_export_param_names pn ON rp.id_param_name = pn.id_param_name
			WHERE     (r.id_rep = %%ID_REP%%)
			ORDER BY r.id_rep, rp.id_param_name
	