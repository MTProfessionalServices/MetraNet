
				select 
				/* Query Tag: __GET_CCTS_BY_NAME__ */
				id_cap_type, tx_name, tx_progid FROM t_composite_capability_type 
				WHERE %%%UPPER%%%(tx_name) = %%%UPPER%%%(N'%%NAME%%')
    	