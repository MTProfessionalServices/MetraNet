SELECT i.Invoice_date AS ReportDate,
  i.Invoice_currency AS Currency,
  SUM(i.Invoice_amount) AS Amount
FROM T_INVOICE i
WHERE i.Invoice_date >= add_months(GETUTCDATE(), -13) and i.Invoice_date <= GETUTCDATE()
GROUP BY i.Invoice_date, i.Invoice_currency
ORDER BY ReportDate, Currency
