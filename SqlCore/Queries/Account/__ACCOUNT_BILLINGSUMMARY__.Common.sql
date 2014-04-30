SELECT a.*
FROM (select dense_rank () OVER (order by invoice_date asc, id_invoice) AS n_order, 
		'Invoice' AS nm_type, 
		id_interval,
		id_invoice AS id_transaction, 
		invoice_date AS dt_transaction, 
		invoice_amount AS n_amount, 
		invoice_amount AS n_invoice_amount, 
		current_balance n_balance_amount, 
		ar_adj_ttl_amt+postbill_adj_ttl_amt AS n_adj_amount, 
		payment_ttl_amt AS n_payment_amount, 
		isnull(mrr.mrr,0.0) AS n_mrr_amount
FROM t_invoice inv with(nolock)
LEFT OUTER JOIN t_gsubmember mbr with(nolock)
ON mbr.id_acc = inv.id_acc
LEFT OUTER JOIN t_sub sub with(nolock)
ON sub.id_group = mbr.id_group
LEFT OUTER JOIN SubscriptionDataMart..SubscriptionsByMonth mrr 
ON mrr.SubscriptionId = sub.id_sub 
	AND datepart(year, inv.invoice_date) = mrr.year 
	AND datepart(month, inv.invoice_date) = mrr.month
WHERE 1=1 AND inv.id_acc = %%ACCOUNT_ID%%
) a where a.n_order <= 10
UNION ALL
SELECT a.*
FROM (select dense_rank () OVER (order by pv.c_eventdate asc, pv.id_sess) AS n_order, 
		'Payment' AS nm_type, 
		pv.id_usage_interval AS id_interval, 
		pv.id_sess AS id_transaction, 
		pv.c_eventdate AS dt_transaction, 
		au.amount AS n_amount, 
		null AS n_invoice_amount, 
		null AS n_balance_amount, 
		null AS n_adj_amount, 
		au.amount AS n_payment_amount, 
		null AS n_mrr_amount
FROM t_pv_payment pv with(nolock)
INNER JOIN t_acc_usage au with(nolock) 
ON pv.id_usage_interval = au.id_usage_interval 
	AND pv.id_sess = au.id_sess
WHERE 1=1 AND pv.c_source <> 'MT'
		AND au.id_acc = %%ACCOUNT_ID%%
) a WHERE a.n_order <= 10
ORDER BY 5 asc, 4 asc