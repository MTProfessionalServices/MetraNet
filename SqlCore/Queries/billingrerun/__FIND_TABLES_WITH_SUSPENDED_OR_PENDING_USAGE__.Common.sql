
 select distinct ss.id_svc, ed.nm_enum_data, slog.nm_table_name
    from t_message msg %%%READCOMMITTED%%%
    inner join t_session_set ss %%%READCOMMITTED%%%
    on msg.id_message = ss.id_message
    inner join t_enum_data ed
    on ed.id_enum_data = ss.id_svc
    inner join t_service_def_log slog
    on slog.nm_service_def = ed.nm_enum_data 
  %%WHERE_CLAUSE%%
  