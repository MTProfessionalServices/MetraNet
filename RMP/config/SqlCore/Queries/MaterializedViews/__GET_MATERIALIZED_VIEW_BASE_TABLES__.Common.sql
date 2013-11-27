
			SELECT DISTINCT bt.base_table_name
			FROM t_mview_catalog cat
			inner join t_mview_event ev on cat.id_mv = ev.id_mv
			inner join t_mview_base_tables bt on bt.id_event = ev.id_event
			where lower(bt.base_table_name) IN (%%TABLE_NAME_LIST%%)
			and cat.update_mode <> 'O'
			