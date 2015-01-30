SELECT
       TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY') as "Date",
       sm.ReportingCurrency as CurrencyCode,
       SUM(sm.MrrPrimaryCurrency) as Amount
FROM SubscriptionsByMonth sm
WHERE TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY') >= %%FROM_DATE%%
  AND TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY') < %%TO_DATE%%
GROUP BY TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY'), sm.ReportingCurrency
