				
				SELECT
					dbo.GenGuid() "ID", /* dummy filed as identifier for GridLayout*/
                    COALESCE(partition_name, N'Non-Partitioned') "PARTITION",          
					COUNT(*) AS "# of invoices",
					tx_desc AS "Invoice Method",
					namespace AS Namespace,
					invoice_currency AS Currency,
					SUM(NVL(invoice_amount, 0.0)) - SUM(NVL(tax_ttl_amt,0.0)) AS Amount,
					SUM(NVL(tax_ttl_amt,0.0)) AS "Tax Amount" 
				FROM t_invoice inv
				INNER JOIN t_av_internal av ON inv.id_payer=av.id_acc
				LEFT OUTER JOIN t_description des ON av.c_invoicemethod=des.id_desc
 				left outer join vw_bus_partition_accounts bpt on bpt.id_acc = inv.id_acc
				WHERE id_payer_interval=%%ID_INTERVAL%%
				  AND (id_lang_code=%%ID_LANG_CODE%% 
				       OR id_lang_code IS NULL)
				GROUP BY partition_name,invoice_currency,tx_Desc,namespace
