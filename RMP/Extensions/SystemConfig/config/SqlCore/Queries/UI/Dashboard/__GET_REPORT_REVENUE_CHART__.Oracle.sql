SELECT trunc(i.Invoice_date,'MON'),
  i.Invoice_currency AS Currency,
  SUM(i.Invoice_amount) AS Amount
FROM T_INVOICE i
WHERE i.Invoice_date >= add_months(GETUTCDATE(), -13) and i.Invoice_date <= GETUTCDATE()
GROUP BY trunc(i.Invoice_date,'MON'), i.Invoice_currency
ORDER BY trunc(i.Invoice_date,'MON'), Currency
