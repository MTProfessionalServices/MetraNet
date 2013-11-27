
	  SELECT DISTINCT
	     am.nm_space 
	  FROM 
	     t_acc_usage_interval aui,
	     t_account_mapper am,
	     t_namespace ns 
	  WHERE 
	   aui.id_acc = am.id_acc AND
	   aui.id_usage_interval = %%INTERVAL_ID%% AND 
		 am.nm_space = ns.nm_space AND 
		 ns.tx_typ_space='system_mps' 
	  