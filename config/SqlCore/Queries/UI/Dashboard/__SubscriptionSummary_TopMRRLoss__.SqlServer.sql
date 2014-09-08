SELECT TOP 10 ROW_NUMBER() OVER (ORDER BY SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) ASC) AS ordernum, 
	ISNULL(props.nm_display_name, '') AS 'productname',
	po.ProductOfferingId as 'productcode',
	ss.Month, 
	SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0)) as 'MRR', 
	SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) as 'MRRPrevious', 
	SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-SUM(ISNULL(prev.MRRPrimaryCurrency,0.0)) as 'MRRChange'
FROM SubscriptionSummary ss
INNER JOIN ProductOffering po 
 ON po.ProductOfferingId = ss.ProductOfferingId 
 AND ss.InstanceId = po.InstanceId
LEFT JOIN t_vw_base_props props on props.id_prop = po.ProductOfferingId AND props.id_lang_code = %%ID_LANG%%
LEFT JOIN SubscriptionSummary prev 
 ON ss.InstanceId = prev.InstanceId 
 AND ss.ProductOfferingId = prev.ProductOfferingId 
 AND prev.Month = DATEPART(m, DATEADD(m, -2, GETDATE()))
 AND prev.Year = DATEPART(yyyy, DATEADD(m, -2, GETDATE()))
WHERE ss.Month = DATEPART(m, DATEADD(m, -1, GETDATE())) AND ss.Year = DATEPART(yyyy, DATEADD(m, -1, GETDATE()))
GROUP BY ss.InstanceId,  ss.Month, po.ProductOfferingId, ISNULL(props.nm_display_name, '')
HAVING SUM(ISNULL(ss.MRRPrimaryCurrency, 0.0))-SUM(ISNULL(prev.MRRPrimaryCurrency, 0.0)) < 0
