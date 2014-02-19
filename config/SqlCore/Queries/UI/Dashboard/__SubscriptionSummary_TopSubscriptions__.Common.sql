select top 10 ss.ProductCode, ss.Month, sum(ss.MRR) as 'MRR', sum(prev.MRR) as 'MRRPrevious', sum(ss.MRR)-sum(prev.MRR) as 'MRRChange',
sum(ss.Subscriptions) as 'Subscriptions', sum(prev.Subscriptions) as 'SubscriptionsPrevious', sum(ss.Subscriptions)-sum(prev.Subscriptions) as 'SubscriptionsChange',
sum(ss.NewCustomers) as 'NewCustomers', sum(prev.NewCustomers) as 'NewCustomersPrevious', sum(ss.NewCustomers)-sum(prev.NewCustomers) as 'NewCustomersChange'
from SubscriptionSummary ss
left join SubscriptionSummary prev on ss.InstanceId = prev.InstanceId AND ss.ProductCode = prev.ProductCode AND prev.Month = DATEADD(m,-1,ss.Month)
WHERE DATEPART(m, ss.Month) = DATEPART(m, DATEADD(m, -1, getdate())) AND DATEPART(yyyy, ss.Month) = DATEPART(yyyy, DATEADD(m, -1, getdate()))
GROUP BY ss.InstanceId, ss.ProductCode, ss.Month 
ORDER BY sum(ss.Subscriptions) desc