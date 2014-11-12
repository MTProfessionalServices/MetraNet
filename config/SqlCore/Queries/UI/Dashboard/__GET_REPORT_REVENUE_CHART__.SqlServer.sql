declare @dateFrom DATE, @dateTo DATE;
SET @dateFrom = DATEADD(month, -13, GETUTCDATE());
SET @dateTo = GETUTCDATE();--DATEADD(day, -1, CONVERT(DATE, CONCAT(DATEPART(month, GETUTCDATE()),'-','01','-',DATEPART(year, GETUTCDATE())), 110));
SELECT 
  CONVERT(DATE, CONCAT(DATEPART(month, i.Invoice_date),'-','01','-',DATEPART(year, i.Invoice_date)), 110) as [Date]
  ,i.Invoice_currency as [Currency]
  ,SUM(i.Invoice_amount) as [Amount]
	,lc.tx_desc as [LocalizedCurrency]
FROM T_invoice i
LEFT OUTER JOIN t_enum_data c on LOWER(c.nm_enum_data) = CONCAT('global/systemcurrencies/systemcurrencies/', LOWER(i.Invoice_currency))
LEFT OUTER JOIN t_description lc on lc.id_desc = c.id_enum_data and lc.id_lang_code = %%ID_LANG_CODE%%
WHERE i.Invoice_date >= @dateFrom and i.Invoice_date <= @dateTo
GROUP BY CONVERT(DATE, CONCAT(DATEPART(month, i.Invoice_date),'-','01','-',DATEPART(year, i.Invoice_date)), 110), i.Invoice_currency, lc.tx_desc
ORDER BY [Date], [Currency]