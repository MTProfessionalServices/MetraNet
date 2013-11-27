
		select nm_table_name from t_service_def_log 
		where %%%UPPER%%%(nm_service_def) = %%%UPPER%%%(N'%%SERVICE_DEF_NAME%%')
		