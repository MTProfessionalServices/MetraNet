
				SELECT 
					/* Query Tag: __GET_ROLES_BY_POLICY__ */
					t_role.id_role, tx_guid, tx_name, tx_desc 
					FROM t_role  
					INNER JOIN t_policy_role ON t_role.id_role = t_policy_role.id_role WHERE id_policy = %%ID_POLICY%%
    	