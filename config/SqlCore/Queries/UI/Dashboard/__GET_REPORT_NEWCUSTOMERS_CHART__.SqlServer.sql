/* Subscription table is not implemented yet, so the query was commented out*/
/*DECLARE @dateFrom DATE, @dateTo DATE
SET @dateFrom = DATEADD(month, -13, GETUTCDATE());
SET @dateTo = DATEADD(month, -1, GETUTCDATE());
SELECT c.AccountId as Account,
       CONVERT(DATE, CONCAT(DATEPART(month, st.StartDate),'-','01','-',DATEPART(year, st.StartDate)), 110) as [Date]
  FROM Customer c
       join Subscription st on c.AccountId = st.AccountId
 WHERE st.StartDate IS NOT NULL
   AND st.StartDate >= @dateFrom
   AND st.StartDate <= @dateTo*/
