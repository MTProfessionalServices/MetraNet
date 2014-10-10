select
	dbo.GenGuid() "ID",
	bg.tx_name "Partition",
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
where id_interval = %%ID_INTERVAL%%
group by bg.tx_name, inv.invoice_currency

