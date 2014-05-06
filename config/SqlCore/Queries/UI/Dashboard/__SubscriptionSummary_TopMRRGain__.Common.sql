select top 10 po.ProductOfferingName, ss.Month, sum(ss.MRRPrimaryCurrency) as 'MRR', sum(prev.MRRPrimaryCurrency) as 'MRRPrevious', sum(ss.MRRPrimaryCurrency)-sum(prev.MRRPrimaryCurrency) as 'Change',  (sum(ss.MRRPrimaryCurrency)-sum(prev.MRRPrimaryCurrency))/sum(ss.MRRPrimaryCurrency) as 'PercentageChange'
from AnalyticsDatamart..SubscriptionSummary ss
inner join AnalyticsDatamart..ProductOffering po on po.ProductOfferingId = ss.ProductOfferingId and ss.InstanceId = po.InstanceId
left join AnalyticsDatamart..SubscriptionSummary prev on ss.InstanceId = prev.InstanceId AND ss.ProductOfferingId = prev.ProductOfferingId AND prev.Month = DATEADD(m,-1,ss.Month)
WHERE DATEPART(m, ss.Month) = DATEPART(m, DATEADD(m, -1, getdate())) AND DATEPART(yyyy, ss.Month) = DATEPART(yyyy, DATEADD(m, -1, getdate()))
GROUP BY ss.InstanceId, po.ProductOfferingName, ss.Month 
HAVING sum(ss.MRRPrimaryCurrency)-sum(prev.MRRPrimaryCurrency) > 0
ORDER BY sum(ss.MRRPrimaryCurrency)-sum(prev.MRRPrimaryCurrency) desc