DECLARE @dateFrom DATE, @dateTo DATE
SET @dateFrom = DATEADD(month, -13, GETDATE());
SET @dateTo = DATEADD(month, 12, CONVERT(DATE, CONCAT(DATEPART(month, GETDATE()),'-','01','-',DATEPART(year, GETDATE())), 110));
SELECT CONVERT(DATE, CONCAT(DATEPART(month, sm.[Month]),'-','01','-',DATEPART(year, sm.[Month])), 110) as [Date],
       st.FeeCurrency as CurrencyCode,
       SUM(sm.MRRBase + sm.MRRNew + sm.MRRRenewal + sm.MRRPriceChange + sm.MRRChurn + sm.MRRCancellation) as Amount
FROM Subscriptiondatamart.dbo.SubscriptionsByMonth sm
                          join Subscriptiondatamart.dbo.SubscriptionTable st on sm.SubscriptionId = st.SubscriptionId
                          join Subscriptiondatamart.dbo.Customer c on st.AccountId = c.AccountId
WHERE sm.[Month] IS NOT NULL
                           AND sm.[Month] >= @dateFrom
                           AND sm.[Month] < @dateTo
GROUP BY CONVERT(DATE, CONCAT(DATEPART(month, sm.[Month]),'-','01','-',DATEPART(year, sm.[Month])), 110), st.FeeCurrency
