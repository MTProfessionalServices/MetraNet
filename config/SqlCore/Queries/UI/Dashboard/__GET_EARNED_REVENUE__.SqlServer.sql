SELECT 
	 acc.c_Currency
	,udrc.id_usage_interval
	,udrc.c_RCIntervalSubscriptionStart
	,udrc.c_RCIntervalSubscriptionEnd
	,udrc.c_ProratedIntervalStart
	,udrc.c_ProratedIntervalEnd
	,udrc.c_ProratedDays
	,udrc.c_ProratedDailyRate
FROM t_pv_UDRecurringCharge AS udrc
INNER JOIN t_sub AS sub ON udrc.c__SubscriptionID = sub.id_sub
INNER JOIN t_av_Internal AS acc ON sub.id_acc = acc.id_acc
WHERE
	c_RCIntervalSubscriptionStart >= '19000101'
	AND c_RCIntervalSubscriptionEnd < %%START_DATE%%

UNION

SELECT 
	 acc.c_Currency
	,rc.id_usage_interval
	,rc.c_RCIntervalSubscriptionStart
	,rc.c_RCIntervalSubscriptionEnd
	,rc.c_ProratedIntervalStart
	,rc.c_ProratedIntervalEnd
	,rc.c_ProratedDays
	,rc.c_ProratedDailyRate
FROM t_pv_FlatRecurringCharge AS rc
INNER JOIN t_sub AS sub ON rc.c__SubscriptionID = sub.id_sub
INNER JOIN t_av_Internal AS acc ON sub.id_acc = acc.id_acc
WHERE
	c_RCIntervalSubscriptionStart >= '19000101'
	AND c_RCIntervalSubscriptionEnd < %%START_DATE%%