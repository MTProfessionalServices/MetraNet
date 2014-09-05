 SELECT TOP 10 ROW_NUMBER() OVER (ORDER BY sum(isnull(ss.MRRPrimaryCurrency, 0.0)) DESC) AS ordernum, 
		po.ProductOfferingName as 'productname', po.ProductOfferingId as 'productcode',
		ss.Month, 
		SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0)) AS MRR, 
		SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) AS MRRPrevious, 
		SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) AS MRRChange,
		SUM(ISNULL(ss.TotalParticipants, 0.0)) AS Subscriptions, 
		SUM(ISNULL(prev.TotalParticipants, 0.0)) AS SubscriptionsPrevious, 
		SUM(ISNULL(ss.TotalParticipants, 0.0))-SUM(ISNULL(prev.TotalParticipants, 0.0)) AS SubscriptionsChange,
		SUM(ISNULL(ss.NewParticipants, 0.0)) AS NewCustomers, 
		SUM(ISNULL(prev.NewParticipants, 0.0)) AS NewCustomersPrevious, 
		SUM(ISNULL(ss.NewParticipants, 0.0))-SUM(ISNULL(prev.NewParticipants, 0.0)) AS NewCustomersChange
FROM SubscriptionSummary ss
INNER JOIN ProductOffering po 
ON po.ProductOfferingId = ss.ProductOfferingId 
		AND ss.InstanceId = po.InstanceId
LEFT JOIN SubscriptionSummary prev 
ON ss.InstanceId = prev.InstanceId 
	AND ss.ProductOfferingId = prev.ProductOfferingId 
	AND prev.Month = DATEPART(m, DATEADD(m, -2, GETDATE()))
  AND prev.Year = DATEPART(yyyy, DATEADD(m, -2, GETDATE()))
WHERE ss.Month = DATEPART(m, DATEADD(m, -1, GETDATE())) AND ss.Year = DATEPART(yyyy, DATEADD(m, -1, GETDATE()))
GROUP BY ss.InstanceId, po.ProductOfferingName, po.ProductOfferingId, ss.Month
