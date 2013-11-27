
		     select ed1.nm_enum_data as Operation, ed2.nm_enum_data as ServiceDefinition
          from t_account_type atype
          inner join t_account_type_servicedef_map sdmap
          	on atype.id_type = sdmap.id_type
          inner join t_enum_data ed1
	          on sdmap.operation = ed1.id_enum_data
	        inner join t_enum_data ed2 
		        on sdmap.id_service_def = ed2.id_enum_data
          where %%%UPPER%%%(atype.name) = %%%UPPER%%%('%%ACCOUNT_TYPE_NAME%%')
				