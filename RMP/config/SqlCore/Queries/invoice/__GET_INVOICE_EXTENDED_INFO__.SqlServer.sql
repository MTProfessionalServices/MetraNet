

		SELECT t_invoice.id_invoice, t_invoice.invoice_string, 
			t_invoice.id_interval, t_invoice.id_acc, 
			t_invoice.invoice_amount, CONVERT(varchar, t_invoice.invoice_date) AS invoice_date, 
			CONVERT(varchar, t_invoice.invoice_due_date) AS invoice_due_date
		FROM t_account_mapper,t_namespace, t_invoice
		WHERE    
			t_account_mapper.nm_space = t_namespace.nm_space 
			AND
			t_account_mapper.id_acc = t_invoice.id_acc
			AND ((t_account_mapper.id_acc = %%ACCOUNT_ID%%) AND (t_namespace.tx_typ_space = 'system_mps'))
			AND  t_invoice.id_interval=%%INTERVAL_ID%%

		