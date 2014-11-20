SELECT
       TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY') as "Date",
       sm.ReportingCurrency as CurrencyCode,
       SUM(sm.MrrPrimaryCurrency) as Amount,
			 NVL(lc.tx_desc, sm.ReportingCurrency) as LocalizedCurrency
FROM SubscriptionsByMonth sm
LEFT OUTER JOIN t_enum_data c on LOWER(c.nm_enum_data) = CONCAT('global/systemcurrencies/systemcurrencies/', LOWER(sm.ReportingCurrency))
LEFT OUTER JOIN t_description lc on lc.id_desc = c.id_enum_data and lc.id_lang_code = %%ID_LANG_CODE%%
WHERE TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY') >= %%FROM_DATE%%
  AND TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY') < %%TO_DATE%%
GROUP BY TO_DATE(LPAD(TO_CHAR(sm.Month), 2, '0') || '-01-' || TO_CHAR(sm.Year), 'MM-DD-YYYY'), sm.ReportingCurrency, lc.tx_desc
