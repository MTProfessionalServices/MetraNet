DECLARE @dateFrom DATE, @dateTo DATE
SET @dateFrom = DATEADD(month, -13, GETUTCDATE());
SET @dateTo = DATEADD(month, 12, CONVERT(DATE, CONCAT(DATEPART(month, GETUTCDATE()),'-','01','-',DATEPART(year, GETUTCDATE())), 110));
SELECT 
      CONVERT(DATE, CAST(sm.[Month] AS VARCHAR) + '-' + '01' + '-' + CAST(sm.[Year] AS VARCHAR), 110) as [Date],
      sm.ReportingCurrency as CurrencyCode,
      SUM(sm.MrrPrimaryCurrency) as Amount
FROM SubscriptionsByMonth sm
WHERE CONVERT(DATE, CAST(sm.[Month] AS VARCHAR) + '-' + '01' + '-' + CAST(sm.[Year] AS VARCHAR), 110) >= @dateFrom
	AND CONVERT(DATE, CAST(sm.[Month] AS VARCHAR) + '-' + '01' + '-' + CAST(sm.[Year] AS VARCHAR), 110) < @dateTo
GROUP BY  CONVERT(DATE, CAST(sm.[Month] AS VARCHAR) + '-' + '01' + '-' + CAST(sm.[Year] AS VARCHAR), 110), sm.ReportingCurrency
