select
	dbo.GenGuid() "ID",
	COALESCE(pam.nm_login, N'Non-Partitioned') "PARTITION",
	inv.invoice_currency "Currency",
	count(*) "# Invoices",
	sum({fn ifnull(inv.invoice_amount, 0.0)})  "Total Amount",
	sum({fn ifnull(inv.payment_ttl_amt, 0.0)}) "Total Payment Amount",
	sum({fn ifnull(inv.tax_ttl_amt, 0.0)})     "Total Tax Amount",
	sum({fn ifnull(inv.postbill_adj_ttl_amt, 0.0)} + {fn ifnull(inv.ar_adj_ttl_amt, 0.0)}) "Total Adjustment Amount"
from t_invoice inv
join t_billgroup_member bgm on inv.id_acc = bgm.id_acc
join t_billgroup bg on bgm.id_root_billgroup = bg.id_billgroup
                       and bg.id_billgroup = %%ID_BILLINGGROUP%%
left outer join t_account_mapper pam on pam.id_acc = bg.id_partition                      
where id_interval = %%ID_INTERVAL%%
group by pam.nm_login, inv.invoice_currency

