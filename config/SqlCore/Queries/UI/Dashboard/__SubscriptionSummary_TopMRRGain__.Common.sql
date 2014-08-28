SELECT TOP 10 DENSE_RANK () OVER (ORDER BY SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) DESC) AS 'ordernum', 
	po.ProductOfferingName as 'productname', 
	po.ProductOfferingId AS 'productcode',
	ss.Month, 
	SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0)) AS 'MRR', 
	SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) AS 'MRRPrevious', 
	SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-sum(isnull(prev.MRRPrimaryCurrency, 0.0)) AS 'MRRChange'
FROM SubscriptionSummary ss
INNER JOIN ProductOffering po on po.ProductOfferingId = ss.ProductOfferingId AND ss.InstanceId = po.InstanceId
LEFT JOIN SubscriptionSummary prev on ss.InstanceId = prev.InstanceId AND ss.ProductOfferingId = prev.ProductOfferingId AND prev.Month = DATEADD(m,-1,ss.Month)
WHERE ss.Month = DATEPART(m, DATEADD(m, -1, %%METRATIME%%)) AND ss.Year = DATEPART(yyyy, DATEADD(m, -1, %%METRATIME%%))
GROUP BY ss.InstanceId, po.ProductOfferingName,  po.ProductOfferingId, ss.Month 
HAVING SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) > 0
ORDER BY SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-sum(prev.MRRPrimaryCurrency) DESC
