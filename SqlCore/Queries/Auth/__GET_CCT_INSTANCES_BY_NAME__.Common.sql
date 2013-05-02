
			SELECT
			/* Query Tag: __GET_CCT_INSTANCES_BY_NAME__ */
			ins.id_cap_instance FROM t_composite_capability_type cct 
			INNER JOIN t_capability_instance ins ON ins.id_cap_type = cct.id_cap_type
			WHERE %%%UPPER%%%(tx_name) = %%%UPPER%%%(N'%%NAME%%')
    	