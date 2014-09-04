SELECT  TOP 10 ROW_NUMBER() OVER (ORDER BY ss.Month ASC) AS 'OrderNum',
  po.ProductOfferingId as 'ProductCode',
  po.ProductOfferingName AS 'ProductName',
  ss.Month, 
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
	AND prev.Month = DATEPART(m, DATEADD(m, -2, getdate()))
	AND prev.Year = DATEPART(yyyy, DATEADD(m, -2, getdate()))
WHERE ss.Month = DATEPART(m, DATEADD(m, -1, getdate())) 
	AND ss.Year = DATEPART(yyyy, DATEADD(m, -1, getdate()))
GROUP BY ss.InstanceId, po.ProductOfferingId, ss.Month, po.ProductOfferingName 
