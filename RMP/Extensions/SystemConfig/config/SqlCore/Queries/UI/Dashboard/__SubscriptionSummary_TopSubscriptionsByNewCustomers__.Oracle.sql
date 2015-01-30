SELECT
 po.ProductOfferingName AS ProductName,
 ss.Month, 
 SUM(NVL(ss.MRRPrimaryCurrency, 0.0)) AS MRR, 
 SUM(NVL(prev.MRRPrimaryCurrency, 0.0)) AS MRRPrevious, 
 SUM(NVL(ss.MRRPrimaryCurrency, 0.0))-SUM(NVL(prev.MRRPrimaryCurrency, 0.0)) AS MRRChange,
 SUM(NVL(ss.TotalParticipants, 0.0)) AS Subscriptions, 
 SUM(NVL(prev.TotalParticipants, 0.0)) AS SubscriptionsPrevious, 
 SUM(NVL(ss.TotalParticipants, 0.0))-SUM(NVL(prev.TotalParticipants, 0.0)) AS SubscriptionsChange,
 SUM(NVL(ss.NewParticipants, 0.0)) AS NewCustomers,
 SUM(NVL(prev.NewParticipants, 0.0)) AS NewCustomersPrevious,
 SUM(NVL(ss.NewParticipants, 0.0))-SUM(NVL(prev.NewParticipants, 0.0)) AS NewCustomersChange
FROM SubscriptionSummary ss
INNER JOIN ProductOffering po 
 ON po.ProductOfferingId = ss.ProductOfferingId 
 AND ss.InstanceId = po.InstanceId
LEFT JOIN SubscriptionSummary prev 
 ON ss.InstanceId = prev.InstanceId 
 AND ss.ProductOfferingId = prev.ProductOfferingId 
 AND prev.Month = TO_NUMBER (TO_CHAR (ADD_MONTHS (SYSDATE, -2),'mm'))  
 AND prev.Year = TO_NUMBER (TO_CHAR (ADD_MONTHS (SYSDATE, -2),'yyyy'))
WHERE ss.Month = TO_NUMBER (TO_CHAR (ADD_MONTHS (SYSDATE, -1),'mm')) 
 AND ss.Year = TO_NUMBER (TO_CHAR (ADD_MONTHS (SYSDATE, -1),'yyyy'))
 AND ROWNUM <=10  
GROUP BY ss.InstanceId, po.ProductOfferingName, ss.Month 
HAVING sum(ss.NewParticipants) > 0
ORDER BY SUM(NVL(ss.NewParticipants, 0.0)) DESC