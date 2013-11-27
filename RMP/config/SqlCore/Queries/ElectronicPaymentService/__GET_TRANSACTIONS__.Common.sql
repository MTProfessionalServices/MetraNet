
			  select t_payment_history.id_payment_transaction as TransactionId,
			  t_payment_history.id_acct as Payer,
			  t_payment_history.dt_transaction as TransactionDate, 
			  t_payment_history.n_amount as Amount,
			  t_payment_history.n_state as Status,
			  t_payment_history.n_operator_notes as OperatorNotes,
			  t_payment_history_details.nm_invoice_num as InvoiceNumber
			  from t_payment_history join t_payment_history_details on 
			  t_payment_history.id_payment_transaction = t_payment_history_details.id_payment_transaction 