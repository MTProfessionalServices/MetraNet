
				SELECT 
				/* Query Tag: __GET_CCT_ID_BY_NAME__ */
				cct.id_cap_type FROM t_composite_capability_type cct
    		WHERE %%%UPPER%%%(cct.tx_name) = %%%UPPER%%%(N'%%NAME%%')
    	