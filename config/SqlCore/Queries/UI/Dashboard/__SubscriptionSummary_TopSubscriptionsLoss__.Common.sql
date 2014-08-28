SELECT top 10 
	 po.ProductOfferingName as 'ProductName',
	 ss.Month,
	 SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0)) as 'MRR',
	 SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) as 'MRRPrevious', 
	 SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) as 'MRRChange',
	 SUM(ISNULL(ss.TotalParticipants, 0.0)) as 'Subscriptions',
	 SUM(ISNULL(prev.TotalParticipants, 0.0)) as 'SubscriptionsPrevious', 
	 SUM(ISNULL(ss.TotalParticipants, 0.0))-SUM(ISNULL(prev.TotalParticipants, 0.0)) as 'SubscriptionsChange',
	 SUM(ISNULL(ss.NewParticipants, 0.0)) as 'NewCustomers', SUM(ISNULL(prev.NewParticipants, 0.0)) as 'NewCustomersPrevious', 
	 SUM(ISNULL(ss.NewParticipants, 0.0))-SUM(ISNULL(prev.NewParticipants, 0.0)) as 'NewCustomersChange'
FROM SubscriptionSummary ss
INNER JOIN ProductOffering po 
 ON po.ProductOfferingId = ss.ProductOfferingId 
 AND ss.InstanceId = po.InstanceId
LEFT JOIN SubscriptionSummary prev 
 ON ss.InstanceId = prev.InstanceId 
 AND ss.ProductOfferingId = prev.ProductOfferingId 
 AND prev.Month = ss.Month-1
WHERE ss.Month = DATEPART(m, DATEADD(m, -1, getdate())) 
 AND ss.Year = DATEPART(yyyy, DATEADD(m, -1, getdate()))
GROUP BY ss.InstanceId, po.ProductOfferingName, ss.Month 
HAVING SUM(ISNULL(ss.TotalParticipants, 0.0))-SUM(ISNULL(prev.TotalParticipants, 0.0)) < 0
ORDER BY SUM(ISNULL(ss.TotalParticipants, 0.0))-SUM(ISNULL(prev.TotalParticipants, 0.0)) ASC