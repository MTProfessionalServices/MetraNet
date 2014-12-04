		SELECT 
			am.nm_login, am.nm_space 
		FROM 
			t_account_mapper am 
			INNER JOIN t_namespace ns ON ns.nm_space = am.nm_space
		WHERE 
			am.id_acc = %%ID%%
		/* this order by is to ensure that alias account (if any) always comes at the end */ 
		ORDER BY 
			ns.tx_typ_space DESC
				