
				SELECT 
				/* Query Tag: __GET_ROLE_ID_BY_NAME__ */
				id_role FROM t_role
    		WHERE %%%UPPER%%%(tx_name) = %%%UPPER%%%(N'%%NAME%%')
    	