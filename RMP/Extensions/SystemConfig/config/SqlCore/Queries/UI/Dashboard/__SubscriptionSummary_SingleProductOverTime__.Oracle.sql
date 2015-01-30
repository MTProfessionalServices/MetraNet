SELECT * 
FROM ( 
  SELECT 
    ROW_NUMBER() OVER (ORDER BY ss.Month ASC) AS OrderNum,
    po.ProductOfferingId AS ProductCode,
    po.ProductOfferingName AS ProductName,
    ss.Month, 
    SUM(NVL(ss.SubscriptionRevPrimaryCurrency, 0.0)) AS Revenue, 
    SUM(NVL(prev.SubscriptionRevPrimaryCurrency, 0.0)) AS RevenuePrevious, 
    SUM(NVL(ss.SubscriptionRevPrimaryCurrency, 0.0))-SUM(NVL(prev.SubscriptionRevPrimaryCurrency, 0.0)) AS RevenueChange
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
  GROUP BY ss.InstanceId, po.ProductOfferingId, ss.Month, po.ProductOfferingName ) a
WHERE a.OrderNum <=10 
