SELECT 
  CONVERT(DATE, CONCAT(DATEPART(month, i.Invoice_date),'-','01','-',DATEPART(year, i.Invoice_date)), 110) as [Date]
  ,i.Invoice_currency AS [Currency]
  ,SUM(i.Invoice_amount) AS [Amount]
FROM T_invoice i
WHERE i.Invoice_date >= %%FROM_DATE%% and i.Invoice_date < %%TO_DATE%%
GROUP BY CONVERT(DATE, CONCAT(DATEPART(month, i.Invoice_date),'-','01','-',DATEPART(year, i.Invoice_date)), 110), i.Invoice_currency
ORDER BY [Date], [Currency]