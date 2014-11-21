
				select 
				  dbo.GenGuid() "ID", /* dummy filed as identifier for GridLayout*/	
		          COALESCE(partition_name, N'Non-Partitioned') "PARTITION",
				  inv.id_payer AS Payer,
				  id_invoice_num AS "Invoice Number",
				  au.total AS "Contributing Accounts",
				  tx_desc AS "Invoice Method",
				  namespace AS Namespace,
				  invoice_currency AS Currency,
				  SUM(NVL(invoice_amount, 0.0)) - SUM(NVL(tax_ttl_amt,0.0))  AS Amount,
				  SUM(NVL(tax_ttl_amt,0.0)) AS "Tax Amount"
				from t_invoice inv
				inner join t_av_internal av on inv.id_payer=av.id_acc
				left outer join t_description des on av.c_invoicemethod=des.id_desc
				inner join (
				    select id_acc, count(distinct id_payee) total 
				    from t_acc_usage where id_usage_interval=%%ID_INTERVAL%% 
				    group by id_acc
				    ) au 
				  on au.id_acc=inv.id_payer
				left outer join vw_bus_partition_accounts bpt on bpt.id_acc = au.id_acc
				where id_payer_interval=%%ID_INTERVAL%%
				  and (id_lang_code=%%ID_LANG_CODE%% 
				       or id_lang_code is null)
				group by partition_name,inv.id_payer,id_invoice_num,invoice_currency,tx_Desc,namespace,au.total
