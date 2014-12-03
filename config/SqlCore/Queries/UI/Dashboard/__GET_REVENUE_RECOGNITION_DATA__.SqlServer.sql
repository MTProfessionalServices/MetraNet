DECLARE @startDate datetime = CAST(CAST(DATEADD(DAY, 1, '%%START_DATE%%')AS DATE) AS DATETIME)
DECLARE @endDate datetime = CAST(CAST(DATEADD(DAY, 1, '%%END_DATE%%')AS DATE) AS DATETIME)

SELECT 
 acc.am_currency
,COALESCE(udrc.id_usage_interval, frc.id_usage_interval, nrc.id_usage_interval, nsc.id_usage_interval, acr.id_usage_interval, acc.id_usage_interval) as id_usage_interval
,COALESCE(udrc.c_RCIntervalSubscriptionStart, frc.c_RCIntervalSubscriptionStart, nrc.c_NRCIntervalSubscriptionStart, nsc.c_IssueTime, acr.c_CreditTime, acc.dt_crt) as SubscriptionStart
,COALESCE(udrc.c_RCIntervalSubscriptionEnd, frc.c_RCIntervalSubscriptionEnd, nrc.c_NRCIntervalSubscriptionEnd, nsc.c_IssueTime, acr.c_CreditTime, acc.dt_crt) as SubscriptionEnd
,COALESCE(udrc.c_ProratedIntervalStart, frc.c_ProratedIntervalStart) as c_ProratedIntervalStart
,COALESCE(udrc.c_ProratedIntervalEnd, frc.c_ProratedIntervalEnd) as c_ProratedIntervalEnd
,CASE 
	WHEN udrc.c_RCIntervalSubscriptionStart > @endDate
		THEN DATEDIFF(DAY, udrc.c_RCIntervalSubscriptionStart, udrc.c_RCIntervalSubscriptionEnd)+1
	WHEN udrc.c_RCIntervalSubscriptionStart <= @endDate
		THEN DATEDIFF(DAY, @endDate, udrc.c_RCIntervalSubscriptionEnd)+1
	WHEN frc.c_RCIntervalSubscriptionStart > @endDate
		THEN DATEDIFF(DAY, frc.c_RCIntervalSubscriptionStart, frc.c_RCIntervalSubscriptionEnd)+1
	WHEN frc.c_RCIntervalSubscriptionStart <= @endDate
		THEN DATEDIFF(DAY, @endDate, frc.c_RCIntervalSubscriptionEnd)+1
	ELSE 1
 END as c_ProratedDays
,COALESCE(udrc.c_ProratedDailyRate, frc.c_ProratedDailyRate, acr.c_CreditAmount, acc.amount) as c_ProratedDailyRate
,COALESCE(udrc_ep.c_IsLiabilityProduct, frc_ep.c_IsLiabilityProduct, nrc_ep.c_IsLiabilityProduct, usg_ep.c_IsLiabilityProduct, dis_ep.c_IsLiabilityProduct, 'N') as c_IsLiabilityProduct
,COALESCE(udrc_ep.c_RevenueCode, frc_ep.c_RevenueCode, nrc_ep.c_RevenueCode, usg_ep.c_RevenueCode, dis_ep.c_RevenueCode, '') as c_RevenueCode
,COALESCE(udrc_ep.c_DeferredRevenueCode, frc_ep.c_DeferredRevenueCode, nrc_ep.c_DeferredRevenueCode, usg_ep.c_DeferredRevenueCode, dis_ep.c_DeferredRevenueCode, '') as c_DeferredRevenueCode
,acc.id_pi_template
FROM		t_acc_usage						acc
LEFT JOIN	t_pv_UDRecurringCharge			udrc		ON acc.id_sess = udrc.id_sess
LEFT JOIN	t_pv_FlatRecurringCharge		frc			ON acc.id_sess = frc.id_sess
LEFT JOIN	t_pv_NonRecurringCharge			nrc			ON acc.id_sess = nrc.id_sess
LEFT JOIN	t_pv_NonStandardCharge			nsc			ON acc.id_sess = nsc.id_sess
LEFT JOIN	t_pv_AccountCredit				acr			ON acc.id_sess = acr.id_sess
LEFT JOIN	t_ep_unit_dependent_recurring	udrc_ep		ON udrc_ep.id_prop = acc.id_pi_template
LEFT JOIN	t_ep_recurring					frc_ep		ON frc_ep.id_prop = acc.id_pi_template
LEFT JOIN	t_ep_nonrecurring				nrc_ep		ON nrc_ep.id_prop = acc.id_pi_template
LEFT JOIN	t_ep_usage						usg_ep		ON usg_ep.id_prop = acc.id_pi_template
LEFT JOIN	t_ep_discount					dis_ep		ON dis_ep.id_prop = acc.id_pi_template
WHERE 	COALESCE(udrc_ep.c_IsLiabilityProduct, frc_ep.c_IsLiabilityProduct, nrc_ep.c_IsLiabilityProduct, usg_ep.c_IsLiabilityProduct, dis_ep.c_IsLiabilityProduct, 'N') = 'N'
	AND	acc.am_currency like '%' + '%%CURRENCY%%' + '%'
	AND COALESCE(udrc_ep.c_RevenueCode, frc_ep.c_RevenueCode, nrc_ep.c_RevenueCode, usg_ep.c_RevenueCode, dis_ep.c_RevenueCode, '')  like '%' + '%%REVENUECODE%%' + '%'
	AND COALESCE(udrc_ep.c_DeferredRevenueCode, frc_ep.c_DeferredRevenueCode, nrc_ep.c_DeferredRevenueCode, usg_ep.c_DeferredRevenueCode, dis_ep.c_DeferredRevenueCode, '') like '%' + '%%DEFREVENUECODE%%' + '%'
	AND	(%%PRODUCTID%% IS NULL OR (%%PRODUCTID%% IS NOT NULL AND acc.id_pi_template = %%PRODUCTID%%))
	AND '%%ACCOUNTINGCYCLEID%%' IS NOT NULL