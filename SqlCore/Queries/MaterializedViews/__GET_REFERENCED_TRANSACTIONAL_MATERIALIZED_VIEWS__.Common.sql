
			SELECT DISTINCT bt.base_table_name FROM t_mview_catalog cat, t_mview_event ev, t_mview_base_tables bt WHERE cat.id_mv = ev.id_mv AND bt.id_event = ev.id_event
			AND cat.name='%%MATERIALIZED_VIEW_NAME%%' and bt.base_table_name IN (SELECT name from t_mview_catalog where update_mode='T')
		