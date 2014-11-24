
				select 
				  inv.id_payer "Payer",
				  id_invoice_num "Invoice Number",
				  au.total "Contributing Accounts",
				  tx_desc "Invoice Method",
				  namespace "Namespace",
				  invoice_currency "Currency",
				  SUM({fn ifnull(invoice_amount, 0.0)})-sum({fn ifnull(tax_ttl_amt,0.0)})  "Amount",
				  sum({fn ifnull(tax_ttl_amt,0.0)}) "Tax Amount"
				from t_invoice inv
				inner join t_av_internal av on inv.id_payer=av.id_acc
				left outer join t_description des on av.c_invoicemethod=des.id_desc
				inner join (
				    select id_acc, count(distinct id_payee) total 
				    from t_acc_usage where id_usage_interval=%%ID_INTERVAL%% 
				    group by id_acc
				    ) au 
				  on au.id_acc=inv.id_payer
				where id_payer_interval=%%ID_INTERVAL%%
				  and (id_lang_code=%%ID_LANG_CODE%% 
				       or id_lang_code is null)
				group by inv.id_payer,id_invoice_num,invoice_currency,tx_Desc,namespace,au.total
				order by inv.id_payer
			 