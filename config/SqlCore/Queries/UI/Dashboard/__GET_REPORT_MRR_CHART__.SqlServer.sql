/* Subscription table is not implemented yet, so the query was commented out*/
/*DECLARE @dateFrom DATE, @dateTo DATE
SET @dateFrom = DATEADD(month, -13, GETUTCDATE());
SET @dateTo = DATEADD(month, 12, CONVERT(DATE, CONCAT(DATEPART(month, GETUTCDATE()),'-','01','-',DATEPART(year, GETUTCDATE())), 110));
SELECT CONVERT(DATE, CONCAT(DATEPART(month, sm.[Month]),'-','01','-',DATEPART(year, sm.[Month])), 110) as [Date],
       st.FeeCurrency as CurrencyCode,
       SUM(sm.MRRBase + sm.MRRNew + sm.MRRRenewal + sm.MRRPriceChange + sm.MRRChurn + sm.MRRCancellation) as Amount
FROM SubscriptionsByMonth sm
                          join Subscription st on sm.SubscriptionId = st.SubscriptionId
                          join Customer c on st.AccountId = c.AccountId
WHERE sm.[Month] IS NOT NULL
                           AND sm.[Month] >= @dateFrom
                           AND sm.[Month] < @dateTo
GROUP BY CONVERT(DATE, CONCAT(DATEPART(month, sm.[Month]),'-','01','-',DATEPART(year, sm.[Month])), 110), st.FeeCurrency*/
