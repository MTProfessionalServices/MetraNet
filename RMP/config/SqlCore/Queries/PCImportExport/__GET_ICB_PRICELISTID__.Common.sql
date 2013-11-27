
				SELECT id_pricelist
				FROM t_pl_map pm, t_account_mapper am
				WHERE pm.id_paramtable = %%PT_ID%%
				AND pm.id_acc = am.id_acc
				AND am.nm_login = '%%ALIAS%%'
				AND am.nm_space = '%%NAMESPACE%%'	
			