
				select 
				/* Query Tag: __GET_ACTS_BY_NAME__ */
				id_cap_type, tx_name, tx_progid FROM t_atomic_capability_type 
				WHERE %%%UPPER%%%(tx_name) = %%%UPPER%%%(N'%%NAME%%')
    	