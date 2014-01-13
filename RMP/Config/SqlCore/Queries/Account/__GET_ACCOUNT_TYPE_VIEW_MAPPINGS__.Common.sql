
		      select vl.nm_table_name tablename, upper(name) as name, ed.nm_enum_data as AccountView
          from t_account_type atype
          inner join t_account_type_view_map amap
          on atype.id_type = amap.id_type
          inner join t_enum_data ed
          on amap.id_account_view = ed.id_enum_data
          inner join t_account_view_log vl on %%%UPPER%%%(ed.nm_enum_data) = %%%UPPER%%%(vl.nm_account_view)
			