SELECT 
 acc.am_currency
,COALESCE(udrc.id_usage_interval, frc.id_usage_interval, nrc.id_usage_interval, nsc.id_usage_interval, acr.id_usage_interval, acc.id_usage_interval) as id_usage_interval
,CASE 
	WHEN adj.IsAdjustmentRow = 1 THEN adj.dt_modified
	ELSE COALESCE(udrc.c_RCIntervalSubscriptionStart, frc.c_RCIntervalSubscriptionStart, nrc.c_NRCIntervalSubscriptionStart, nsc.c_IssueTime, acr.c_CreditTime, acc.dt_crt) 
END as SubscriptionStart
,CASE 
	WHEN adj.IsAdjustmentRow = 1 THEN adj.dt_modified
	ELSE COALESCE(udrc.c_RCIntervalSubscriptionEnd, frc.c_RCIntervalSubscriptionEnd, nrc.c_NRCIntervalSubscriptionEnd, nsc.c_IssueTime, acr.c_CreditTime, acc.dt_crt) 
END as SubscriptionEnd
,COALESCE(udrc.c_ProratedIntervalStart, frc.c_ProratedIntervalStart) as c_ProratedIntervalStart
,COALESCE(udrc.c_ProratedIntervalEnd, frc.c_ProratedIntervalEnd) as c_ProratedIntervalEnd
,CASE 
	WHEN COALESCE(udrc.c_RCIntervalSubscriptionStart, frc.c_RCIntervalSubscriptionStart) IS NOT NULL
		THEN 30
	ELSE 1
 END as c_ProratedDays
,CASE 
	WHEN adj.IsAdjustmentRow = 1 THEN COALESCE(adj.AdjustmentAmount, 0) 
	+ COALESCE(adj.aj_tax_federal, 0) + COALESCE(adj.aj_tax_state, 0) + COALESCE(adj.aj_tax_county, 0) + COALESCE(adj.aj_tax_local, 0) + COALESCE(adj.aj_tax_other, 0)
	ELSE COALESCE(udrc.c_ProratedDailyRate, frc.c_ProratedDailyRate, acr.c_CreditAmount, acc.amount +
	+ COALESCE(acc.tax_federal, 0) + COALESCE(acc.tax_state, 0) + COALESCE(acc.tax_county, 0) + COALESCE(acc.tax_local, 0) + COALESCE(acc.tax_other, 0)) 
END as c_ProratedDailyRate
,COALESCE(udrc_ep.c_IsLiabilityProduct, frc_ep.c_IsLiabilityProduct, nrc_ep.c_IsLiabilityProduct, usg_ep.c_IsLiabilityProduct, dis_ep.c_IsLiabilityProduct, 'N') as c_IsLiabilityProduct
,COALESCE(udrc_ep.c_RevenueCode, frc_ep.c_RevenueCode, nrc_ep.c_RevenueCode, usg_ep.c_RevenueCode, dis_ep.c_RevenueCode, N'') as c_RevenueCode
,COALESCE(udrc_ep.c_DeferredRevenueCode, frc_ep.c_DeferredRevenueCode, nrc_ep.c_DeferredRevenueCode, usg_ep.c_DeferredRevenueCode, dis_ep.c_DeferredRevenueCode, N'') as c_DeferredRevenueCode
,acc.id_pi_template
FROM		t_acc_usage						acc
INNER JOIN	t_usage_interval				ui			ON acc.id_usage_interval = ui.id_interval
LEFT JOIN	t_pv_UDRecurringCharge			udrc		ON acc.id_sess = udrc.id_sess
LEFT JOIN	t_pv_FlatRecurringCharge		frc			ON acc.id_sess = frc.id_sess
LEFT JOIN	t_pv_NonRecurringCharge			nrc			ON acc.id_sess = nrc.id_sess
LEFT JOIN	t_pv_NonStandardCharge			nsc			ON acc.id_sess = nsc.id_sess
LEFT JOIN	t_pv_AccountCredit				acr			ON acc.id_sess = acr.id_sess
LEFT JOIN	(SELECT	adj_t.id_sess,
					adj_t.AdjustmentAmount,
					adj_t.dt_modified,
					adj_t.aj_tax_federal,
					adj_t.aj_tax_state,
					adj_t.aj_tax_county,
					adj_t.aj_tax_local,
					adj_t.aj_tax_other,
					x.IsAdjustmentRow
			FROM	t_adjustment_transaction adj_t
			CROSS JOIN (select 0 as IsAdjustmentRow from dual
						union 
						select 1 from dual) x		)	adj			ON acc.id_sess = adj.id_sess
LEFT JOIN	t_ep_unit_dependent_recurring	udrc_ep		ON udrc_ep.id_prop = acc.id_pi_template
LEFT JOIN	t_ep_recurring					frc_ep		ON frc_ep.id_prop = acc.id_pi_template
LEFT JOIN	t_ep_nonrecurring				nrc_ep		ON nrc_ep.id_prop = acc.id_pi_template
LEFT JOIN	t_ep_usage						usg_ep		ON usg_ep.id_prop = acc.id_pi_template
LEFT JOIN	t_ep_discount					dis_ep		ON dis_ep.id_prop = acc.id_pi_template
WHERE 	COALESCE(udrc_ep.c_IsLiabilityProduct, frc_ep.c_IsLiabilityProduct, nrc_ep.c_IsLiabilityProduct, usg_ep.c_IsLiabilityProduct, dis_ep.c_IsLiabilityProduct, 'N') = 'N'
	AND ('%%HARDCLOSED%%' = 'S' OR ui.tx_interval_status = 'H')
	AND	acc.am_currency like '%' || TRIM('%%CURRENCY%%') || '%'
	AND (COALESCE(udrc_ep.c_RevenueCode, frc_ep.c_RevenueCode, nrc_ep.c_RevenueCode, usg_ep.c_RevenueCode, dis_ep.c_RevenueCode)  like '%' || TRIM('%%REVENUECODE%%') || '%'
		OR (COALESCE(udrc_ep.c_RevenueCode, frc_ep.c_RevenueCode, nrc_ep.c_RevenueCode, usg_ep.c_RevenueCode, dis_ep.c_RevenueCode) IS NULL 
			AND TRIM('%%REVENUECODE%%') IS NULL)
	)
	AND (COALESCE(udrc_ep.c_DeferredRevenueCode, frc_ep.c_DeferredRevenueCode, nrc_ep.c_DeferredRevenueCode, usg_ep.c_DeferredRevenueCode, dis_ep.c_DeferredRevenueCode) like '%' || TRIM('%%DEFREVENUECODE%%') || '%'
		OR (COALESCE(udrc_ep.c_DeferredRevenueCode, frc_ep.c_DeferredRevenueCode, nrc_ep.c_DeferredRevenueCode, usg_ep.c_DeferredRevenueCode, dis_ep.c_DeferredRevenueCode) IS NULL 
			AND TRIM('%%DEFREVENUECODE%%') IS NULL)
	)
	AND	(%%PRODUCTID%% IS NULL OR (%%PRODUCTID%% IS NOT NULL AND acc.id_pi_template = %%PRODUCTID%%))
	AND (NOT EXISTS (select 1 from t_be_sys_rep_accountingcycle)
		OR
		('%%ACCOUNTINGCYCLEID%%' = '00000000-0000-0000-0000-000000000000'
			AND NOT EXISTS (	SELECT 1
								FROM t_be_sys_rep_accountingcycle dcycl
								INNER JOIN t_be_sys_rep_accountingcycl dcyclto ON dcycl.c_AccountingCycle_Id = dcyclto.c_AccountingCycle_Id
								INNER JOIN t_account_ancestor dtanc ON dtanc.id_ancestor = dcyclto.c_AccountId
								WHERE dtanc.id_descendent = acc.id_payee
								)
				)
		OR 
		EXISTS (SELECT 1
				FROM t_be_sys_rep_accountingcycle cycl
				LEFT JOIN t_be_sys_rep_accountingcycl cyclto ON cycl.c_AccountingCycle_Id = cyclto.c_AccountingCycle_Id
				LEFT JOIN t_account_ancestor tanc ON tanc.id_ancestor = cyclto.c_AccountId or cyclto.c_AccountId is NULL
				WHERE cycl.c_AccountingCycle_Id like '%%ACCOUNTINGCYCLEID%%'
				AND tanc.id_descendent = acc.id_payee
				AND (	(cycl.c_IsDefault = 'F' AND cyclto.c_AccountId IS NOT NULL)
						OR
						(cycl.c_IsDefault = 'T'	
							AND (cyclto.c_AccountId IS NOT NULL
									OR
										(cyclto.c_AccountId IS NULL
										AND NOT EXISTS (	SELECT 1
															FROM t_be_sys_rep_accountingcycle ncycl
															INNER JOIN t_be_sys_rep_accountingcycl ncyclto ON ncycl.c_AccountingCycle_Id = ncyclto.c_AccountingCycle_Id
															INNER JOIN t_account_ancestor ntanc ON ntanc.id_ancestor = ncyclto.c_AccountId
															WHERE ncycl.c_IsDefault = 'F'
															AND ntanc.id_descendent = acc.id_payee
															)
											)
									)
							)
					)
			)
	)
	