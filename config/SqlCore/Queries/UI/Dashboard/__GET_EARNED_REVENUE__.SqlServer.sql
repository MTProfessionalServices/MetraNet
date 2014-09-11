SELECT 
  acc.am_currency
	,udrc.id_usage_interval
	,udrc.c_RCIntervalSubscriptionStart
	,udrc.c_RCIntervalSubscriptionEnd
	,udrc.c_ProratedIntervalStart
	,udrc.c_ProratedIntervalEnd
	,udrc.c_ProratedDays
	,udrc.c_ProratedDailyRate
	,udrc_ep.c_IsLiabilityProduct
	,udrc_ep.c_RevenueCode
	,udrc_ep.c_DeferredRevenueCode
FROM t_pv_UDRecurringCharge AS udrc
INNER JOIN t_acc_usage AS acc ON udrc.id_sess = acc.id_sess
LEFT JOIN t_ep_unit_dependent_recurring AS udrc_ep ON udrc_ep.id_prop = acc.id_pi_template
WHERE c_RCIntervalSubscriptionStart < %%START_DATE%%

UNION

SELECT 
  acc.am_currency
 ,frc.id_usage_interval
 ,frc.c_RCIntervalSubscriptionStart
 ,frc.c_RCIntervalSubscriptionEnd
 ,frc.c_ProratedIntervalStart
 ,frc.c_ProratedIntervalEnd
 ,frc.c_ProratedDays
 ,frc.c_ProratedDailyRate
 ,frc_ep.c_IsLiabilityProduct
 ,frc_ep.c_RevenueCode
 ,frc_ep.c_DeferredRevenueCode
FROM t_pv_FlatRecurringCharge AS frc
INNER JOIN t_acc_usage AS acc ON frc.id_sess = acc.id_sess
LEFT JOIN t_ep_recurring AS frc_ep ON frc_ep.id_prop = acc.id_pi_template
WHERE c_RCIntervalSubscriptionStart < %%START_DATE%%