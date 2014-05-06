SELECT  ss.ProductOfferingId,
		ss.Month, 
		sum(ss.MRRPrimaryCurrency) as MRR,
		sum(prev.MRRPrimaryCurrency) as MRRPrevious, 
		sum(ss.MRRPrimaryCurrency)-sum(prev.MRRPrimaryCurrency) as MRRChange,
		sum(ss.TotalParticipants) as Subscriptions, 
		sum(prev.TotalParticipants) as SubscriptionsPrevious, 
		sum(ss.TotalParticipants)-sum(prev.TotalParticipants) as SubscriptionsChange,
		sum(ss.NewParticipants) as NewCustomers, 
		sum(prev.NewParticipants) as NewCustomersPrevious, 
		sum(ss.NewParticipants)-sum(prev.NewParticipants) as NewCustomersChange,
		sum(ss.SubscriptionRevenuePrimaryCurrency) as Revenue, 
		sum(prev.SubscriptionRevenuePrimaryCurrency) as RevenuePrevious, 
		sum(ss.SubscriptionRevenuePrimaryCurrency)-sum(prev.SubscriptionRevenuePrimaryCurrency) as RevenueChange
FROM AnalyticsDatamart..SubscriptionSummary ss
INNER JOIN AnalyticsDatamart..ProductOffering po 
ON po.ProductOfferingId = ss.ProductOfferingId 
	AND ss.InstanceId = po.InstanceId
LEFT JOIN AnalyticsDatamart..SubscriptionSummary prev 
ON ss.InstanceId = prev.InstanceId 
	AND ss.ProductOfferingId = prev.ProductOfferingId 
	AND prev.Month = DATEADD(m,-1,ss.Month)
WHERE DATEPART(m, ss.Month) = DATEPART(m, DATEADD(m, -1, getdate())) 
		AND DATEPART(yyyy, ss.Month) = DATEPART(yyyy, DATEADD(m, -1, getdate()))
GROUP BY ss.InstanceId, ss.ProductOfferingId, ss.Month 
ORDER BY ss.Month asc