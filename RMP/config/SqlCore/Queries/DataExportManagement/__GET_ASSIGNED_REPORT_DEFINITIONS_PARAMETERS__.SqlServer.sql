
			SELECT pn.id_param_name as IDParameter, replace(pn.c_param_name,'%','') as ParameterName,  ISNULL(pn.c_param_desc,'') as ParameterDescription,
			r.id_rep IDReport
			FROM t_export_reports r 
			INNER JOIN t_export_report_params rp ON r.id_rep = rp.id_rep 
			INNER JOIN t_export_param_names pn ON rp.id_param_name = pn.id_param_name
			WHERE r.id_rep = %%ID_REP%%

	