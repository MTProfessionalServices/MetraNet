
				SELECT 
					id_param_name as IDParameter, 
					REPLACE(c_param_name, '%', '') AS ParameterName,  
					NVL(c_param_desc, ' ') as ParameterDescription 
				FROM t_export_param_names 
					 WHERE id_param_name NOT IN 
					 (SELECT id_param_name FROM t_export_report_params WHERE id_rep = %%ID_REP%%)
                        