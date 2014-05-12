select top 10 po.ProductOfferingName, ss.Month, sum(ss.MRRPrimaryCurrency) as 'MRR', sum(prev.MRRPrimaryCurrency) as 'MRRPrevious', sum(ss.MRRPrimaryCurrency)-sum(prev.MRRPrimaryCurrency) as 'MRRChange',
sum(ss.TotalParticipants) as 'Subscriptions', sum(prev.TotalParticipants) as 'SubscriptionsPrevious', sum(ss.TotalParticipants)-sum(prev.TotalParticipants) as 'SubscriptionsChange',
sum(ss.NewParticipants) as 'NewCustomers', sum(prev.NewParticipants) as 'NewCustomersPrevious', sum(ss.NewParticipants)-sum(prev.NewParticipants) as 'NewCustomersChange'
from SubscriptionSummary ss
inner join ProductOffering po on po.ProductOfferingId = ss.ProductOfferingId and ss.InstanceId = po.InstanceId
left join SubscriptionSummary prev on ss.InstanceId = prev.InstanceId AND ss.ProductOfferingId = prev.ProductOfferingId AND prev.Month = DATEADD(m,-1,ss.Month)
WHERE DATEPART(m, ss.Month) = DATEPART(m, DATEADD(m, -1, getdate())) AND DATEPART(yyyy, ss.Month) = DATEPART(yyyy, DATEADD(m, -1, getdate()))
GROUP BY ss.InstanceId, po.ProductOfferingName, ss.Month 
HAVING sum(ss.NewParticipants) > 0
ORDER BY sum(ss.NewParticipants) desc