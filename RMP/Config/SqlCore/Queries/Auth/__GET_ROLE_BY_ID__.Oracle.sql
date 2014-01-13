
				SELECT 
				/* Query Tag: __GET_ROLE_BY_ID__ */
				id_role, RAWTOHEX(tx_guid) tx_guid, tx_name, tx_desc, csr_assignable, subscriber_assignable
		    FROM t_role
		    WHERE id_role= %%ROLE_ID%%
    	