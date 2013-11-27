SELECT 
		SUM(au.amount) AS Amount,
		MAX(au.am_currency) AS Currency,
		(CASE WHEN au.tax_federal IS NULL THEN 0 ELSE SUM(au.tax_federal) END) AS Tax_Federal,
		(CASE WHEN au.tax_state IS NULL THEN 0 ELSE SUM(au.tax_state) END) AS Tax_State,
		(CASE WHEN au.tax_county IS NULL THEN 0 ELSE SUM(au.tax_county) END) AS Tax_County,
		(CASE WHEN au.tax_local IS NULL THEN 0 ELSE SUM(au.tax_local) END) AS Tax_Local,
		(CASE WHEN au.tax_other IS NULL THEN 0 ELSE SUM(au.tax_other) END) AS Tax_Other
FROM t_acc_usage au
WHERE au.id_acc in (%%ACCOUNTS%%) and au.id_usage_interval = %%USAGE_INTERVAL%%
GROUP BY 
		au.tax_federal,
		au.tax_state,
		au.tax_county,
		au.tax_local,
		au.tax_other
		