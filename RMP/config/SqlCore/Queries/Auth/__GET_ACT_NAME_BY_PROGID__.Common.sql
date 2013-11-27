
				select 
				/* Query Tag: __GET_ACT_NAME_BY_PROGID__ */
				tx_name FROM t_atomic_capability_type 
				WHERE %%%UPPER%%%(tx_progid) = %%%UPPER%%%(N'%%PROGID%%')
    	