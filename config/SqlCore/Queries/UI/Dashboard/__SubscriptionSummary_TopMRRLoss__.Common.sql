SELECT TOP 10 DENSE_RANK () OVER (ORDER BY SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) ASC) AS ordernum, 
	po.ProductOfferingName as 'productname', 
	po.ProductOfferingId as 'productcode',
	ss.Month, 
	SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0)) as 'MRR', 
	SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) as 'MRRPrevious', 
	SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-SUM(ISNULL(prev.MRRPrimaryCurrency,0.0)) as 'MRRChange'
FROM SubscriptionSummary ss
INNER JOIN ProductOffering po 
 ON po.ProductOfferingId = ss.ProductOfferingId 
 AND ss.InstanceId = po.InstanceId
LEFT JOIN SubscriptionSummary prev 
 ON ss.InstanceId = prev.InstanceId 
 AND ss.ProductOfferingId = prev.ProductOfferingId 
 AND prev.Month = DATEPART(m, DATEADD(m, -2, %%METRATIME%%))
 AND prev.Year = DATEPART(yyyy, DATEADD(m, -2, %%METRATIME%%))
WHERE ss.Month = DATEPART(m, DATEADD(m, -1, %%METRATIME%%)) AND ss.Year = DATEPART(yyyy, DATEADD(m, -1, %%METRATIME%%))
GROUP BY ss.InstanceId, po.ProductOfferingName, po.ProductOfferingId, ss.Month 
HAVING SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) < 0
ORDER BY SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) ASC 