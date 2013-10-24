			delete from t_pending_ach_trans where id_payment_transaction = N'%%PAYMENT_TX_ID%%'    
		  delete from t_pending_ach_trans_details where id_payment_transaction = N'%%PAYMENT_TX_ID%%';
		  