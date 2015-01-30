SELECT 
      CONVERT(DATE, CAST(sm.[Month] AS VARCHAR) + '-' + '01' + '-' + CAST(sm.[Year] AS VARCHAR), 110) as [Date],
      sm.ReportingCurrency as CurrencyCode,
      SUM(sm.MrrPrimaryCurrency) as Amount
FROM SubscriptionsByMonth sm
WHERE CONVERT(DATE, CAST(sm.[Month] AS VARCHAR) + '-' + '01' + '-' + CAST(sm.[Year] AS VARCHAR), 110) >= %%FROM_DATE%%
	AND CONVERT(DATE, CAST(sm.[Month] AS VARCHAR) + '-' + '01' + '-' + CAST(sm.[Year] AS VARCHAR), 110) < %%TO_DATE%%
GROUP BY  CONVERT(DATE, CAST(sm.[Month] AS VARCHAR) + '-' + '01' + '-' + CAST(sm.[Year] AS VARCHAR), 110), sm.ReportingCurrency
