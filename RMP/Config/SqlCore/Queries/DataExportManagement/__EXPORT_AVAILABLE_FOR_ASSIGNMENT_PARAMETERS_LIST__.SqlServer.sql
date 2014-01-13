
				SELECT id_param_name as IDParameter, REPLACE(c_param_name, '%', '') AS ParameterName,  isnull(c_param_desc, ' ') as ParameterDescription 
				FROM t_export_param_names 
				WHERE id_param_name NOT IN 
				(select id_param_name from t_export_report_params where id_rep = %%ID_REP%%)
			