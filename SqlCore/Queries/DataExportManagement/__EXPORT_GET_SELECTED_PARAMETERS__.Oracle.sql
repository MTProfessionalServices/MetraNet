
				SELECT 
					id_param_name, 
					REPLACE(c_param_name, '%', '') AS c_param_name 
				FROM t_export_param_names
				  WHERE id_param_name IN (%%PARAMETER_IDS%%)	
                        