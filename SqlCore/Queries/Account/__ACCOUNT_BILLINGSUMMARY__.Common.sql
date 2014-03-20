select a.*
from (select dense_rank () OVER (order by invoice_date asc, id_invoice) n_order, 'Invoice' nm_type, id_interval, id_invoice id_transaction, invoice_date dt_transaction, invoice_amount n_amount, invoice_amount n_invoice_amount, current_balance n_balance_amount, ar_adj_ttl_amt+postbill_adj_ttl_amt n_adj_amount, payment_ttl_amt n_payment_amount, isnull(mrr.mrr,0.0) n_mrr_amount
from t_invoice inv with(nolock)
left outer join t_gsubmember mbr with(nolock) on mbr.id_acc = inv.id_acc
left outer join t_sub sub with(nolock) on sub.id_group = mbr.id_group
left outer join SubscriptionDataMart..SubscriptionsByMonth mrr on mrr.SubscriptionId = sub.id_sub and datepart(year, inv.invoice_date) = mrr.year and datepart(month, inv.invoice_date) = mrr.month
where 1=1 and inv.id_acc = %%ACCOUNT_ID%%
) a where a.n_order <= 10
union all
select a.*
from (select dense_rank () OVER (order by pv.c_eventdate asc, pv.id_sess) n_order, 'Payment' nm_type, pv.id_usage_interval id_interval, pv.id_sess id_transaction, pv.c_eventdate dt_transaction, au.amount n_amount, null n_invoice_amount, null n_balance_amount, null n_adj_amount, au.amount n_payment_amount, null n_mrr_amount
from t_pv_payment pv with(nolock)
inner join t_acc_usage au with(nolock) on pv.id_usage_interval = au.id_usage_interval and pv.id_sess = au.id_sess
where 1=1 and pv.c_source <> 'MT' and au.id_acc = %%ACCOUNT_ID%%
) a where a.n_order <= 10
order by 5 asc, 4 asc
