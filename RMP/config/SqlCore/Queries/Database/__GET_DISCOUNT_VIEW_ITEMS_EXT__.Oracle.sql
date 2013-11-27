
				select %%SELECT_CLAUSE%%, au.id_sess SessionID,
				(nvl(pv.c_DiscountAmount, 0.0) + nvl(pv.c_DiscountTaxAmount, 0.0)) AmountWithTax,
				au.am_currency Currency, au.id_acc AccountID, au.dt_session Timestamp,
				'Extended' SessionType, %%INTERVAL_ID%% IntervalID from %%TABLE_NAME%% pv,
				t_acc_usage au where au.id_acc = %%ACCOUNT_ID%% and
				au.id_usage_interval = %%INTERVAL_ID%% and au.id_sess = pv.id_sess and au.id_usage_interval=pv.id_usage_interval %%EXT%%
			