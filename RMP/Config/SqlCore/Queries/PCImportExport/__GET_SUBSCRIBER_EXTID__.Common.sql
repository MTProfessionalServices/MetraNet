
				SELECT map.nm_login nm_login, map.nm_space nm_space
				FROM t_account_mapper map, t_namespace ns
				WHERE map.id_acc = %%_ACCOUNTID%%
				AND map.nm_space = ns.nm_space
				AND tx_typ_space = 'system_mps'
			