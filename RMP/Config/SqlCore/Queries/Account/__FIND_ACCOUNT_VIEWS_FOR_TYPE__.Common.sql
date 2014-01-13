
		     select ed.nm_enum_data as AccountView
          from t_account_type atype
          inner join t_account_type_view_map amap
          on atype.id_type = amap.id_type
          inner join t_enum_data ed
          on amap.id_account_view = ed.id_enum_data
          where %%%UPPER%%%(atype.name) = %%%UPPER%%%('%%ACCOUNT_TYPE_NAME%%')
			