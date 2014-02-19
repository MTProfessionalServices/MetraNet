select top 10 ss.ProductCode, ss.Month, sum(ss.MRR) as 'MRR', sum(prev.MRR) as 'MRRPrevious', sum(ss.MRR)-sum(prev.MRR) as 'Change',  (sum(ss.MRR)-sum(prev.MRR))/sum(ss.MRR) as 'PercentageChange'
from SubscriptionSummary ss
left join SubscriptionSummary prev on ss.InstanceId = prev.InstanceId AND ss.ProductCode = prev.ProductCode AND prev.Month = DATEADD(m,-1,ss.Month)
WHERE DATEPART(m, ss.Month) = DATEPART(m, DATEADD(m, -1, getdate())) AND DATEPART(yyyy, ss.Month) = DATEPART(yyyy, DATEADD(m, -1, getdate()))
GROUP BY ss.InstanceId, ss.ProductCode, ss.Month 
HAVING sum(ss.MRR)-sum(prev.MRR) > 0
ORDER BY sum(ss.MRR)-sum(prev.MRR) desc