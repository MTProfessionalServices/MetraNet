
      	select  nm_table_name from t_service_def_log slog
				    inner join t_enum_data ed
				    on %%%UPPER%%%(slog.nm_service_def) = %%%UPPER%%%(ed.nm_enum_data)
				    where ed.id_enum_data = %%ID_SVC%%	
	  