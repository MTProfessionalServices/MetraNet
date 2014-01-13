
				select 
				/* Query Tag: __GET_ROLES_BY_NAME__ */
				id_role, tx_name, tx_desc, subscriber_assignable, csr_assignable FROM t_role
				WHERE %%%UPPER%%%(tx_name) = %%%UPPER%%%(N'%%NAME%%')
    	