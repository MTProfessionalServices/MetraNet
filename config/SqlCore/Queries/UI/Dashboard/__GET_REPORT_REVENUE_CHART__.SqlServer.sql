SELECT 
  CONVERT(DATE, CONCAT(DATEPART(month, i.Invoice_date),'-','01','-',DATEPART(year, i.Invoice_date)), 110) as [Date]
  ,i.Invoice_currency AS [Currency]
  ,SUM(i.Invoice_amount) AS [Amount]
  ,ISNULL(lc.tx_desc, i.Invoice_currency)  AS [LocalizedCurrency]
FROM T_invoice i
LEFT OUTER JOIN t_enum_data c on LOWER(c.nm_enum_data) = CONCAT('global/systemcurrencies/systemcurrencies/', LOWER(i.Invoice_currency))
LEFT OUTER JOIN t_description lc on lc.id_desc = c.id_enum_data and lc.id_lang_code = %%ID_LANG_CODE%%
WHERE i.Invoice_date >= %%FROM_DATE%% and i.Invoice_date < %%TO_DATE%%
GROUP BY CONVERT(DATE, CONCAT(DATEPART(month, i.Invoice_date),'-','01','-',DATEPART(year, i.Invoice_date)), 110), i.Invoice_currency, lc.tx_desc
ORDER BY [Date], [Currency]