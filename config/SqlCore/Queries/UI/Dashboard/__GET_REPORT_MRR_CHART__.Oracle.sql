SELECT
       TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY') as "Date",
       sm.ReportingCurrency as CurrencyCode,
       SUM(sm.MrrPrimaryCurrency) as Amount
FROM SubscriptionsByMonth sm
WHERE TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY') >= add_months(GETUTCDATE(), -13)
  AND TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY') < trunc(add_months(GETUTCDATE(), 12),'MON')
GROUP BY TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY'), sm.ReportingCurrency
