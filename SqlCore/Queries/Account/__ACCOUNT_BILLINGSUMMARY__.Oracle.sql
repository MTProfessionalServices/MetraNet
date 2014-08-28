SELECT dense_rank () OVER (ORDER BY invoice_date ASC, id_invoice) AS n_order, 
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
		CAST(inv.invoice_string AS NVARCHAR2(50)) AS item_desc
FROM t_invoice inv 
INNER JOIN ( --subquery to sum up mrr for active subscriptions in the interval
	SELECT 
		inv.id_interval,
		SUM(NVL(mrr.MRR,0.0)) AS MRR
	FROM t_invoice inv 
	INNER JOIN t_usage_interval ui ON inv.id_interval = ui.id_interval
	LEFT OUTER JOIN t_sub sub  ON (inv.id_acc = sub.id_acc and ((ui.dt_end BETWEEN sub.vt_start and sub.vt_end) OR (ui.dt_start BETWEEN sub.vt_start and sub.vt_end)))  -- active regular subscriptions
												OR (id_group IN (SELECT id_group FROM t_gsubmember WHERE id_acc = inv.id_acc AND ((ui.dt_end BETWEEN vt_start AND vt_end) OR (ui.dt_start BETWEEN vt_start AND vt_end)))) -- active group subscriptions
	LEFT OUTER JOIN SubscriptionsByMonth mrr ON sub.id_sub = mrr.SubscriptionId AND to_char(ui.dt_end, 'YYYY') = mrr.year AND to_char(ui.dt_end, 'MM') = mrr.month -- mrr for the interval month
	WHERE inv.id_acc = %%ACCOUNT_ID%%
	GROUP BY inv.id_interval
) TotalMRR ON TotalMRR.id_interval = inv.id_interval 
WHERE 1=1 AND inv.id_acc = %%ACCOUNT_ID%%
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
		null AS n_mrr_amount,
		au.am_currency as currency,
		CAST(pv.id_usage_interval AS NVARCHAR2(50)) as item_desc
FROM t_pv_payment pv 
INNER JOIN t_acc_usage au
ON pv.id_usage_interval = au.id_usage_interval 
	AND pv.id_sess = au.id_sess
WHERE 1=1  
		AND au.id_acc = %%ACCOUNT_ID%%
) a WHERE a.n_order <= 10
ORDER BY n_order DESC