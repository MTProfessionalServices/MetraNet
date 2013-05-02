select %%SELECT_CLAUSE%%, au.id_view ViewID, au.id_sess SessionID, au.amount Amount,
			  au.am_currency Currency, au.id_acc AccountID, au.dt_session Timestamp, '%%SESSION_TYPE%%' SessionType,
        (isnull((au.tax_federal), 0.0) + isnull((au.tax_state), 0.0) + isnull((au.tax_county), 0.0) + 
        isnull((au.tax_local), 0.0) + isnull((au.tax_other), 0.0)) TaxAmount, (au.amount + 
        isnull((au.tax_federal), 0.0) + isnull((au.tax_state), 0.0) + isnull((au.tax_county), 0.0) + 
        isnull((au.tax_local), 0.0) + isnull((au.tax_other), 0.0)) AmountWithTax, %%INTERVAL_ID%% IntervalID
			  from %%TABLE_NAME%% pv, t_acc_usage au %%FROM_CLAUSE%% where 
			  au.id_acc = %%ACCOUNT_ID%% and au.id_usage_interval = %%INTERVAL_ID%% and au.id_view = %%VIEW_ID%% and 
			  au.id_sess = pv.id_sess
			  and au.id_usage_interval=pv.id_usage_interval
			  and au.id_parent_sess is NULL AND au.id_pi_instance %%INSTANCE_ID%% 
				%%WHERE_CLAUSE%% %%EXT%%