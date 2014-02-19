select ss.ProductCode, ss.Month, sum(ss.MRR) as 'MRR', sum(prev.MRR) as 'MRRPrevious', sum(ss.MRR)-sum(prev.MRR) as 'MRRChange',
sum(ss.Subscriptions) as 'Subscriptions', sum(prev.Subscriptions) as 'SubscriptionsPrevious', sum(ss.Subscriptions)-sum(prev.Subscriptions) as 'SubscriptionsChange',
sum(ss.NewCustomers) as 'NewCustomers', sum(prev.NewCustomers) as 'NewCustomersPrevious', sum(ss.NewCustomers)-sum(prev.NewCustomers) as 'NewCustomersChange',
sum(ss.SubscriptionRevenue) as 'Revenue', sum(prev.SubscriptionRevenue) as 'RevenuePrevious', sum(ss.SubscriptionRevenue)-sum(prev.SubscriptionRevenue) as 'RevenueChange'
from SubscriptionSummary ss
left join SubscriptionSummary prev on ss.InstanceId = prev.InstanceId AND ss.ProductCode = prev.ProductCode AND prev.Month = DATEADD(m,-1,ss.Month)
WHERE ss.Month > '2012-2-01' and ss.Month < '2014-02-01'
AND ss.ProductCode like 'Adobe Connect Monthly Fee'
group by ss.InstanceId, ss.ProductCode, ss.Month order by ss.Month asc