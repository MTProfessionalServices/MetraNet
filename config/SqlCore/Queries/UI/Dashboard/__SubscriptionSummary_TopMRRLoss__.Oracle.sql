SELECT * 
FROM ( 
  SELECT 
    ROW_NUMBER() OVER (ORDER BY SUM(NVL(ss.MRRPrimaryCurrency, 0.0))-SUM(NVL(prev.MRRPrimaryCurrency, 0.0)) ASC) AS ordernum, 
	po.ProductOfferingName as productname, 
	po.ProductOfferingId as productcode,
	ss.Month, 
	SUM(NVL(ss.MRRPrimaryCurrency, 0.0)) as MRR, 
	SUM(NVL(prev.MRRPrimaryCurrency, 0.0)) as MRRPrevious, 
	SUM(NVL(ss.MRRPrimaryCurrency, 0.0))-SUM(NVL(prev.MRRPrimaryCurrency,0.0)) as MRRChange
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
  GROUP BY ss.InstanceId, po.ProductOfferingName, po.ProductOfferingId, ss.Month 
  HAVING SUM(NVL(ss.MRRPrimaryCurrency, 0.0))-SUM(NVL(prev.MRRPrimaryCurrency, 0.0)) < 0 ) a
WHERE a.ordernum <=10 
