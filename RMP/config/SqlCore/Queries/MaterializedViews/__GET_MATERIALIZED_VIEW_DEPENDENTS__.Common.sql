
			SELECT mv_name, MAX(global_index) as gindex from t_mview_map where base_table_name in (%%TABLE_NAME_LIST%%)
			GROUP BY mv_name ORDER BY gindex
		