
				select 
				  count(*) "# of invoices",
				  tx_desc "Invoice Method",
				  namespace "Namespace",
				  invoice_currency "Currency",
				  SUM({fn ifnull(invoice_amount, 0.0)})-sum({fn ifnull(tax_ttl_amt,0.0)}) "Amount",
				  sum({fn ifnull(tax_ttl_amt,0.0)}) "Tax Amount" 
				from t_invoice inv
				inner join t_av_internal av on inv.id_payer=av.id_acc
				left outer join t_description des on av.c_invoicemethod=des.id_desc
				where id_payer_interval=%%ID_INTERVAL%%
				  and (id_lang_code=%%ID_LANG_CODE%% 
				       or id_lang_code is null)
				group by invoice_currency,tx_Desc,namespace
			 