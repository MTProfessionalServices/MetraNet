
			  SELECT DISTINCT
				/* Query Tag: __GET_ROLE_ACTORS__ */
				pp.id_acc,
				map.nm_login
        ,map.nm_space
        ,map.displayname
        ,tav.c_folder
				FROM t_role r
				INNER JOIN t_policy_role pr ON  r.id_role = pr.id_role
				INNER JOIN t_principal_policy pp ON pr.id_policy = pp.id_policy
        INNER JOIN t_av_internal tav ON tav.id_acc = pp.id_acc
				LEFT OUTER JOIN VW_MPS_OR_SYSTEM_ACC_MAPPER map on pp.id_acc = map.id_acc
				WHERE %%%UPPER%%%(r.tx_name) = %%%UPPER%%%(N'%%NAME%%')
        AND pp.policy_type = '%%POLICY_TYPE%%'
    	