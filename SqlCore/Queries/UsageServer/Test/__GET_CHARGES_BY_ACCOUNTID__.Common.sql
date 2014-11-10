
SELECT
	 au.id_acc AccountId
	,ma.nm_login AccountUserName
	,au.id_payee PayeeId
	,mp.nm_login PayeeUserName
	,au.id_usage_interval UsageIntervalId
	,pv.nm_name ProductView
	,au.amount Amount
	,au.am_currency Currency
    ,au.dt_session SessionDate
FROM
	t_acc_usage au
	,t_prod_view pv
	,t_account_mapper ma
	,t_account_mapper mp
WHERE
	au.id_acc = %%ACCOUNT_ID%% 
	AND au.id_view = pv.id_view
	AND au.id_acc = ma.id_acc
	AND au.id_payee = mp.id_acc
