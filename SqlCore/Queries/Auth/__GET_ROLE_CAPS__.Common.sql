
			  SELECT
				/* Query Tag: __GET_ROLE_CAPS__ */
				ci.id_cap_type
				FROM t_role r
				INNER JOIN t_principal_policy pp ON r.id_role = pp.id_role
        INNER JOIN t_capability_instance ci ON ci.id_policy = pp.id_policy
        WHERE %%%UPPER%%%(r.tx_name) = %%%UPPER%%%(N'%%NAME%%')
        AND pp.policy_type = 'A'
    	