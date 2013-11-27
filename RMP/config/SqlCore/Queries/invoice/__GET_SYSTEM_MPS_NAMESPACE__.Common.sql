
		  select am.nm_space from t_account_mapper am,t_namespace ns
		  where am.id_acc=%%ACCOUNT_ID%% and %%%UPPER%%%(am.nm_space)=%%%UPPER%%%(ns.nm_space) and %%%UPPER%%%(ns.tx_typ_space)=%%%UPPER%%%('system_mps')
	  