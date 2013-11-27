
				SELECT 
				/* Query Tag: __GET_ACT_ID_BY_NAME__ */
				act.id_cap_type FROM t_atomic_capability_type act
    		WHERE %%%UPPER%%%(act.tx_name) = %%%UPPER%%%(N'%%NAME%%')
    	