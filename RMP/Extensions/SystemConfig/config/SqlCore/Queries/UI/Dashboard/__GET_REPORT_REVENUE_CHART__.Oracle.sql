SELECT trunc(i.Invoice_date,'MON'),
  i.Invoice_currency AS Currency,
  SUM(i.Invoice_amount) AS Amount
FROM T_INVOICE i
WHERE i.Invoice_date >= %%FROM_DATE%% and i.Invoice_date < %%TO_DATE%%
GROUP BY trunc(i.Invoice_date,'MON'), i.Invoice_currency
ORDER BY trunc(i.Invoice_date,'MON'), i.Invoice_currency