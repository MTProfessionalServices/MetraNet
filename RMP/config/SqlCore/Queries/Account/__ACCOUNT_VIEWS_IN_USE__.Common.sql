
		     select atype.name from t_account_view_log alog
	        inner join t_enum_data ed
						on lower(alog.nm_account_view) = lower(ed.nm_enum_data)
	        inner join t_account_type_view_map amap
						on amap.id_account_view = ed.id_enum_data
	        inner join t_account_type atype
						on atype.id_type = amap.id_type
	        where %%%UPPER%%%(alog.nm_account_view) = %%%UPPER%%%('%%ACCOUNT_VIEW_NAME%%')
	        and %%%UPPER%%%(atype.name) <> %%%UPPER%%%('%%ACCOUNT_TYPE_NAME%%')
			