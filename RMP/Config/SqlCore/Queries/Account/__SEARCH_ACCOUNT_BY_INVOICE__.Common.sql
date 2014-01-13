
  SELECT DISTINCT acc.id_acc "_AccountID"
	FROM
		t_account acc
		INNER JOIN t_invoice ON acc.id_acc = t_invoice.id_acc
   WHERE t_invoice.invoice_string = '%%INVOICE_ID%%'       
        