SELECT TOP 10 ROW_NUMBER() OVER (ORDER BY SUM(ISNULL(ss.TotalParticipants, 0.0))-SUM(ISNULL(prev.TotalParticipants, 0.0)) DESC) AS 'OrderNum', 
   po.ProductOfferingId as 'ProductCode',
	 ISNULL(props.nm_display_name, po.ProductOfferingName) AS 'productname',
	 ss.Month,
	 SUM(ISNULL(ss.TotalParticipants, 0.0)) AS 'Subscriptions',
	 SUM(ISNULL(prev.TotalParticipants, 0.0)) AS 'SubscriptionsPrevious', 
	 SUM(ISNULL(ss.TotalParticipants, 0.0))-SUM(ISNULL(prev.TotalParticipants, 0.0)) AS 'SubscriptionsChange',
   ABS(SUM(ISNULL(ss.TotalParticipants, 0.0))-SUM(ISNULL(prev.TotalParticipants, 0.0))) AS 'SubscriptionsAbsChange',
	 SUM(ISNULL(ss.NewParticipants, 0.0)) AS 'NewCustomers',
   SUM(ISNULL(prev.NewParticipants, 0.0)) AS 'NewCustomersPrevious', 
	 SUM(ISNULL(ss.NewParticipants, 0.0))-SUM(ISNULL(prev.NewParticipants, 0.0)) AS 'NewCustomersChange'
FROM SubscriptionParticipants ss
INNER JOIN ProductOffering po 
 ON po.ProductOfferingId = ss.ProductOfferingId 
 AND ss.InstanceId = po.InstanceId
LEFT JOIN t_vw_base_props props on props.id_prop = po.ProductOfferingId AND props.id_lang_code = %%ID_LANG%%
LEFT JOIN SubscriptionParticipants prev 
 ON ss.InstanceId = prev.InstanceId 
 AND ss.ProductOfferingId = prev.ProductOfferingId 
 AND prev.Month = DATEPART(m, DATEADD(m, -2, %%CURRENT_DATETIME%%))
 AND prev.Year = DATEPART(yyyy, DATEADD(m, -2, %%CURRENT_DATETIME%%))
WHERE ss.Month = DATEPART(m, DATEADD(m, -1, %%CURRENT_DATETIME%%)) 
 AND ss.Year = DATEPART(yyyy, DATEADD(m, -1, %%CURRENT_DATETIME%%))
GROUP BY ss.InstanceId, ss.Month, po.ProductOfferingId, po.ProductOfferingName, props.nm_display_name
HAVING SUM(ISNULL(ss.TotalParticipants, 0.0))-SUM(ISNULL(prev.TotalParticipants, 0.0)) < 0
