
			SELECT DISTINCT bt.base_table_name, 'N' as is_materialized_view
				FROM t_mview_catalog cat, t_mview_event ev, t_mview_base_tables bt
				WHERE cat.id_mv = ev.id_mv AND bt.id_event = ev.id_event AND cat.name='%%MATERIALIZED_VIEW_NAME%%'
				and bt.base_table_name NOT IN (SELECT table_name from t_mview_catalog)
			UNION
				SELECT DISTINCT bt.base_table_name, 'Y' as is_materialized_view 
				FROM t_mview_catalog cat, t_mview_event ev, t_mview_base_tables bt
				WHERE cat.id_mv = ev.id_mv AND bt.id_event = ev.id_event AND cat.name='%%MATERIALIZED_VIEW_NAME%%'
				and bt.base_table_name IN (SELECT table_name from t_mview_catalog)
			ORDER BY 1 ASC
		