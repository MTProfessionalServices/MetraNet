
				select 
				/* Query Tag: __GET_CCT_NAME_BY_PROGID__ */
				tx_name FROM t_composite_capability_type 
				WHERE %%%UPPER%%%(tx_progid) = %%%UPPER%%%(N'%%PROGID%%')
    	