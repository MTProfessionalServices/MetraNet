SELECT * 
FROM ( 
  SELECT 
    ROW_NUMBER() OVER (ORDER BY SUM(NVL(ss.TotalParticipants, 0.0))-SUM(NVL(prev.TotalParticipants, 0.0)) ASC) AS OrderNum,
    po.ProductOfferingId AS ProductCode,
    NVL(props.nm_display_name, po.ProductOfferingName) AS productname,
    ss.Month,
    SUM(NVL(ss.TotalParticipants, 0.0)) AS Subscriptions,
    SUM(NVL(prev.TotalParticipants, 0.0)) AS SubscriptionsPrevious, 
    SUM(NVL(ss.TotalParticipants, 0.0))-SUM(NVL(prev.TotalParticipants, 0.0)) AS SubscriptionsChange,
    ABS(SUM(NVL(ss.TotalParticipants, 0.0))-SUM(NVL(prev.TotalParticipants, 0.0))) AS SubscriptionsAbsChange,
    SUM(NVL(ss.NewParticipants, 0.0)) AS NewCustomers, 
    SUM(NVL(prev.NewParticipants, 0.0)) AS NewCustomersPrevious, 
    SUM(NVL(ss.NewParticipants, 0.0))-SUM(NVL(prev.NewParticipants, 0.0)) AS NewCustomersChange
  FROM SubscriptionParticipants ss
  INNER JOIN ProductOffering po 
    ON po.ProductOfferingId = ss.ProductOfferingId 
    AND ss.InstanceId = po.InstanceId
	LEFT JOIN t_vw_base_props props on props.id_prop = po.ProductOfferingId AND props.id_lang_code = %%ID_LANG%%
  LEFT JOIN SubscriptionParticipants prev 
    ON ss.InstanceId = prev.InstanceId 
    AND ss.ProductOfferingId = prev.ProductOfferingId 
    AND prev.Month = TO_NUMBER (TO_CHAR (ADD_MONTHS (%%CURRENT_DATETIME%%, -2),'mm'))  
    AND prev.Year = TO_NUMBER (TO_CHAR (ADD_MONTHS (%%CURRENT_DATETIME%%, -2),'yyyy'))
  WHERE ss.Month = TO_NUMBER (TO_CHAR (ADD_MONTHS (%%CURRENT_DATETIME%%, -1),'mm')) 
    AND ss.Year = TO_NUMBER (TO_CHAR (ADD_MONTHS (%%CURRENT_DATETIME%%, -1),'yyyy'))
  GROUP BY ss.InstanceId, ss.Month, po.ProductOfferingId, po.ProductOfferingName, props.nm_display_name
  HAVING SUM(NVL(ss.TotalParticipants, 0.0))-SUM(NVL(prev.TotalParticipants, 0.0)) > 0 ) a
WHERE a.OrderNum <=10 

