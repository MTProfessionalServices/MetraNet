SELECT trunc(i.Invoice_date,'MON'),
  i.Invoice_currency AS Currency,
  SUM(i.Invoice_amount) AS Amount,
  lc.tx_desc as LocalizedCurrency
FROM T_INVOICE i
LEFT OUTER JOIN t_enum_data c on LOWER(c.nm_enum_data) = CONCAT('global/systemcurrencies/systemcurrencies/', LOWER(i.Invoice_currency))
LEFT OUTER JOIN t_description lc on lc.id_desc = c.id_enum_data and lc.id_lang_code = %%ID_LANG_CODE%%
WHERE i.Invoice_date >= add_months(GETUTCDATE(), -13) and i.Invoice_date <= GETUTCDATE()
GROUP BY trunc(i.Invoice_date,'MON'), i.Invoice_currency, lc.tx_desc
ORDER BY trunc(i.Invoice_date,'MON'), i.Invoice_currency