
				select 
				  dbo.GenGuid() "ID", /* dummy filed as identifier for GridLayout*/	
		  		  COALESCE(partition_name,'Non-Partitioned') Partition,	
				  count(*) "NUMOFINV",
				  invoice_currency "CURRENCY",
				  SUM({fn ifnull(invoice_amount, 0.0)}) - sum({fn ifnull(tax_ttl_amt,0.0)}) "TOTALAMT",
				  sum({fn ifnull(tax_ttl_amt,0.0)}) "TOTALTAX" 
			  from t_invoice inv 
				inner join t_av_internal av on inv.id_payer=av.id_acc
				left outer join t_description des on av.c_invoicemethod=des.id_desc
                left outer join vw_bus_partition_accounts bpt on bpt.id_acc = inv.id_acc
				where id_payer_interval=%%ID_INTERVAL%%
				  and (id_lang_code=%%ID_LANG_CODE%% 
				       or id_lang_code is null)
				group by COALESCE(partition_name,'Non-Partitioned'),invoice_currency
