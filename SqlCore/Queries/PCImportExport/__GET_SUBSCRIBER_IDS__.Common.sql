
        SELECT DISTINCT sub.id_acc, sub.id_sub, map.nm_login nm_login, 
	        map.nm_space nm_space, 
	        case when plmap.id_sub is null then 0
		        else plmap.id_sub end hasICBMappings
        FROM t_sub sub
        join t_account_mapper map
	        on sub.id_acc = map.id_acc
        join t_namespace ns
	        on map.nm_space = ns.nm_space
        left outer join t_pl_map plmap
	        on sub.id_sub = plmap.id_sub
        where tx_typ_space = 'system_mps'
			