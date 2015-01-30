SELECT a.*
FROM (
SELECT DENSE_RANK () OVER (ORDER BY invoice_date DESC, id_invoice) AS n_order, 
		'Invoice' AS nm_type, 
		inv.id_interval,
		id_invoice AS id_transaction, 
		invoice_date AS dt_transaction, 
		invoice_amount AS n_amount, 
		invoice_amount AS n_invoice_amount, 
		current_balance n_balance_amount, 
		ar_adj_ttl_amt+postbill_adj_ttl_amt AS n_adj_amount, 
		payment_ttl_amt AS n_payment_amount, 
		TotalMRR.MRR AS n_mrr_amount,
		inv.invoice_currency AS currency,
		CONVERT(NVARCHAR, inv.invoice_string) AS item_desc
FROM t_invoice inv WITH(NOLOCK)
INNER JOIN ( --subquery to sum up mrr for active subscriptions in the interval
	SELECT 
		inv.id_interval,
		SUM(ISNULL(mrr.MRR,0.0)) AS MRR
	FROM t_invoice inv WITH(NOLOCK)
	INNER JOIN t_usage_interval ui WITH(NOLOCK) ON inv.id_interval = ui.id_interval
	LEFT OUTER JOIN t_payment_redirection pr on inv.id_acc = pr.id_payer
	LEFT OUTER JOIN t_vw_effective_subs sub with(nolock) ON pr.id_payee = sub.id_acc
	LEFT OUTER JOIN SubscriptionsByMonth mrr WITH(NOLOCK) ON sub.id_sub = mrr.SubscriptionId AND datepart(year, ui.dt_end) = mrr.year AND datepart(month, ui.dt_end) = mrr.month -- mrr for the interval month
	WHERE inv.id_acc = %%ACCOUNT_ID%%
	GROUP BY inv.id_interval
) TotalMRR ON TotalMRR.id_interval = inv.id_interval 
WHERE 1=1 AND inv.id_acc = %%ACCOUNT_ID%%
) a WHERE a.n_order <= 10 
UNION ALL
SELECT a.*
FROM (SELECT DENSE_RANK () OVER (ORDER BY pv.c_eventdate DESC, pv.id_sess) AS n_order, 
		'Payment' AS nm_type, 
		pv.id_usage_interval AS id_interval, 
		pv.id_sess AS id_transaction, 
		pv.c_eventdate AS dt_transaction, 
		au.amount AS n_amount, 
		NULL AS n_invoice_amount, 
		NULL AS n_balance_amount, 
		NULL AS n_adj_amount, 
		au.amount AS n_payment_amount, 
		NULL AS n_mrr_amount,
		au.am_currency AS currency,
		CONVERT(NVARCHAR, pv.id_usage_interval) AS item_desc
FROM t_pv_payment pv WITH(NOLOCK)
INNER JOIN t_acc_usage au WITH(NOLOCK) 
ON pv.id_usage_interval = au.id_usage_interval 
	AND pv.id_sess = au.id_sess
WHERE 1=1  
		AND au.id_acc = %%ACCOUNT_ID%%
) a WHERE a.n_order <= 10
ORDER BY n_order DESC
