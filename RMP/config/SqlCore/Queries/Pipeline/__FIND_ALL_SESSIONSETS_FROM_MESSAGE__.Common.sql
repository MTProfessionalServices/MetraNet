
      select s2.id_ss, s2.id_svc, ed.id_enum_data, slog.nm_table_name
				from t_session_set s2 
				inner join t_enum_data ed
					on s2.id_svc = ed.id_enum_data
				inner join t_service_def_log slog
					on %%%UPPER%%%(ed.nm_enum_data) = %%%UPPER%%%(slog.nm_service_def)
				where id_message in ( 
					select msg.id_message 
						from t_session_set ss
						inner join t_message msg
							on ss.id_message = msg.id_message
					where id_ss = %%SESSION_SET%%)
			