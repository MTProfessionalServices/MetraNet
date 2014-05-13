
      select au.id_acc AccountId, au.id_payee PayeeId, au.id_usage_interval UsageIntervalId, 
	  pv.nm_name ProductView, au.amount Amount, au.am_currency Currency	
	  from t_acc_usage au, t_prod_view pv 
	  where 
	  id_acc = %%ACCOUNT_ID%% and au.id_view = pv.id_view
        