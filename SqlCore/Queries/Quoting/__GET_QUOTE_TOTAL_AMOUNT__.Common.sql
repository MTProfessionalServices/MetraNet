SELECT 
	SUM (_Amount) as Amount,
	SUM (_TaxTotal) as TaxTotal,
	MAX(_Currency) as Currency
FROM
(

	SELECT 
			SUM(au.amount) AS _Amount,
			MAX(au.am_currency) AS _Currency,
			(CASE WHEN au.tax_federal IS NULL THEN 0 ELSE SUM(au.tax_federal) END) +
			(CASE WHEN au.tax_state IS NULL THEN 0 ELSE SUM(au.tax_state) END) +
			(CASE WHEN au.tax_county IS NULL THEN 0 ELSE SUM(au.tax_county) END) +
			(CASE WHEN au.tax_local IS NULL THEN 0 ELSE SUM(au.tax_local) END) +
			(CASE WHEN au.tax_other IS NULL THEN 0 ELSE SUM(au.tax_other) END) AS _TaxTotal		 
	FROM t_acc_usage au
	WHERE au.id_acc in (%%ACCOUNTS%%) and au.id_usage_interval = %%USAGE_INTERVAL%% 
	and 	au.tx_batch in (%%BATCHIDS%%)
	GROUP BY 
			au.tax_federal,
			au.tax_state,
			au.tax_county,
			au.tax_local,
			au.tax_other
) as a
		