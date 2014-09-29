SELECT 
  acc.am_currency
	,udrc.id_usage_interval
	,udrc.c_RCIntervalSubscriptionStart AS SubscriptionStart
	,udrc.c_RCIntervalSubscriptionEnd AS SubscriptionEnd
	,udrc.c_ProratedIntervalStart
	,udrc.c_ProratedIntervalEnd
	,c_ProratedDays = CASE 
					WHEN udrc.c_RCIntervalSubscriptionStart > %%END_DATE%%
						THEN DATEDIFF(DAY, udrc.c_RCIntervalSubscriptionStart, udrc.c_RCIntervalSubscriptionEnd)+1
					WHEN udrc.c_RCIntervalSubscriptionStart <= %%END_DATE%%
						THEN DATEDIFF(DAY, %%END_DATE%%, udrc.c_RCIntervalSubscriptionEnd)+1
				END
	,udrc.c_ProratedDailyRate
	,udrc_ep.c_IsLiabilityProduct
	,udrc_ep.c_RevenueCode
	,udrc_ep.c_DeferredRevenueCode
	,pit.id_pi
FROM t_pv_UDRecurringCharge AS udrc
INNER JOIN t_acc_usage AS acc ON udrc.id_sess = acc.id_sess
INNER JOIN t_usage_interval AS ui ON acc.id_usage_interval = ui.id_interval
LEFT JOIN t_ep_unit_dependent_recurring AS udrc_ep ON udrc_ep.id_prop = acc.id_pi_template
INNER JOIN t_pi_template AS pit ON acc.id_pi_template = pit.id_template
WHERE
	c_RCIntervalSubscriptionEnd >= %%END_DATE%%
	AND ui.tx_interval_status = 'O'
	AND udrc_ep.c_IsLiabilityProduct = 'N'
	AND acc.am_currency like '%' + '%%CURRENCY%%' + '%'
	AND udrc_ep.c_RevenueCode like '%' + '%%REVENUECODE%%' + '%'
	AND udrc_ep.c_DeferredRevenueCode like '%' + '%%DEFREVENUECODE%%' + '%'

UNION

SELECT 
	acc.am_currency
	,frc.id_usage_interval
	,frc.c_RCIntervalSubscriptionStart AS SubscriptionStart
	,frc.c_RCIntervalSubscriptionEnd AS SubscriptionEnd
	,frc.c_ProratedIntervalStart
	,frc.c_ProratedIntervalEnd
	,c_ProratedDays = CASE 
					WHEN frc.c_RCIntervalSubscriptionStart > %%END_DATE%%
						THEN DATEDIFF(DAY, frc.c_RCIntervalSubscriptionStart, frc.c_RCIntervalSubscriptionEnd)+1
					WHEN frc.c_RCIntervalSubscriptionStart <= %%END_DATE%%
						THEN DATEDIFF(DAY, %%END_DATE%%, frc.c_RCIntervalSubscriptionEnd)+1
				END
	,frc.c_ProratedDailyRate
	,frc_ep.c_IsLiabilityProduct
	,frc_ep.c_RevenueCode
	,frc_ep.c_DeferredRevenueCode
	,pit.id_pi
FROM t_pv_FlatRecurringCharge AS frc
INNER JOIN t_acc_usage AS acc ON frc.id_sess = acc.id_sess
INNER JOIN t_usage_interval AS ui ON acc.id_usage_interval = ui.id_interval
LEFT JOIN t_ep_recurring AS frc_ep ON frc_ep.id_prop = acc.id_pi_template
INNER JOIN t_pi_template AS pit ON acc.id_pi_template = pit.id_template
WHERE
	c_RCIntervalSubscriptionEnd >= %%END_DATE%%
	AND ui.tx_interval_status = 'O'
	AND frc_ep.c_IsLiabilityProduct = 'N'
	AND acc.am_currency like '%' + '%%CURRENCY%%' + '%'
	AND frc_ep.c_RevenueCode like '%' + '%%REVENUECODE%%' + '%'
	AND frc_ep.c_DeferredRevenueCode like '%' + '%%DEFREVENUECODE%%' + '%'

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
	,pit.id_pi
FROM t_pv_NonRecurringCharge AS nrc
INNER JOIN t_acc_usage AS acc ON nrc.id_sess = acc.id_sess
INNER JOIN t_usage_interval AS ui ON acc.id_usage_interval = ui.id_interval
LEFT JOIN t_ep_recurring AS nrc_ep ON nrc_ep.id_prop = acc.id_pi_template
INNER JOIN t_pi_template AS pit ON acc.id_pi_template = pit.id_template
WHERE
	c_NRCIntervalSubscriptionEnd >= %%END_DATE%%
	AND ui.tx_interval_status = 'O'
	AND nrc_ep.c_IsLiabilityProduct = 'N'
	AND nrc_ep.c_IsLiabilityProduct = 'N'
	AND acc.am_currency like '%' + '%%CURRENCY%%' + '%'
	AND nrc_ep.c_RevenueCode like '%' + '%%REVENUECODE%%' + '%'
	AND nrc_ep.c_DeferredRevenueCode like '%' + '%%DEFREVENUECODE%%' + '%'