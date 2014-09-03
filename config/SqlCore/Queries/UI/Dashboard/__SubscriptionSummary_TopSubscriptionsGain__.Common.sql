SELECT TOP 10 ROW_NUMBER() OVER (ORDER BY SUM(ISNULL(ss.TotalParticipants, 0.0))-SUM(ISNULL(prev.TotalParticipants, 0.0)) DESC) AS 'OrderNum',
   po.ProductOfferingId as 'ProductCode',
	 po.ProductOfferingName AS 'ProductName', 
	 ss.Month,
	 SUM(ISNULL(ss.TotalParticipants, 0.0)) AS 'Subscriptions',
	 SUM(ISNULL(prev.TotalParticipants, 0.0)) AS 'SubscriptionsPrevious', 
	 SUM(ISNULL(ss.TotalParticipants, 0.0))-SUM(ISNULL(prev.TotalParticipants, 0.0)) AS 'SubscriptionsChange',
	 SUM(ISNULL(ss.NewParticipants, 0.0)) AS 'NewCustomers', 
   SUM(ISNULL(prev.NewParticipants, 0.0)) AS 'NewCustomersPrevious', 
	 SUM(ISNULL(ss.NewParticipants, 0.0))-SUM(ISNULL(prev.NewParticipants, 0.0)) AS 'NewCustomersChange'
FROM SubscriptionSummary ss
INNER JOIN ProductOffering po 
 ON po.ProductOfferingId = ss.ProductOfferingId 
 AND ss.InstanceId = po.InstanceId
LEFT JOIN SubscriptionSummary prev 
 ON ss.InstanceId = prev.InstanceId 
 AND ss.ProductOfferingId = prev.ProductOfferingId 
 AND prev.Month = DATEPART(m, DATEADD(m, -2, GETDATE()))
 AND prev.Year = DATEPART(yyyy, DATEADD(m, -2, GETDATE()))
WHERE ss.Month = DATEPART(m, DATEADD(m, -1, GETDATE())) 
 AND ss.Year = DATEPART(yyyy, DATEADD(m, -1, GETDATE()))
GROUP BY ss.InstanceId, po.ProductOfferingId, po.ProductOfferingName, ss.Month 
HAVING SUM(ISNULL(ss.TotalParticipants, 0.0))-SUM(ISNULL(prev.TotalParticipants, 0.0)) > 0

