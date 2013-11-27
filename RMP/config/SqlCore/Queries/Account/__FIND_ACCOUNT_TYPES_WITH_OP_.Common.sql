
       select atype.name as AccountTypeName, ed.nm_enum_data as Operation from 
        t_account_type_servicedef_map map
        inner join t_enum_data ed
        on ed.id_enum_data = map.operation
        inner join t_account_type atype
        on atype.id_type = map.id_type
        where %%%UPPER%%%(ed.nm_enum_data) = %%%UPPER%%%('%%OPERATION%%')
			