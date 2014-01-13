
       select atypedesc.name as AccountTypeName, ed.nm_enum_data as Operation from 
        t_acctype_descendenttype_map descmap
          inner join t_account_type atype
          on descmap.id_type = atype.id_type
          inner join t_account_type atypedesc
          on atypedesc.id_type = descmap.id_descendent_type
          inner join t_account_type_servicedef_map svcmap
          on svcmap.id_type = descmap.id_descendent_type
          inner join t_enum_data ed
          on ed.id_enum_data = svcmap.operation 
            where %%%UPPER%%%(atype.name) = %%%UPPER%%%('%%ACCOUNT_TYPE_NAME%%')
            and %%%UPPER%%%(ed.nm_enum_data) = %%%UPPER%%%('%%OPERATION%%')
			