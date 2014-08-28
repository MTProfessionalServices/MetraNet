SELECT
 po.ProductOfferingId,
 po.ProductOfferingName AS 'ProductName', 
 ss.Month, 
 SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0)) AS 'MRR', 
 SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) AS 'MRRPrevious', 
 SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) AS 'MRRChange',
 SUM(ISNULL(ss.TotalParticipants, 0.0)) AS 'Subscriptions', 
 SUM(ISNULL(prev.TotalParticipants, 0.0)) AS 'SubscriptionsPrevious', 
 SUM(ISNULL(ss.TotalParticipants, 0.0))-SUM(ISNULL(prev.TotalParticipants, 0.0)) AS 'SubscriptionsChange',
 SUM(ISNULL(ss.NewParticipants, 0.0)) AS 'NewCustomers', 
 SUM(ISNULL(prev.NewParticipants, 0.0)) AS 'NewCustomersPrevious', 
 SUM(ISNULL(ss.NewParticipants, 0.0))-SUM(ISNULL(prev.NewParticipants, 0.0)) AS 'NewCustomersChange',
 SUM(ISNULL(ss.SubscriptionRevPrimaryCurrency, 0.0)) AS 'Revenue', 
 SUM(ISNULL(prev.SubscriptionRevPrimaryCurrency, 0.0)) AS 'RevenuePrevious', 
 SUM(ISNULL(ss.SubscriptionRevPrimaryCurrency, 0.0))-SUM(ISNULL(prev.SubscriptionRevPrimaryCurrency, 0.0)) AS 'RevenueChange'
FROM SubscriptionSummary ss
INNER JOIN ProductOffering po 
ON po.ProductOfferingId = ss.ProductOfferingId 
 AND ss.InstanceId = po.InstanceId
LEFT JOIN SubscriptionSummary prev 
ON ss.InstanceId = prev.InstanceId 
 AND ss.ProductOfferingId = prev.ProductOfferingId 
 AND prev.Month = DATEADD(m,-1,ss.Month)
WHERE ss.Month = DATEPART(m, DATEADD(m, -1, getdate())) 
 AND   ss.Year = DATEPART(yyyy, DATEADD(m, -1, getdate()))
GROUP BY ss.InstanceId, po.ProductOfferingId, ss.Month, po.ProductOfferingName 
ORDER BY ss.Month asc
