
		  select id_service_def,nm_service_def,nm_table_name from t_service_def_log WHERE %%%UPPER%%%(nm_service_def) = %%%UPPER%%%(N'%%SDEF_NAME%%')
	  