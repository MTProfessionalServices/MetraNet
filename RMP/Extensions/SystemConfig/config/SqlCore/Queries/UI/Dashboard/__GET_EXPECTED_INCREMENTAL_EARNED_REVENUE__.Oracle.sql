SELECT 
	acc.am_currency
	,udrc.id_usage_interval
	,udrc.c_RCIntervalSubscriptionStart AS SubscriptionStart
	,udrc.c_RCIntervalSubscriptionEnd AS SubscriptionEnd
	,udrc.c_ProratedIntervalStart
	,udrc.c_ProratedIntervalEnd
	,1 as c_ProratedDays
	,udrc.c_ProratedDailyRate
	,udrc_ep.c_IsLiabilityProduct
	,udrc_ep.c_RevenueCode
	,udrc_ep.c_DeferredRevenueCode
	,acc.id_pi_template
FROM t_pv_UDRecurringCharge udrc
INNER JOIN t_acc_usage acc ON udrc.id_sess = acc.id_sess
INNER JOIN t_usage_interval ui ON acc.id_usage_interval = ui.id_interval
LEFT JOIN t_ep_unit_dependent_recurring udrc_ep ON udrc_ep.id_prop = acc.id_pi_template
WHERE c_RCIntervalSubscriptionStart <= %%START_DATE%%
	AND ui.tx_interval_status = 'H'
	AND udrc_ep.c_IsLiabilityProduct = 'N'
  AND acc.am_currency like '%' + '%%CURRENCY%%' + '%'
	AND udrc_ep.c_RevenueCode like '%' + '%%REVENUECODE%%' + '%'
	AND udrc_ep.c_DeferredRevenueCode like '%' + '%%DEFREVENUECODE%%' + '%'
	AND (%%PRODUCTID%% IS NULL OR (%%PRODUCTID%% IS NOT NULL AND acc.id_pi_template = %%PRODUCTID%%))
	AND (NOT EXISTS (select 1 from t_be_sys_rep_accountingcycle)
			OR
			EXISTS (
				SELECT 1
			  FROM t_be_sys_rep_accountingcycle cycl
			  LEFT JOIN t_be_sys_rep_accountingcycl cyclto ON cycl.c_AccountingCycle_Id = cyclto.c_AccountingCycle_Id
			  LEFT JOIN t_account_ancestor tanc ON tanc.id_ancestor = cyclto.c_AccountId or cyclto.c_AccountId is NULL
			  WHERE cycl.c_AccountingCycle_Id = '%%ACCOUNTINGCYCLEID%%'
			  AND tanc.id_descendent = acc.id_payee
			  AND (
						cycl.c_IsDefault = 'T' 
						AND (cyclto.c_AccountId IS NOT NULL
								OR
								(cyclto.c_AccountId IS NULL
									AND
									NOT EXISTS (
											SELECT 1
										  FROM t_be_sys_rep_accountingcycle iNcycl
										  INNER JOIN t_be_sys_rep_accountingcycl iNcyclto ON iNcycl.c_AccountingCycle_Id = iNcyclto.c_AccountingCycle_Id
										  INNER JOIN t_account_ancestor iNtanc ON iNtanc.id_ancestor = iNcyclto.c_AccountId
										  WHERE iNcycl.c_IsDefault = 'F'
										  AND iNtanc.id_descendent = acc.id_payee
										)
								)
								)
						)
		  			OR (cycl.c_IsDefault = 'F' AND cyclto.c_AccountId IS NOT NULL)
		  ))

UNION

SELECT 
	acc.am_currency
	,frc.id_usage_interval
	,frc.c_RCIntervalSubscriptionStart AS SubscriptionStart
	,frc.c_RCIntervalSubscriptionEnd AS SubscriptionEnd
	,frc.c_ProratedIntervalStart
	,frc.c_ProratedIntervalEnd
	,1 as c_ProratedDays
	,frc.c_ProratedDailyRate
	,frc_ep.c_IsLiabilityProduct
	,frc_ep.c_RevenueCode
	,frc_ep.c_DeferredRevenueCode
	,acc.id_pi_template
FROM t_pv_FlatRecurringCharge frc
INNER JOIN t_acc_usage acc ON frc.id_sess = acc.id_sess
INNER JOIN t_usage_interval ui ON acc.id_usage_interval = ui.id_interval
LEFT JOIN t_ep_recurring frc_ep ON frc_ep.id_prop = acc.id_pi_template
WHERE c_RCIntervalSubscriptionStart <= %%START_DATE%%
	AND ui.tx_interval_status = 'H'
	AND frc_ep.c_IsLiabilityProduct = 'N'
	AND acc.am_currency like '%' + '%%CURRENCY%%' + '%'
	AND frc_ep.c_RevenueCode like '%' + '%%REVENUECODE%%' + '%'
	AND frc_ep.c_DeferredRevenueCode like '%' + '%%DEFREVENUECODE%%' + '%'
	AND (%%PRODUCTID%% IS NULL OR (%%PRODUCTID%% IS NOT NULL AND acc.id_pi_template = %%PRODUCTID%%))
	AND (NOT EXISTS (select 1 from t_be_sys_rep_accountingcycle)
			OR
			EXISTS (
				SELECT 1
			  FROM t_be_sys_rep_accountingcycle cycl
			  LEFT JOIN t_be_sys_rep_accountingcycl cyclto ON cycl.c_AccountingCycle_Id = cyclto.c_AccountingCycle_Id
			  LEFT JOIN t_account_ancestor tanc ON tanc.id_ancestor = cyclto.c_AccountId or cyclto.c_AccountId is NULL
			  WHERE cycl.c_AccountingCycle_Id = '%%ACCOUNTINGCYCLEID%%'
			  AND tanc.id_descendent = acc.id_payee
			  AND (
						cycl.c_IsDefault = 'T' 
						AND (cyclto.c_AccountId IS NOT NULL
								OR
								(cyclto.c_AccountId IS NULL
									AND
									NOT EXISTS (
											SELECT 1
										  FROM t_be_sys_rep_accountingcycle iNcycl
										  INNER JOIN t_be_sys_rep_accountingcycl iNcyclto ON iNcycl.c_AccountingCycle_Id = iNcyclto.c_AccountingCycle_Id
										  INNER JOIN t_account_ancestor iNtanc ON iNtanc.id_ancestor = iNcyclto.c_AccountId
										  WHERE iNcycl.c_IsDefault = 'F'
										  AND iNtanc.id_descendent = acc.id_payee
										)
								)
								)
						)
		  			OR (cycl.c_IsDefault = 'F' AND cyclto.c_AccountId IS NOT NULL)
		  ))

UNION

SELECT 
	acc.am_currency
	,nrc.id_usage_interval
	,nrc.c_NRCIntervalSubscriptionStart AS SubscriptionStart
	,nrc.c_NRCIntervalSubscriptionEnd AS SubscriptionEnd
	,NULL AS c_ProratedIntervalStart
	,NULL AS c_ProratedIntervalEnd
	,1 AS c_ProratedDays
	,acc.amount AS c_ProratedDailyRate
	,nrc_ep.c_IsLiabilityProduct
	,nrc_ep.c_RevenueCode
	,nrc_ep.c_DeferredRevenueCode
	,acc.id_pi_template
FROM t_pv_NonRecurringCharge nrc
INNER JOIN t_acc_usage acc ON nrc.id_sess = acc.id_sess
INNER JOIN t_usage_interval ui ON acc.id_usage_interval = ui.id_interval
LEFT JOIN t_ep_nonrecurring nrc_ep ON nrc_ep.id_prop = acc.id_pi_template
WHERE
	c_NRCIntervalSubscriptionStart >= %%START_DATE%%
	AND ui.tx_interval_status = 'H'
	AND (nrc_ep.c_IsLiabilityProduct = 'N' OR nrc_ep.c_IsLiabilityProduct IS NULL)
	AND acc.am_currency like '%' + '%%CURRENCY%%' + '%'
	AND nrc_ep.c_RevenueCode like '%' + '%%REVENUECODE%%' + '%'
	AND nrc_ep.c_DeferredRevenueCode like '%' + '%%DEFREVENUECODE%%' + '%'
	AND (%%PRODUCTID%% IS NULL OR (%%PRODUCTID%% IS NOT NULL AND acc.id_pi_template = %%PRODUCTID%%))
	AND (NOT EXISTS (select 1 from t_be_sys_rep_accountingcycle)
			OR
			EXISTS (
				SELECT 1
			  FROM t_be_sys_rep_accountingcycle cycl
			  LEFT JOIN t_be_sys_rep_accountingcycl cyclto ON cycl.c_AccountingCycle_Id = cyclto.c_AccountingCycle_Id
			  LEFT JOIN t_account_ancestor tanc ON tanc.id_ancestor = cyclto.c_AccountId or cyclto.c_AccountId is NULL
			  WHERE cycl.c_AccountingCycle_Id = '%%ACCOUNTINGCYCLEID%%'
			  AND tanc.id_descendent = acc.id_payee
			  AND (
						cycl.c_IsDefault = 'T' 
						AND (cyclto.c_AccountId IS NOT NULL
								OR
								(cyclto.c_AccountId IS NULL
									AND
									NOT EXISTS (
											SELECT 1
										  FROM t_be_sys_rep_accountingcycle iNcycl
										  INNER JOIN t_be_sys_rep_accountingcycl iNcyclto ON iNcycl.c_AccountingCycle_Id = iNcyclto.c_AccountingCycle_Id
										  INNER JOIN t_account_ancestor iNtanc ON iNtanc.id_ancestor = iNcyclto.c_AccountId
										  WHERE iNcycl.c_IsDefault = 'F'
										  AND iNtanc.id_descendent = acc.id_payee
										)
								)
								)
						)
		  			OR (cycl.c_IsDefault = 'F' AND cyclto.c_AccountId IS NOT NULL)
		  ))