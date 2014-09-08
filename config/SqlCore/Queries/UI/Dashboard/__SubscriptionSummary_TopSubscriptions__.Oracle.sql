SELECT * 
FROM ( 
  SELECT 
    ROW_NUMBER () OVER (ORDER BY ss.Month ASC) AS OrderNum,
    po.ProductOfferingId as ProductCode,
    NVL(props.nm_display_name, '') AS productname,
    ss.Month, 
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
	LEFT JOIN t_vw_base_props props on props.id_prop = po.ProductOfferingId AND props.id_lang_code = %%ID_LANG%%
  LEFT JOIN SubscriptionSummary prev 
    ON ss.InstanceId = prev.InstanceId 
    AND ss.ProductOfferingId = prev.ProductOfferingId 
    AND prev.Month = TO_NUMBER (TO_CHAR (ADD_MONTHS (SYSDATE, -2),'mm'))  
    AND prev.Year = TO_NUMBER (TO_CHAR (ADD_MONTHS (SYSDATE, -2),'yyyy'))
  WHERE ss.Month = TO_NUMBER (TO_CHAR (ADD_MONTHS (SYSDATE, -1),'mm')) 
    AND ss.Year = TO_NUMBER (TO_CHAR (ADD_MONTHS (SYSDATE, -1),'yyyy'))
  GROUP BY ss.InstanceId, ss.Month, po.ProductOfferingId, NVL(props.nm_display_name, '') ) a
WHERE a.OrderNum <=10 

