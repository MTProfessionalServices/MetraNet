DECLARE @dateFrom DATE, @dateTo DATE
SET @dateFrom = DATEADD(month, -13, GETUTCDATE());
SET @dateTo = DATEADD(month, -1, GETUTCDATE());
SELECT 
       CONVERT(DATE, CONCAT(DATEPART(month, c.StartDate),'-','01','-',DATEPART(year, c.StartDate)), 110) AS [Date],
			 COUNT(c.MetraNetId) AS CustomerCount
  FROM Customer c
 WHERE c.StartDate >= @dateFrom
   AND c.StartDate <= @dateTo
GROUP BY CONVERT(DATE, CONCAT(DATEPART(month, c.StartDate),'-','01','-',DATEPART(year, c.StartDate)), 110)
