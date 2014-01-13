

		SELECT t_invoice.id_invoice, t_invoice.invoice_string, 
			t_invoice.id_interval, t_invoice.id_acc, 
			t_invoice.invoice_amount, TO_CHAR(t_invoice.invoice_date) AS invoice_date, 
			TO_CHAR(t_invoice.invoice_due_date) AS invoice_due_date
		FROM t_account_mapper,t_namespace, t_invoice
		WHERE    
			upper(t_account_mapper.nm_space) = upper(t_namespace.nm_space) 
			AND
			t_account_mapper.id_acc = t_invoice.id_acc
			AND ((t_account_mapper.id_acc = %%ACCOUNT_ID%%) AND (upper(t_namespace.tx_typ_space) = upper('system_mps')))
			AND  t_invoice.id_interval=%%INTERVAL_ID%%

		