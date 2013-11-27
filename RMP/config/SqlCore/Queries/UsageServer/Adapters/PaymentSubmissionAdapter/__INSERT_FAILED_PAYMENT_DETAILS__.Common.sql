
			   insert into t_failed_payment_details 
				(id_interval, id_acc, id_payment_instrument, nm_invoice_num, 
							dt_invoice, nm_po_number, n_amount) values 
				(%%INTERVAL_ID%%, %%ACCOUNT_ID%%, N'%%PI_ID%%', N'%%INVOICE_NUM%%', 
							%%DT_INVOICE%%, N'%%PO_NUM%%', %%AMOUNT%%)