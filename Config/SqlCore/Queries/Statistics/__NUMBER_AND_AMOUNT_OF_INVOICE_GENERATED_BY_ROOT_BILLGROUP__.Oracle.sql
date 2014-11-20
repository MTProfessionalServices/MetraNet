select
	dbo.GenGuid() "ID",
	COALESCE(pam.nm_login, 'Non-Partitioned') "Partition",
	inv.invoice_currency "Currency",
	count(*) "# Invoices",
	sum(NVL(inv.invoice_amount, 0.0))  "Total Amount",
	sum(NVL(inv.payment_ttl_amt, 0.0)) "Total Payment Amount",
	sum(NVL(inv.tax_ttl_amt, 0.0))     "Total Tax Amount",
	sum(NVL(inv.postbill_adj_ttl_amt, 0.0) + NVL(inv.ar_adj_ttl_amt, 0.0)) "Total Adjustment Amount"
from t_invoice inv
join t_billgroup_member bgm on inv.id_acc = bgm.id_acc
join t_billgroup bg on bgm.id_root_billgroup = bg.id_billgroup
                       and bg.id_billgroup = %%ID_BILLINGGROUP%%
left outer join t_account_mapper pam on pam.id_acc = bg.id_partition                      
where id_interval = %%ID_INTERVAL%%
group by COALESCE(pam.nm_login, 'Non-Partitioned'), inv.invoice_currency

