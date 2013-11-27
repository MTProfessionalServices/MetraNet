
				SELECT id_param_name, REPLACE(c_param_name, '%', '') AS c_param_name,  isnull(c_param_desc, ' ') as paramdesc FROM t_export_param_names
			