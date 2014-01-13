
        select commonlog.nm_table_name tablename
					/* __GET_COMMON_ACCOUNT_VIEW_TABLES__ */
          from t_account_type atype
          inner join t_account_type_view_map amap
          on atype.id_type = amap.id_type
          inner join t_enum_data ed
          on amap.id_account_view = ed.id_enum_data
          inner join t_account_view_log vl on %%%UPPER%%%(ed.nm_enum_data) = %%%UPPER%%%(vl.nm_account_view)
          inner join t_account_type common on common.id_type = atype.id_type
          inner join t_account_type_view_map commonviews on commonviews.id_type = common.id_type
          inner join t_enum_data commoned
          on commonviews.id_account_view = commoned.id_enum_data
          inner join t_account_view_log commonlog on %%%UPPER%%%(commoned.nm_enum_data) = %%%UPPER%%%(commonlog.nm_account_view)
          where %%%UPPER%%%(vl.nm_table_name) = %%%UPPER%%%('%%ACCOUNT_VIEW_TABLE_NAME%%')
          group by commonlog.nm_table_name
			