declare @dateFrom DATE, @dateTo DATE;
SET @dateFrom = DATEADD(month, -13, GETDATE());
SET @dateTo = GETDATE();--DATEADD(day, -1, CONVERT(DATE, CONCAT(DATEPART(month, GETDATE()),'-','01','-',DATEPART(year, GETDATE())), 110));
SELECT CONVERT(DATE, CONCAT(DATEPART(month, i.Invoice_date),'-','01','-',DATEPART(year, i.Invoice_date)), 110) as [Date]
      ,i.Invoice_currency as [Currency]
	  ,SUM(i.Invoice_amount) as [Amount]
  FROM T_invoice i
 WHERE i.Invoice_date >= @dateFrom and i.Invoice_date <= @dateTo
GROUP BY CONVERT(DATE, CONCAT(DATEPART(month, i.Invoice_date),'-','01','-',DATEPART(year, i.Invoice_date)), 110), i.Invoice_currency
ORDER BY [Date], [Currency]
