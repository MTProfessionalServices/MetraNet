
			SELECT
			/* Query Tag: __GET_ACT_INSTANCES_BY_NAME__ */
			ins.id_cap_instance FROM t_atomic_capability_type act 
			INNER JOIN t_capability_instance ins ON ins.id_cap_type = act.id_cap_type
			WHERE %%%UPPER%%%(tx_name) = %%%UPPER%%%(N'%%NAME%%')
    	