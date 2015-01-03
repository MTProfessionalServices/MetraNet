SELECT
       TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY') as "Date",
       sm.ReportingCurrency as CurrencyCode,
       SUM(sm.MrrPrimaryCurrency) as Amount,
			 NVL(lc.tx_desc, sm.ReportingCurrency) as LocalizedCurrency
FROM SubscriptionsByMonth sm
WHERE TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY') >= add_months(GETUTCDATE(), -13)
  AND TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY') <= GETUTCDATE()
GROUP BY TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY'), sm.ReportingCurrency
