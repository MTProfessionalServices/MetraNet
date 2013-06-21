select %%SELECT_CLAUSE%%, au.id_view ViewID, au.id_sess SessionID, au.amount Amount, 
			  au.am_currency Currency, au.id_acc AccountID, au.dt_session Timestamp, '%%SESSION_TYPE%%' SessionType,
        (isnull((au.tax_federal), 0.0) + isnull((au.tax_state), 0.0) + isnull((au.tax_county), 0.0) + 
        isnull((au.tax_local), 0.0) + isnull((au.tax_other), 0.0)) TaxAmount, 
		isnull(au.Amount,0.0)  
			  /*If implied taxes, then taxes are already included, don't add them again */
			  + (CASE WHEN (au.is_implied_tax = 'N') THEN (isnull(au.Tax_Federal,0.0) + isnull(au.Tax_State,0.0) 
			      + isnull(au.Tax_County,0.0) + isnull(au.Tax_Local,0.0) + isnull(au.Tax_Other,0.0)) else 0 end) 
			  /*If informational taxes, then they shouldn't be in the total */
			  - (CASE WHEN (au.tax_informational = 'Y') THEN (isnull(au.Tax_Federal,0.0) + isnull(au.Tax_State,0.0) 
			      + isnull(au.Tax_County,0.0) + isnull(au.Tax_Local,0.0) + isnull(au.Tax_Other,0.0)) else 0 end) 
			   AmountWithTax,  
		%%INTERVAL_ID%% IntervalID
			  from %%TABLE_NAME%% pv, t_acc_usage au %%FROM_CLAUSE%% where 
			  au.id_parent_sess = %%PARENT_ID%% and au.id_acc = %%ACCOUNT_ID%% and au.id_usage_interval = %%INTERVAL_ID%% and
			au.id_view = %%VIEW_ID%% and au.id_sess = pv.id_sess 
			and au.id_usage_interval=pv.id_usage_interval %%WHERE_CLAUSE%% %%EXT%%